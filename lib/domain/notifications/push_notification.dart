import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../core/global/auth/auth.dart';

class PushNotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  sendNotification(String title, List<String?> token, String body, Map<String, dynamic> map) async {
    final data = {
      //   "registration_ids" : token,
      // "collapse_key" : "type_a",
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'data': map// 'to': '/topics/preAlert',
    };

    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAZgoNLSU:APA91bFZroYBmKtHrxya-9HaUbE28yigy0Ng-BNHmAZyoIj7CirUNB8ZC8yNavvZWnbtB57RyLfOBHWAbBLOhMF0DypAqQjlmqAeMiZjafW3U-wFQu-ZPCkeQVXkRgpBQizqvB6V98wm'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': 'NEW DRIVE REQUEST',
                  'body': '$body has just been created'
                },
                'priority': 'high',
                'data': data,
                "registration_ids": token,
                // 'to': '/topics/preAlert',
                'message': 'hello',
              }));

      if (response.statusCode == 200) {
        print('success');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getToken() async {
    String? token = await messaging.getToken();

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");

    return token!;


  }
}
