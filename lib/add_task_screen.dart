import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/models/task.dart';
import 'package:flutter_app/utilities/database_helper.dart';
import 'package:flutter_app/utilities/format_helper.dart';


class AddTask extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateOfTask();
  }
}

class _StateOfTask extends State<AddTask> {
  var _formValidationKey = new GlobalKey<FormState>();
  TextEditingController taskController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController hourController = new TextEditingController();
  var priorities = ["Low", "Medium", "High"];
  var currentPriority = "";
  DatabaseHelper databaseHelper = DatabaseHelper();
  FormatHelper formatHelper = FormatHelper();

  @override
  void initState() {
    super.initState();
    dateController.text = FormatHelper.formatHelper.getCurrentDateInUS();
    hourController.text = FormatHelper.formatHelper.getCurrentHour();
    currentPriority = priorities[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add task", textAlign: TextAlign.center),
      ),
      body: getAddTaskPanel(),
    );
  }

  Widget getAddTaskPanel() {
    return Form(
        key: _formValidationKey,
        child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                      child: Row(children: <Widget>[
                        Text("Priority:\t",
                            style: TextStyle(color: Colors.deepOrangeAccent)),
                        DropdownButton<String>(
                          value: currentPriority,
                          hint: Text("Priority"),
                          items: priorities.map((String priorityItem) {
                            return DropdownMenuItem<String>(
                              value: priorityItem,
                              child: Text(priorityItem),
                            );
                          }).toList(),
                          onChanged: (String prioritySelected) {
                            setState(() {
                              currentPriority = prioritySelected;
                            });
                          },
                        ),
                        CircleAvatar(
                          child: Icon(Icons.event_note),
                          backgroundColor: getPriorityColor(currentPriority),
                        )
                      ])),
                ),
                Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      autofocus: true,
                        controller: taskController,
                        // ignore: missing_return
                        validator: (String taskInput) {
                          if (taskInput.isEmpty) {
                            return "Please enter a task";
                          }
                        },
                        decoration: new InputDecoration(
                            hintText: "Attend meeting",
                            labelText: "Task",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))))),
                Row(children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: 15.0, left: 10.0, right: 10.0),
                          child: TextField(
                              readOnly: true,
                              controller: dateController,
                              onTap: () async {
                                await displayDatePicker(context);
                              },
                              decoration: new InputDecoration(
                                  labelText: "Date",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0)))))),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: 15.0, left: 10.0, right: 10.0),
                          child: TextField(
                              readOnly: true,
                              onTap: () async {
                               await displayTimePicker(context);
                              },
                              controller: hourController,
                              decoration: new InputDecoration(
                                  labelText: "Hour",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))))))
                ]),
                Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                                child: Text(
                                  "Add",
                                  textScaleFactor: 1.5,
                                ),
                                elevation: 3.0,
                                onPressed: () {
                                  if (_formValidationKey.currentState
                                      .validate()) {
                                    Task taskToAdd = createTaskToAdd();
                                    saveTaskToDatabase(taskToAdd);
                                  }
                                })),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                            child: RaisedButton(
                                child: Text(
                                  "Reset",
                                  textScaleFactor: 1.5,
                                ),
                                elevation: 3.0,
                                onPressed: () {
                                  resetFields();
                                }))
                      ],
                    ))
              ],
            )));
  }

  Task createTaskToAdd() {
    String toDoTask = taskController.text;
    int priority = getPriorityAsInt(currentPriority);

    String date = dateController.text + " " + hourController.text;
    date = formatHelper.convertUsDateForOrder(date);

    Task task = new Task(toDoTask, date, priority);

    return task;
  }

  void resetFields() {
    taskController.text = "";
    dateController.text = "";
    hourController.text = "";
  }

  int getPriorityAsInt(String value) {
    switch (value) {
      case "Low":
        return 1;
        break;

      case "Medium":
        return 2;
        break;

      case "High":
        return 3;

      default:
        return 1;
    }
  }

  void saveTaskToDatabase(Task task) async {
    moveToLastScreen();
    int result = await databaseHelper.insertTask(task);
    if (result != 0) {
      _showAlertDialog("Status", "Task is successfully added. ");
    } else {
      _showAlertDialog("Status", "Failed to add task.");
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Future<void> displayDatePicker(BuildContext context) async{
    DatePicker.showDatePicker(context,
        onMonthChangeStartWithFirstDate: true,
        dateFormat: "d MMMM y",
        initialDateTime: DateTime.now(),
        minDateTime: DateTime.now(),
        maxDateTime: DateTime(DateTime.now().year+1),
        onConfirm: (date, list) {
      setState(() {
        String formattedDate = DateFormat('d MMMM y', 'en_US').format(date);
        dateController.text = formattedDate;
      });
    },
        );
  }

  Future<void> displayTimePicker(BuildContext context) async {
       DatePicker.showDatePicker(context,
        dateFormat: 'HH:mm',
        initialDateTime: DateFormat('HH:mm').parse(hourController.text),
        minDateTime: getMinHourByDate(),
        onConfirm: (hour, list) {
      setState(() {
        String formattedHour = DateFormat('HH:mm').format(hour);
        hourController.text = formattedHour;
      });
    });
  }

  getPriorityColor(String currentPriority) {
    switch (currentPriority) {
      case "Low":
        return Colors.green;
        break;
      case "Medium":
        return Colors.yellow;
        break;
      case "High":
        return Colors.red;
    }
  }

  DateTime getMinHourByDate()
  {
    DateTime selectedDate = DateFormat('d MMMM y', 'en_US').parse(dateController.text);
    if(selectedDate.isBefore(DateTime.now()))
    {
      return DateTime.now();
    }
    return null;
  }
}
