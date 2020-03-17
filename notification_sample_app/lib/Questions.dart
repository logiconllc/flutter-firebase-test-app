import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notification_sample_app/models/Topics.dart';
import "dart:async";
import 'package:cloud_functions/cloud_functions.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:string_validator/string_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Question extends StatefulWidget {
  String fcmToken;

  Question({@required this.fcmToken});

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  String userAge = "";
  String answer = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _authResult;
  DocumentReference documentReference;
  FirebaseUser firebaseUser;
  List<String> list = List<String>();

  Future<FirebaseUser> _getAnonymouslyUID() async {
//    firebaseUser = await _auth.currentUser();
//    bool wasSignIn = true;
//    if (firebaseUser == null) wasSignIn = false;

    _authResult = await _auth.signInAnonymously();
    firebaseUser = await _auth.currentUser();
    documentReference =
        Firestore.instance.collection("users").document(_authResult.user.uid);
    //if (!wasSignIn) {
    documentReference.setData({'count': 0, 'state': 'B'});
    addQuestionNode();
    //}
    return firebaseUser;
  }

  void listenChanges() {
    list.clear();
    CollectionReference reference = Firestore.instance
        .collection('users')
        .document(_authResult.user.uid)
        .collection("messages");
    reference.orderBy("date").snapshots().listen((querySnapshot) {
      print("Size" + querySnapshot.documentChanges.length.toString());
      querySnapshot.documentChanges.forEach((change) {
        list.add(change.document.data['text'].toString());
        print(change.document.data['text'].toString());
      });
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text(list[list.length - 1]),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _auth.signOut();
  }

  void addQuestionNode() {
    documentReference.collection('messages').document().setData({
      'text': 'Please tell me your age?',
      'date':
          '${DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now())}',
    });
  }

  Widget getQuestionFormView(FirebaseUser data) {
//    documentReference =
//        Firestore.instance.collection("users").document(data.uid);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 40,
        ),
        Text('Please tell me your age?'),
        SizedBox(
          height: 20,
        ),
        TextField(
          decoration: InputDecoration(
            hintText: data.uid,
          ),
          onChanged: (String value) {
            userAge = value;
          },
          onSubmitted: (String answer) {},
        ),
        SizedBox(
          height: 20,
        ),
        RaisedButton(
          onPressed: () async{
            if (userAge.isNotEmpty) {
              if (isNumeric(userAge)) {
                documentReference.collection('messages').document().setData({
                  'text': int.parse(userAge),
                  'date':
                      '${DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now())}',
                });
              } else {
                documentReference.collection('messages').document().setData({
                  'text': userAge,
                  'date': '${DateTime.now().toString()}',
                });
              }
              await new Future.delayed(const Duration(seconds : 5));
              listenChanges();
            }
          },
          child: Text('Submit'),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<FirebaseUser>(
          future: _getAnonymouslyUID(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FirebaseUser data = snapshot.data;
              return getQuestionFormView(data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
