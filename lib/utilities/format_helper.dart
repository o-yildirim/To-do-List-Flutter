import 'package:intl/intl.dart';

class FormatHelper
{
  static FormatHelper formatHelper = new FormatHelper();

  String convertUsDateForOrder(String date)
  {
    DateTime parsedDate = DateFormat('d MMMM y HH:mm','en_US').parse(date);
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
    return formattedDate;
  }

  String convertDbDateForUS(String date)
  {
    DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm').parse(date);
    String formattedDate = DateFormat('d MMMM y HH:mm','en_US').format(parsedDate);
    return formattedDate;
  }


  String getHourFromDbDate(String date)
  {
      DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm').parse(date);
      String hour = DateFormat('HH:mm').format(parsedDate);
      return hour;
  }

  String getHourFromUSDate(String date)
  {
    DateTime parsedDate = DateFormat('d MMMM y','en_US').parse(date);
    String hour = DateFormat('HH:mm').format(parsedDate);
    return hour;
  }

  String getCurrentDateInUS()
  {
    DateTime now =  DateTime.now();
    DateFormat formatter = new DateFormat('d MMMM y','en_US');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  String getCurrentHour()
  {
    DateTime now = DateTime.now();
    String currentHour = DateFormat('HH:mm').format(now);
    return currentHour;
  }

  String getDMYFromUSDate(String dateWithHour)
  {
    DateTime dt = DateFormat('d MMMM y HH:mm').parse(dateWithHour);
    String dateWithDMY = DateFormat('d MMMM y').format(dt);
    return dateWithDMY;
  }


}