// import 'dart:io';
// import 'dart:math';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:legal_log/features/notifications/message.dart';
// import 'package:path_provider/path_provider.dart';
// class NotificationServices {

//   //initialising firebase message plugin
//   FirebaseMessaging messaging = FirebaseMessaging.instance ;

//   //initialising firebase message plugin
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

//   //function to initialise flutter local notification plugin to show notifications for android when app is active
//   void initLocalNotifications(BuildContext context, RemoteMessage message)async{
//     var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iosInitializationSettings = const DarwinInitializationSettings();

//     var initializationSetting = InitializationSettings(
//         android: androidInitializationSettings ,
//         iOS: iosInitializationSettings
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//         initializationSetting,
//       onDidReceiveNotificationResponse: (payload){
//           // handle interaction when app is active for android
//           handleMessage(context, message);
//       }
//     );
//   }

//   void firebaseInit(BuildContext context){

//     FirebaseMessaging.onMessage.listen((message) {

//       RemoteNotification? notification = message.notification ;
//       AndroidNotification? android = message.notification!.android ;

//       if (kDebugMode) {
//         print("notifications title:${notification!.title}");
//         print("notifications body:${notification.body}");
//         print('count:${android!.count}');
//         print('data:${message.data.toString()}');
//       }

//       if(Platform.isIOS){
//         forgroundMessage();
//       }

//       if(Platform.isAndroid){
//         initLocalNotifications(context, message);
//         showNotification(message);
//       }
//     });
//   }


//   void requestNotificationPermission() async {
//     NotificationSettings settings = await messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true ,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       if (kDebugMode) {
//         print('user granted permission');
//       }
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       if (kDebugMode) {
//         print('user granted provisional permission');
//       }
//     } else {
//       //appsetting.AppSettings.openNotificationSettings();
//       if (kDebugMode) {
//         print('user denied permission');
//       }
//     }
//   }

//   // function to show visible notification when app is active
//   Future<void> showNotification(RemoteMessage message)async{

//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//         message.notification!.android!.channelId.toString(),
//       message.notification!.android!.channelId.toString() ,
//       importance: Importance.max  ,
//       showBadge: true ,
//       playSound: true,
//       sound: const RawResourceAndroidNotificationSound('sound')
//     );

//      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       channel.id.toString(),
//       channel.name.toString() ,
//       channelDescription: 'your channel description',
//       importance: Importance.high,
//       priority: Priority.high ,
//       playSound: true,
//       ticker: 'ticker' ,
//          sound: channel.sound
//     //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
//     //  icon: largeIconPath
//     );

//     const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
//       presentAlert: true ,
//       presentBadge: true ,
//       presentSound: true
//     ) ;

//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: darwinNotificationDetails
//     );

//     Future.delayed(Duration.zero , (){
//       _flutterLocalNotificationsPlugin.show(
//           message.hashCode, // Unique ID for the notification
//           message.notification!.title.toString(),
//           message.notification!.body.toString(),
//           notificationDetails ,
//       );
//     });

//   }

//   //function to get device token on which we will send the notifications
//   Future<String> getDeviceToken() async {
//     String? token = await messaging.getToken();
//     print("FCM Token: $token");
//     return token!;
//   }

//   void isTokenRefresh()async{
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//       if (kDebugMode) {
//         print('refresh');
//       }
//     });
//   }

//   //handle tap on notification when app is in background or terminated
//   Future<void> setupInteractMessage(BuildContext context)async{

//     // when app is terminated
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

//     if(initialMessage != null){
//       handleMessage(context, initialMessage);
//     }


//     //when app ins background
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       handleMessage(context, event);
//     });

//   }

//   void handleMessage(BuildContext context, RemoteMessage message) {

//     if(message.data['type'] =='msj'){
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => MessageScreen(
//             id: message.data['id'] ,
//           )));
//     }
//   }


//   Future forgroundMessage() async {
//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }


// }




import 'dart:io';
import 'dart:math';
import 'package:cron/cron.dart';  // Importing cron package
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:legal_log/features/notifications/message.dart';
import 'package:path_provider/path_provider.dart';

class NotificationServices {

  // Initializing firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initializing firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();
  
  // Initializing cron scheduler
  final cron = Cron();

  // Function to initialize flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
      onDidReceiveNotificationResponse: (payload) {
          // Handle interaction when app is active for android
          handleMessage(context, message);
      }
    );
  }

  // Firebase Initialization for handling messages
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("Notifications title: ${notification!.title}");
        print("Notifications body: ${notification.body}");
        print('Count: ${android!.count}');
        print('Data: ${message.data.toString()}');
      }

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  // Requesting notification permissions
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User denied permission');
      }
    }
  }

  // Function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('sound')
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      sound: channel.sound,
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        message.hashCode, // Unique ID for the notification
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  // Function to get device token on which we will send notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    return token!;
  }

  // Function for handling token refresh
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('Token refreshed');
      }
    });
  }

  // Handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // When app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    // When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  // Handle message navigation
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msj') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MessageScreen(
            id: message.data['id'],
          )));
    }
  }

  // Set foreground notification options for iOS
  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Function to schedule notifications daily at 9 AM
  void scheduleDailyNotification() {
    cron.schedule(Schedule.parse('54 7 * * *'), () async {
      // This will run every day at 9 AM

      // Example: Send a local notification at 9 AM
      await showNotification(
        RemoteMessage(
          notification: RemoteNotification(
            title: 'Daily Reminder',
            body: 'This is your daily 9 AM reminder!',
            android: AndroidNotification(channelId: '1'),
          ),
        ),
      );
    });
  }

  // Initialize Firebase and Cron scheduler
  void initialize(BuildContext context) {
    requestNotificationPermission();

    // Initialize local notifications
    initLocalNotifications(context, RemoteMessage(notification: RemoteNotification()));

    // Start cron scheduler
    scheduleDailyNotification();
  }
}
