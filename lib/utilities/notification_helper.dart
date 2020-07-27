import 'package:flutter/material.dart';
import 'package:flutter_app/models/task.dart';
import'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import'database_helper.dart';
import 'package:flutter_app/models/notification.dart';

class NotificationHelper
{

  static NotificationHelper notificationHelper = new NotificationHelper();
  DatabaseHelper databaseHelper = DatabaseHelper();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;



  void init()
  {
    initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings();
    initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }




  Future<void> scheduleNotification(Task task) async
  {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('channel_ID',
        'channel_name',
        'channel_description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker:'test_ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics,iOSChannelSpecifics);


    int differenceBetweenNotifications = 30;

    DateTime scheduleDate = DateFormat('yyyy-MM-dd HH:mm').parse(task.date);

    String firstNotifDate = DateFormat('yyyy-MM-dd HH:mm').format(scheduleDate.subtract(Duration(minutes:differenceBetweenNotifications)));
    String secondNotifDate = task.date;

    int id = await databaseHelper.getNextNotifId();
    UserNotification notif = new UserNotification(id,task.task,firstNotifDate);


    await flutterLocalNotificationsPlugin.schedule(
      id, //id
      "Upcoming task", //title
      "You have an upcoming task in 30 minutes!", //body
      scheduleDate.subtract(Duration(minutes: differenceBetweenNotifications)), //date
      platformChannelSpecifics,
      payload: task.task,
      androidAllowWhileIdle :true,
    );
    await databaseHelper.insertToNotif(notif);


    id = await databaseHelper.getNextNotifId();
    notif = new UserNotification(id, task.task,secondNotifDate);
    await flutterLocalNotificationsPlugin.schedule(
        id, //id
        "Upcoming task", //title
        "You have a task to do right now!", //body
        scheduleDate, //date
        platformChannelSpecifics,
        payload: task.task,
        androidAllowWhileIdle :true,
        );
    await databaseHelper.insertToNotif(notif);


  }

  Future<void> removeNotifications(Task task) async
  {

    int id = await databaseHelper.getNotificationId(task);

    flutterLocalNotificationsPlugin.cancel(id);
    flutterLocalNotificationsPlugin.cancel(id-1);
    databaseHelper.deleteNotif(id);


  }

  Future<void> updateNotif(Task editedTask,Task oldTask) async
  {
    int notifId = await databaseHelper.getNotificationId(oldTask);
    //debugPrint("Notif id = " + notifId.toString()+ "\n Edited task: " + editedTask.task + ".\n Old task: " + oldTask.task);

    flutterLocalNotificationsPlugin.cancel(notifId);
    flutterLocalNotificationsPlugin.cancel(notifId-1);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('channel_ID',
        'channel_name',
        'channel_description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker:'test_ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics,iOSChannelSpecifics);




    int differenceBetweenNotifications = 30;
    DateTime scheduleDate = DateFormat('yyyy-MM-dd HH:mm').parse(editedTask.date);
    String firstNotifDate = DateFormat('yyyy-MM-dd HH:mm').format(scheduleDate.subtract(Duration(minutes:differenceBetweenNotifications)));
    String secondNotifDate = editedTask.date;


    UserNotification userNotif = new UserNotification(notifId-1, editedTask.task, firstNotifDate);
    await databaseHelper.updateNotif(userNotif);

    userNotif = new UserNotification(notifId, editedTask.task, secondNotifDate);
    await databaseHelper.updateNotif(userNotif);


    await flutterLocalNotificationsPlugin.schedule(
      notifId-1, //id
      "Upcoming task", //title
      "You have an upcoming task in 30 minutes!", //body
      scheduleDate.subtract(Duration(minutes: differenceBetweenNotifications)), //date
      platformChannelSpecifics,
      payload: editedTask.task,
      androidAllowWhileIdle :true,
    );


    await flutterLocalNotificationsPlugin.schedule(
      notifId, //id
      "Upcoming task", //title
      "You have a task to do right now!", //body
      scheduleDate, //date
      platformChannelSpecifics,
      payload: editedTask.task,
      androidAllowWhileIdle :true,
    );



  }

  Future<void> cancelAllNotifications()
  {
    flutterLocalNotificationsPlugin.cancelAll();
  }

}




