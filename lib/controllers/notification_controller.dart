import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/get_service_key.dart';

class NotificationController extends GetxController {
  DatabaseReference? _databaseRef;
  
  DatabaseReference? get databaseRef {
    if (_databaseRef == null) {
      try {
        if (Firebase.apps.isNotEmpty) {
          _databaseRef = FirebaseDatabase.instance.ref();
        }
      } catch (e) {
        print('Firebase not initialized: $e');
      }
    }
    return _databaseRef;
  }

  final RxBool isSending = false.obs;
  final RxString statusMessage = ''.obs;

  /// Get service account key token
  /// For web platform, this requires Firebase Cloud Functions or manual server key input
  Future<String> getServiceKeyToken() async {
    try {
      final getServiceKey = GetServiceKey();
      return await getServiceKey.getServiceKeyToken();
    } catch (e) {
      print('Error retrieving access token: $e');
      return '';
    }
  }

  /// Send notification to all users
  Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
    String? subjectName,
    String? topicId,
  }) async {
    if (databaseRef == null) {
      statusMessage.value = 'Firebase not initialized';
      return;
    }

    try {
      isSending.value = true;
      statusMessage.value = 'Preparing notification...';

      // Get all user FCM tokens
      final usersSnapshot = await databaseRef!.child('users').get();
      
      if (!usersSnapshot.exists) {
        statusMessage.value = 'No users found';
        isSending.value = false;
        return;
      }

      final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null || usersData.isEmpty) {
        statusMessage.value = 'No users found';
        isSending.value = false;
        return;
      }

      final totalUsers = usersData.length;

      // Prepare notification data
      final notificationData = {
        'type': 'new_subject_paper',
        'title': title,
        'body': body,
        if (subjectName != null) 'subjectName': subjectName,
        if (topicId != null) 'topicId': topicId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };


      // Get service key token (for mobile/desktop)
      statusMessage.value = 'Getting authentication token...';
      final serverKey = await getServiceKeyToken();
      
      if (serverKey.isEmpty) {
        statusMessage.value = 'Failed to get authentication token. Saving to database only.';
        // Still save to database
        await databaseRef!.child('adminNotifications').push().set({
          'title': title,
          'body': body,
          'subjectName': subjectName,
          'topicId': topicId,
          'sentAt': DateTime.now().millisecondsSinceEpoch,
          'totalUsers': totalUsers,
          'successCount': 0,
          'failCount': totalUsers,
          'note': 'FCM token not available',
        });
        isSending.value = false;
        return;
      }

      // Send notification to each user
      int successCount = 0;
      int failCount = 0;

      statusMessage.value = 'Sending notifications to $totalUsers users...';

      for (var entry in usersData.entries) {
        final userData = entry.value;
        if (userData is Map) {
          final fcmToken = userData['fcmToken']?.toString();
          
          if (fcmToken != null && fcmToken.isNotEmpty) {
            try {
              await _sendSingleNotification(
                token: fcmToken,
                title: title,
                body: body,
                data: notificationData,
                serverKey: serverKey,
              );
              successCount++;
            } catch (e) {
              print('Error sending to user ${entry.key}: $e');
              failCount++;
            }
          } else {
            failCount++;
          }
        }
      }

      // Save notification to database
      await databaseRef!.child('adminNotifications').push().set({
        'title': title,
        'body': body,
        'subjectName': subjectName,
        'topicId': topicId,
        'sentAt': DateTime.now().millisecondsSinceEpoch,
        'totalUsers': totalUsers,
        'successCount': successCount,
        'failCount': failCount,
      });

      statusMessage.value = 'Notification sent! Success: $successCount, Failed: $failCount';
      
    } catch (e) {
      print('Error sending notifications: $e');
      statusMessage.value = 'Error: ${e.toString()}';
    } finally {
      isSending.value = false;
    }
  }

  /// Send single notification
  Future<void> _sendSingleNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String serverKey,
  }) async {
    final url = "https://fcm.googleapis.com/v1/projects/afn-test/messages:send";

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    final message = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title},
        "data": data.map((key, value) => MapEntry(key, value.toString())),
        "android": {
          "priority": "high",
          "notification": {
            "channel_id": "high_importance_channel",
            "sound": "default",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
          }
        },
        "apns": {
          "headers": {
            "apns-priority": "10",
          },
          "payload": {
            "aps": {
              "sound": "default",
              "badge": 1,
            }
          }
        }
      }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send: ${response.body}');
    }
  }
}

