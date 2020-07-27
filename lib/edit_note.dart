import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/format_helper.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/models/task.dart';
import 'package:flutter_app/utilities/database_helper.dart';
import 'package:flutter_app/utilities/notification_helper.dart';

class NoteDetail extends StatefulWidget {

  final Task task;

  NoteDetail(this.task);

  @override
  State<StatefulWidget> createState() {
    return EditNoteState(this.task);
  }
}

class EditNoteState extends State<NoteDetail> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  NotificationHelper notificationHelper = NotificationHelper();

  var _formValidationKey = new GlobalKey<FormState>();

  var priorities = ["Low", "Medium", "High"];
  TextEditingController taskController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hourController = TextEditingController();
  var currentPriority;

  FormatHelper formatHelper = FormatHelper();

  Task task;
  Task oldTask;

  EditNoteState(this.task);

  @override
  void initState()
  {
    super.initState();

    oldTask= new Task(task.task,task.date,task.priority);

    taskController.text = task.task;

    String fullDate = formatHelper.convertDbDateForUS(task.date);

    dateController.text = formatHelper.getDMYFromUSDate(fullDate);
    hourController.text = formatHelper.getHourFromDbDate(task.date);
    currentPriority = getPriorityAsString(task.priority);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit task"),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child:Form(
                key: _formValidationKey,
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
                        ), CircleAvatar(
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
                        // ignore: missing_return
                        validator: (String taskInput) {
                          if (taskInput.isEmpty) {
                            return "Please enter a task";
                          }
                        },
                        controller: taskController,
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
                              onTap: () async {
                                await displayDatePicker(context);
                              },
                              controller: dateController,
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
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                                  hintText: "15:00",
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
                                  "Edit",
                                  textScaleFactor: 1.5,
                                ),
                                elevation: 3.0,
                                onPressed: () {
                                  if (_formValidationKey.currentState
                                      .validate()) {
                                    assignNewValuesToTask();
                                    updateOnDatabase();
                                  }
                                }

                            )),
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
            ))));
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case "Low":
        task.priority = 1;
        break;
      case "Medium":
        task.priority = 2;
        break;
      case "High":
        task.priority = 3;
    }
  }

  String getPriorityAsString(int value) {
    switch (value) {
      case 1:
        currentPriority = priorities[0]; //low
        break;
      case 2:
        currentPriority = priorities[1]; //medium
        break;
      case 3:
        currentPriority = priorities[2]; //high
    }

    return currentPriority;
  }

  void assignNewValuesToTask() {



    updatePriorityAsInt(currentPriority);
    task.task = taskController.text;
    task.date = dateController.text + " " + hourController.text;
    task.date = formatHelper.convertUsDateForOrder(task.date);
  }

  void updateOnDatabase() async
  {
    moveToLastScreen();

    int result = await databaseHelper.updateTask(task);

    if (result != 0) {
      _showAlertDialog("Status", "Task is successfully edited.");
      notificationHelper.updateNotif(task,oldTask);
    } else {
      _showAlertDialog("Status", "Failed to edit task.");
    }
  }

  void resetFields() {
    taskController.text = "";
    dateController.text = "";
    hourController.text = "";
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Future<void> displayDatePicker(BuildContext context) async {
    DatePicker.showDatePicker(context,
      onMonthChangeStartWithFirstDate: true,
      dateFormat: 'd MMMM y',
      minDateTime: DateTime.now(),
      maxDateTime: DateTime(DateTime
          .now()
          .year + 1),
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

  DateTime getMinHourByDate() {
    DateTime selectedDate = DateFormat('d MMMM y', 'en_US').parse(
        dateController.text);
    if (selectedDate.isBefore(DateTime.now())) {
      return DateTime.now();
    }
    return null;
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

}
