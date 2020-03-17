import 'package:flutter/material.dart';
import 'package:notification_sample_app/models/Topics.dart';
import "dart:async";
import 'package:cloud_functions/cloud_functions.dart';
import 'package:progress_dialog/progress_dialog.dart';


class TopicsScreen extends StatefulWidget {

  String fcmToken;

  TopicsScreen({@required this.fcmToken});

  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {

//  List<Topic> topics;
  ProgressDialog pr;
  List<Topic> topicsList = List<Topic>();



  @override
  void initState() {
    super.initState();
  }

  Future<List<Topic>> _fetchTopics() async {
    HttpsCallable callable =  CloudFunctions.instance.getHttpsCallable(functionName: "listTopics");
    HttpsCallableResult response = await callable.call(<String, dynamic>{
      'device_token': '${widget.fcmToken}'
    });
    List<Topic> topics = List<Topic>();
    for( var i = 0 ; i < response.data.length; i++ ) {
      topics.add(Topic(id: response.data[i]['id'] , name: response.data[i]['name'] , is_subscribed:response.data[i]['is_subscribed'] ));
    }
    topicsList.clear();
    topicsList.addAll(topics);
    return topicsList;
  }

  ListTile _tile(
      String title, String subtitle, IconData icon, bool isSubscribed) =>
      ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(subtitle),
        leading: Icon(
          icon,
          color: Colors.blue[500],
        ),
        trailing: Icon(
            isSubscribed ? Icons.notifications_active : Icons.notifications),
      );

  ListView _topicsListView(data) {
    print("topics data"+ data.toString());
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () async{
                pr= new ProgressDialog(context);
                String url = "";
                bool statusToSet = false;
                if(data[index].is_subscribed) {
                  url = "unsubscribeFromTopic";
                  statusToSet = false;
                }
                else {
                  url = "subscribeToTopic";
                  statusToSet = true;
                }
                HttpsCallable callable =  CloudFunctions.instance.getHttpsCallable(functionName: url); // replace 'functionName' with the name of your function
                pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
                pr.show();

                HttpsCallableResult response = await callable.call(<String, dynamic>{
                  'device_token': '${widget.fcmToken}',
                  'topic_id' : '${data[index].id}'
                });
                pr.hide();
                setState(() {
                  topicsList[index].is_subscribed = statusToSet;
                });
              },
              child: _tile(data[index].name, data[index].id,
                  Icons.track_changes, data[index].is_subscribed));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<List<Topic>>(
          future: _fetchTopics(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Topic> data = snapshot.data;
              return _topicsListView(data);
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
