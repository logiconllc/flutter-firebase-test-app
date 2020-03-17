
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notification_sample_app/Questions.dart';
import 'package:notification_sample_app/TopicsScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';


void main() => runApp(NotificationHome());

class NotificationHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(),
    );
  }
}


class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String fcmToken = "";
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();



  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage called: $message');
        displayNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume called: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch called: $message');
      },
    );


    firebaseMessaging.getToken().then((token) {
      fcmToken = token;
      print("FCM-Token"+fcmToken);
    });
  }


  Future displayNotification(Map<String, dynamic> message) async{
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'FirebaseFcm', 'FirebaseFcm', 'FirebaseFcm Sample App',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: 'hello',);
  }
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
//    await Fluttertoast.showToast(
//        msg: "Notification Clicked",
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.BOTTOM,
//        timeInSecForIos: 1,
//        backgroundColor: Colors.black54,
//        textColor: Colors.white,
//        fontSize: 16.0
//    );
    // Navigator.push(
    //   context,
    //   new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    // );
  }
  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
//              Navigator.of(context, rootNavigator: true).pop();
//              await Fluttertoast.showToast(
//                  msg: "Notification Clicked",
//                  toastLength: Toast.LENGTH_SHORT,
//                  gravity: ToastGravity.BOTTOM,
//                  timeInSecForIos: 1,
//                  backgroundColor: Colors.black54,
//                  textColor: Colors.white,
//                  fontSize: 16.0
//              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notifications Sample App'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> TopicsScreen(fcmToken: fcmToken,)));
              },
              child: Text('Fetch Topics'),
              ),
              RaisedButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Question(fcmToken: fcmToken,)));
              },
                child: Text('Questions'),
              )

            ],
          ),
        ),
      ),
    );
  }
}

//Container(
//padding: const EdgeInsets.all(10.0),
//child: StreamBuilder<QuerySnapshot>(
//stream: Firestore.instance.collection('topics').snapshots(),
//builder: (BuildContext context,
//    AsyncSnapshot<QuerySnapshot> snapshot) {
//if (snapshot.hasError)
//return new Text('Error: ${snapshot.error}');
//switch (snapshot.connectionState) {
//case ConnectionState.waiting:
//return new Text('Loading...');
//default:
//return new ListView(
//children: snapshot.data.documents
//    .map((DocumentSnapshot document) {
//return GestureDetector(
//onTap: () async {
//ProjectUtils.showToast(document.documentID);
//
//print(fcmToken);
//
//String json =
//'{"topic_id": "${document.documentID}", "device_token": "$fcmToken"}';
//
//String url =
//'https://us-central1-notification-sample-bdb6a.cloudfunctions.net/subscribeToTopic';
//ProjectUtils.showToast(
//await ProjectUtils.fetchChannelStatus(
//json, url));
//},
//child: new ListTile(
//leading: Icon(Icons.track_changes),
//title: Text(document['name']),
//subtitle: Text(document.documentID),
//),
//);
//}).toList(),
//);
//}
//},
//))
