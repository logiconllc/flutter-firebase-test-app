import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProjectUtils {
  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<String> fetchChannelStatus(String json, String url) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    // make POST request
    Response response = await post(url, headers: headers, body: json);
    // check the status code for the result
  //  int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    String body = response.body;
    return body;
  }
}
