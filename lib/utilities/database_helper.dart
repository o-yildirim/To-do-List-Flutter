import 'package:flutter_app/models/notification.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/models/task.dart';


class DatabaseHelper {
  static DatabaseHelper _instance;
  static Database _database;

  String taskTable = "task_table";
  String columnId = "id";
  String columnTask = "task";
  String columnDate = "date";
  String columnPriority = "priority";


  String compTable = "comp_table";
  String compColumnId = "comp_id";
  String compColumnTask = "comp_task";
  String compColumnDate = "comp_date_of_task";
  String compColumnPriority = "comp_priority";
  String compTaskCompleteDate = "comp_complete_date";

  String notificationTable = "notif_table";
  String notifColumnId = "notif_id";
  String notifColumnTask = "notif_task";
  String notifColumnDate = "notif_date";


  DatabaseHelper.createInstance();

  factory DatabaseHelper()
  {
    if (_instance == null) {
      _instance = DatabaseHelper.createInstance();
    }
    return _instance;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  void _createDbTable(Database db, int newVersion) async
  {
    String instructionTask = 'CREATE TABLE $taskTable($columnId INTEGER PRIMARY KEY AUTOINCREMENT,$columnTask TEXT,$columnDate TEXT,$columnPriority INTEGER)';
    await db.execute(instructionTask);
    String instructionComp = 'CREATE TABLE $compTable($compColumnId INTEGER PRIMARY KEY AUTOINCREMENT,$compColumnTask TEXT,$compColumnDate TEXT,$compTaskCompleteDate TEXT,$compColumnPriority INTEGER)';
    await db.execute(instructionComp);
    String instructionNotification = 'CREATE TABLE $notificationTable($notifColumnId INTEGER PRIMARY KEY ,$notifColumnTask TEXT,$notifColumnDate TEXT)';
    await db.execute(instructionNotification);
    //db.rawQuery('DROP $notificationTable');
  }

  Future<Database> initializeDatabase() async
  {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "ToDoListFl.db";
    var taskDbReference = await openDatabase(
        path, version: 1, onCreate: _createDbTable);
    return taskDbReference;
  }

  //CRUD OPERATIONS

  //SELECT
  Future<List<Map<String, dynamic>>> getTaskMap(String order) async
  {
    Database db = await this.database;
    var result;
    if (order == "Priority") {
      result =
          db.rawQuery('SELECT * FROM $taskTable order by $columnPriority DESC');
    }
    else if (order == "Date") {
      result = db.rawQuery('SELECT * FROM $taskTable order by $columnDate ASC');
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getCompTaskMap() async
  {
    Database db = await this.database;
    var result;
    result = db.rawQuery(
        'SELECT * FROM $compTable order by $compTaskCompleteDate ASC');
    return result;
  }


  //INSERT
  Future<int> insertTask(Task task) async
  {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  Future <int> insertCompTask(Task task) async
  {
    Database db = await this.database;
    var result = await db.insert(compTable, task.toCompMap());
    return result;
  }

  Future<int> insertToNotif(UserNotification notif) async
  {
    Database db = await this.database;
    var result = await db.insert(notificationTable, notif.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async
  {
    var db = await this.database;
    var result = await db.update(
        taskTable, task.toMap(), where: '$columnId =?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(int id) async
  {
    var db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $taskTable WHERE $columnId = $id');
    return result;
  }

  Future<int> deleteCompTask(int id) async
  {
    var db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $compTable WHERE $compColumnId = $id');
    return result;
  }


  Future<int> getCount() async
  {
    Database db = await this.database;
    List<Map<String, dynamic>> map = await db.rawQuery(
        'SELECT COUNT(*) FROM $taskTable');
    int result = Sqflite.firstIntValue(map);
    return result;
  }

  Future<List<Task>> getTaskList(String order) async
  {
    var taskMapList = await getTaskMap(order);
    int taskCount = taskMapList.length;

    List<Task> taskList = List<Task>();

    for (int i = 0; i < taskCount; i++) {
      taskList.add(Task.convertMapToObject(taskMapList[i]));
    }

    return taskList;
  }

  Future<List<Task>> getCompTaskList() async
  {
    var compTaskMapList = await getCompTaskMap();
    int compTaskCount = compTaskMapList.length;

    List<Task> compTaskList = List<Task>();

    for (int i = 0; i < compTaskCount; i++) {
      compTaskList.add(Task.convertMapToCompObject(compTaskMapList[i]));
    }

    return compTaskList;
  }

  Future<int> getNextNotifId() async
  {
    Database db = await this.database;
    List<Map<String, dynamic>> map = await db.rawQuery(
        'SELECT MAX($notifColumnId) FROM $notificationTable');
    int result = Sqflite.firstIntValue(map);
    if (result == null) {
      result = 0;
    }
    else {
      result += 1;
    }
    return result;
  }

  Future<int> getNotificationId(Task task) async
  {
    var db = await this.database;

    List<Map<String, dynamic>> map = await db.query(notificationTable,where: '$notifColumnTask =? AND $notifColumnDate =?',whereArgs: [task.task,task.date]);
    int id = Sqflite.firstIntValue(map);
    return id;

  }

  /*                    FOR DEBUG PURPOSES
  Future<void> showNotifTable() async
  {
    var db = await this.database;

    List<Map> map2 = await db.rawQuery(

        'SELECT * FROM $notificationTable');

    map2.forEach((row) => print(row));
  }
  */
  Future<void> deleteNotif(int id) async
  {
    var db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $notificationTable WHERE $notifColumnId = $id OR $notifColumnId = $id-1');
    return result;
  }

  Future<void> clearNotifTable()  async
  {
  var db = await this.database;
  var result = await db.rawDelete(
  'DELETE FROM $notificationTable');
  return result;
  }

  Future<void> updateNotif(UserNotification userNotification) async
  {
    var db = await this.database;
    await db.update(
        notificationTable, userNotification.toMap(), where: '$notifColumnId =?', whereArgs: [userNotification.id]);
  }
}


