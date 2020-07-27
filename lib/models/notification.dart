
class UserNotification
{
  int _id;
  String _task;
  String _notifDate;

  UserNotification(this._id,this._task,this._notifDate);


  int get id => _id;
  String get task => _task;
  String get notifDate => _notifDate;

  set task(String enteredTask)
  {
    this._task = enteredTask;
  }

  set notifDate(String enteredDate)
  {
    this.notifDate = enteredDate;
  }


  Map<String,dynamic> toMap()
  {
    var map = Map<String,dynamic>();
    if(id!=null)
    {
      map["notif_id"] = _id;
    }
    map["notif_task"] = _task;
    map["notif_date"] = _notifDate;

    return map;
  }




  convertMapToObject(Map<String,dynamic>map)
  {
    this._id = map["notif_id"];
    this._task = map["notif_task"];
    this._notifDate = map["notif_date"];
  }



}