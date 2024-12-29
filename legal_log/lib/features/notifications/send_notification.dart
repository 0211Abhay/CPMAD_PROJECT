import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class SendNotification extends StatefulWidget {
  const SendNotification({super.key});

  @override
  State<SendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
  final cron = Cron();

  @override
  void initState() {
    super.initState();

    // Initialize Awesome Notifications
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'Key_1',
          channelName: 'Legal Log Notifications',
          channelDescription: 'Daily Notifications for Legal Log',
          ledColor: Colors.white,
          defaultColor: const Color(0xFF9050DD),
          playSound: true,
          enableLights: true,
          enableVibration: true,
        )
      ],
    );

    // // Schedule a task to run every day at 6:00 AM
    // cron.schedule(Schedule.parse('* 9 * * *'), () async {
    //   print('Notification triggered at 6:00 AM');
    //   sendNotification();
    // });

    cron.schedule(Schedule.parse('* * * * *'), () async {
      print('Notification triggered at 6:00 AM');
      sendNotification();
    });
  }

  void sendNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1, // Unique ID for the notification
        channelKey:
            'Key_1', // Must match the channelKey defined in initialization
        title: 'Good Morning!',
        body: 'Here is your daily reminder for Legal Log!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  void dispose() {
    // Stop the cron jobs when the widget is disposed
    cron.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
