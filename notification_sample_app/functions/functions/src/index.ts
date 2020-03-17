import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableContext } from 'firebase-functions/lib/providers/https';
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore';

admin.initializeApp();

const db = admin.firestore();

exports.listTopics = functions.https.onCall(async (data: any, context: CallableContext) => {
    const { device_token } = data;

    console.log("device_token", device_token);

    try {

        let allTopics: any[] = [];

        const snapshot = await db.collection("topics").get();

        if (snapshot.empty) {
            return allTopics
        }

        snapshot.forEach(topic => allTopics.push({ ...topic.data(), ...{ id: topic.id } }));

        allTopics = allTopics.map((topic: any) =>
            ({ ...topic, ...{ is_subscribed: topic.device_token && topic.device_token.includes(device_token) ? true : false } }))
        return allTopics


    } catch (e) {
        return false
    }

})

exports.subscribeToTopic = functions.https.onCall(async (data: any, context: CallableContext) => {
    const { topic_id, device_token } = data

    const ref = db.collection("topics").doc(topic_id);
    await ref.update({ device_token: admin.firestore.FieldValue.arrayUnion(device_token) })

    try {
        await admin.messaging().subscribeToTopic([device_token], topic_id);

        const message = {
            notification: {
                title: "New Notification",
                body: "New User Subscribed"
            },
            data: {
                title: "New Notification"
            },
            topic: topic_id
        }

        await admin.messaging().send(message)

        return true;
    } catch (e) {
        console.log(e)
        return false;
    }

})

exports.unsubscribeFromTopic = functions.https.onCall(async (data: any, context: CallableContext) => {
    const { topic_id, device_token } = data;

    const ref = db.collection("topics").doc(topic_id);
    await ref.update({ device_token: admin.firestore.FieldValue.arrayRemove(device_token) })

    try {
        await admin.messaging().unsubscribeFromTopic([device_token], topic_id)
        return true;
    } catch (e) {
        return false
    }
})

exports.stateHandler = functions.firestore.document("users/{uid}/messages/{msg_id}")
    .onWrite(async (change: functions.Change<DocumentSnapshot>, context: functions.EventContext) => {
        const { uid } = context.params
        const afterData = change.after.data();

        let state = 'B';
        let count = 0;


        const snapshot = await db.collection('users').doc(uid).get()
        const data = snapshot.data()

        if (!snapshot.exists) {
            return;
        }

        if (data!.count === 5) {
            state = 'A';
            count = 0
            await db.collection('users').doc(uid).update({ state, count });
            await db.collection('users').doc(uid).collection('messages').add({ text: "Seems like we can’t proceed.", date: new Date().toISOString() })
            return;
        }


        if ((afterData!.text === "Please tell me your age?") ||
            data!.state === 'C' ||
            afterData!.text === "That doesn’t seem the right answer" ||
            afterData!.text === "Thank You!") {
            return;
        }

        console.log("typeof afterData!.text === 'number'", typeof afterData!.text)

        if (typeof afterData!.text === 'number') {
            state = 'C';
            count = data!.count + 1
            await db.collection('users').doc(uid).update({ state, count });
            await db.collection('users').doc(uid).collection('messages').add({ text: "Thank You!", date: new Date().toISOString() })
            return;
        }

        if (afterData!.text !== 'number' && data!.count < 5) {
            count = data!.count + 1
            await db.collection('users').doc(uid).update({ state, count });
            await db.collection('users').doc(uid).collection('messages')
                .add({ text: "That doesn’t seem the right answer", date: new Date().toISOString() })
            return;
        }

    })
