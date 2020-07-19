import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/edit_note.dart';
import 'package:flutter_app/utilities/format_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/add_task_screen.dart';
import 'package:flutter_app/models/task.dart';
import 'package:flutter_app/utilities/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class TaskView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateOfTasks();
  }
}

class _StateOfTasks extends State<TaskView> {
  var orders = ["Priority", "Date"];

  TextEditingController taskController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController hourController = new TextEditingController();
  String selectedOrder = "";

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Task> taskList;
  int taskCount = 0;

  List<Task> compTaskList;
  int compTaskCount = 0;

  FormatHelper formatHelper = FormatHelper();

  @override
  void initState() {
    super.initState();
    hourController.text = formatHelper.getCurrentHour();
    dateController.text = formatHelper.getCurrentDateInUS();

    selectedOrder = orders[0];
  }

  @override
  Widget build(BuildContext context) {
    if (taskList == null) {
      taskList = List<Task>();
      updateTaskView(selectedOrder);
    }
    if (compTaskList == null) {
      compTaskList = List<Task>();
      updateTaskView(selectedOrder);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("To do-List", textAlign: TextAlign.center),
      ),
      body: getListView(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          navigateToAddTask(new Task('', '', 1));
        },
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }


  Widget getListView() {
    var listView = ListView.builder(
      // ignore: missing_return
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
              elevation: 2.0,
              color: Colors.orangeAccent,
              child: ListTile(
                title: Column(
                  children: <Widget>[
                    Text(
                      "Tasks",
                      textScaleFactor: 1.5,
                    ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text("Order by: ",),
                        getOrderDropdownButton(),
                      ],
                    )
                  ],
                ),
              ));

        } else if (index <= taskList.length ) {
          return Card(
              elevation: 2.0,
              color: Colors.white,
              child: ListTile(
                title: Text(taskList[index - 1].task),
                leading: CircleAvatar(
                    child: Icon(Icons.event_note),
                    backgroundColor:
                        getPriorityColor(taskList[index - 1].priority)),
                trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  GestureDetector(
                      child: Icon(Icons.check_box, color: Colors.grey),
                      onTap: () {
                        _completeTask(context, taskList[index - 1]);
                      }),
                  GestureDetector(
                    child: Icon(Icons.delete, color: Colors.grey),
                    onTap: () {
                      _deleteTask(context, taskList[index - 1]);
                    },
                  )
                ]),
                subtitle: Text(
                    FormatHelper.formatHelper
                        .convertDbDateForUS(taskList[index - 1].date),
                    style: TextStyle(
                        color: getColorForSubtitle(taskList[index - 1]))),
                // subtitle: Text(taskList[index-1].date),
                onTap: () {
                  navigateToEditTask(taskList[index - 1]);
                },
              ));
        }
        else if(index == taskList.length+1)
        {
          return Card(
              elevation: 2.0,
              color: Colors.orangeAccent,
              child: ListTile(
                title:Text(
                  "Completed",
                  textScaleFactor: 1.5,
                ),
              ));
        }
        else if(index > taskList.length+1)
          {
            return Card(
                elevation: 2.0,
                color: Colors.white,
                child: ListTile(
                  title: Text(compTaskList[index-taskList.length - 2 ].task),
                  leading: CircleAvatar(
                      child: Icon(Icons.event_note),
                      backgroundColor:
                      getPriorityColor(compTaskList[index-taskList.length - 2].priority)),
                  trailing:
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[

                    GestureDetector(
                      child: Icon(Icons.delete, color: Colors.grey),
                      onTap: () {
                        _deleteCompTask(context,compTaskList[index-taskList.length -2 ]); //DELETE FROM COMP OLACAK BU
                      },
                    )
                  ]),

              subtitle: Text(compTaskList[index-taskList.length - 2 ].date, style: TextStyle(
                  color: Colors.green)),

                ));
          }
      },

      itemCount: taskList.length + compTaskList.length + 2,
    );
    return listView;
  }





  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
        break;

      case 2:
        return Colors.yellow;
        break;

      case 3:
        return Colors.red;

      default:
        return Colors.green;
    }
  }

  void _deleteTask(BuildContext context,
      Task task) async //context snackbar için
      {
    int result = await databaseHelper.deleteTask(task.id);
    if (result != 0) {
      updateTaskView(selectedOrder);
      _showSnackBar(context, 'Task deleted.');
    }
  }

  void _deleteCompTask(BuildContext context,Task task,) async {
    int result = await databaseHelper.deleteCompTask(task.id);
    if (result != 0) {
      updateTaskView(selectedOrder);
      _showSnackBar(context, 'Task deleted from completed tasks.');
    }
  }

  void _completeTask(BuildContext context, Task task) async {
    int result;

    result = await databaseHelper.insertCompTask(task);
    if (result != 0) {
      result = await databaseHelper.deleteTask(task.id);
      if (result != 0) {
        _showSnackBar(context, 'Task completed!');
        updateTaskView(selectedOrder);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    SnackBar sb = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );
    Scaffold.of(context).showSnackBar(sb);
  }


  void updateTaskView(String order) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList(order);
      Future<List<Task>> compTaskListFuture = databaseHelper.getCompTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList;
          this.taskCount = taskList.length;
        });
        compTaskListFuture.then((compTaskList) {
          setState(() {
            this.compTaskList = compTaskList;
            this.compTaskCount = compTaskList.length;
          });
      });
    });

  });
  }


  void navigateToEditTask(Task task) async {
    bool result =
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(task);
    }));

    if (result != null) {
      updateTaskView(selectedOrder);

    }
  }

  void navigateToAddTask(Task task) async {
    bool result =
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddTask();
    }));

    if (result != null) {
      updateTaskView(selectedOrder);

    }
  }

  getOrderDropdownButton() {
    return DropdownButton<String>(
      value: selectedOrder,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      onChanged: (String newValue) {
        setState(() {
          selectedOrder = newValue;
          updateTaskView(selectedOrder);
        });
      },
      items: orders.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Color getColorForSubtitle(Task task) {
    String dateOfTask = formatHelper.convertDbDateForUS(task.date);
    DateTime parsedDate =
    DateFormat('d MMMM y HH:mm', 'en_US').parse(dateOfTask);
    DateTime now = DateTime.now();

    if (parsedDate.isBefore(now)) {
      return Colors.red;
    }
    return null;
  }
}


