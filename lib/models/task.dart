import 'package:flutter_app/utilities/format_helper.dart';
import 'package:intl/intl.dart';

class Task
{
  int _id;
  String _task;
  String _date;
  int _priority;

  Task(this._task,this._date,this._priority);
  Task.withId(this._id,this._task,this._date,this._priority);

  int get id => _id;
  String get task => _task;
  String get date => _date;
  int get priority => _priority;

  set task(String enteredTask)
  {
    this._task = enteredTask;
  }

  set date(String enteredDate)
  {
    this._date = enteredDate;
  }


  set priority(int newPriority)
  {
    this._priority = newPriority;
  }

  Map<String,dynamic> toMap()
  {
    var map = Map<String,dynamic>();
    if(id!=null)
    {
      map["id"] = _id;
    }
    map["task"] = _task;
    map["date"] = _date;
    map["priority"] = _priority;

    return map;
  }

  Map<String,dynamic> toCompMap()
  {
    var map = Map<String,dynamic>();
    if(id!=null)
    {
      map["comp_id"] = _id;
    }
    map["comp_task"] = _task;
    map["comp_date_of_task"] = _date;
    map["comp_priority"] = _priority;

    DateFormat df = DateFormat('yyyy-MM-dd HH:mm');
    map["comp_complete_date"] = df.format(DateTime.now());
    return map;


  }


  Task.convertMapToObject(Map<String,dynamic>map)
  {
    this._id = map["id"];
    this._task = map["task"];
    this._date = map["date"];
    this._priority = map["priority"];
  }


  Task.convertMapToCompObject(Map<String,dynamic>map)
  {
    this._id = map["comp_id"];
    this._task = map["comp_task"];
    this._date = FormatHelper.formatHelper.convertDbDateForUS(map["comp_date_of_task"])+ "\nComplete date: " + FormatHelper.formatHelper.convertDbDateForUS(map["comp_complete_date"])  ;
    this._priority = map["comp_priority"];
  }

}