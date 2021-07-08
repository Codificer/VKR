import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class User{
  String tn;
  String name;
  String place;
  String placeID;
  bool ruler;

  User({this.tn,this.name,this.place, this.ruler,this.placeID});

  factory User.fromJson(Map<String, dynamic> json) {
      return User(
      tn: json['tn'] as String,
      name: json['name'] as String,
      place: json['place'] as String,
      ruler: ((json['ruler'] as String)=='1')?true:false,
      placeID: json['placeid'] as String);
  }
  factory User.fromSettings(SharedPreferences prefs){
    return User(
      name: prefs.getString('FIO'),
      tn: prefs.getString('TN'),
      place: prefs.getString('Place'),
      ruler:prefs.getBool('Ruler'),
      placeID: prefs.getString('PlaceID')
    );
  }
}


class Plans{
  int number;
  String dbName;
  String strName;
  int num_count;
  
  Plans ({this.number, this.dbName, this.strName, this.num_count});

  static List<Plans> getPlans(){
    return <Plans>[
      Plans(dbName: "sim", strName: "SIM",num_count: 3, number: 0),
      Plans(dbName: "mnp", strName: "MNP",num_count: 3, number: 1),
      Plans(dbName: "lk", strName: "ЛК",num_count: 3, number: 2),
      Plans(dbName: "tvo", strName: "ТВО",num_count: 8, number: 3),
      Plans(dbName: "aks", strName: "Аксы",num_count: 8, number: 4),
      Plans(dbName: "fin", strName: "ФИН",num_count: 8, number: 5),
      Plans(dbName: "nastr", strName: "Настройки",num_count: 8, number: 6),
      Plans(dbName: "strah", strName: "Страховки",num_count: 8, number: 7),
      Plans(dbName: "credit", strName: "Кредиты",num_count: 8, number: 8),
      Plans(dbName: "focus", strName: "ФО",num_count: 8, number: 9),
    ];
  }
}

//=========================
//==============
//=========================

class UserTask{//класс, содержащий табельный и фио
  String tn;
  String name;
  UserTask({this.tn,this.name});
  factory UserTask.fromJson(Map<String,dynamic> json){
    return UserTask(
      tn: json['tn'] as String,
      name: json['name'] as String
    );
  }
}

class Task{
  String id,tn, starter, name,what,how,why,photo_link;
  String time;
  DateTime date;
  bool need_photo, finished, returned,readed;

  Task({this.id,this.tn,this.starter,this.name,this.what,this.how,this.why,this.photo_link,this.time,this.date,this.need_photo,this.finished,this.returned,this.readed});

  factory Task.fromJson(Map<String,dynamic> json){
    var _timeN=DateTime.now();
    var _time=DateTime.parse(json['time'] as String);
    String _timeS="";
    if((_time.year==_timeN.year)&&(_time.month==_timeN.month)&&(_time.day==_timeN.day)){
      _timeS="Сегодня\n${_time.hour}:${(_time.minute.toInt()==0)?'00':_time.minute}";
    }else{
      _timeS="${_time.day}.${(_time.month.toInt()<10)?('0'+_time.month.toString()):_time.month}\n${_time.hour}:${(_time.minute.toInt()==0)?'00':_time.minute}";
    }

    return Task(
      id:json['task_id'] as String,
      tn: json['tn'] as String,
      starter: json['starter'] as String,
      name: json['name'] as String,
      what: json['what'] as String,
      how: json['how'] as String,
      why: json['why'] as String,
      photo_link: json['photo_link'] as String,
      time: _timeS,
      date:_time,
      need_photo: ((json['need_photo'] as String)=='1')?true:false,
      finished: ((json['finished'] as String)=='1')?true:false,
      returned: ((json['returned'] as String)=='1')?true:false,
      readed: ((json['readed'] as String)=='1')?true:false,
    );
  }

}

//===================================
//График
//===================================

class UserSheduleDay{
  String time_begin;
  String time_end;
  bool weekend;
  bool nn;
  String name, tn;

  UserSheduleDay({this.time_begin,this.time_end,this.weekend,this.nn,this.name, this.tn});

  factory UserSheduleDay.fromJson(Map<String, dynamic> json){
    return UserSheduleDay(
      time_begin: json['time_begin'] as String,
      time_end: json['time_end'] as String,
      weekend: int.parse(json['weekend'] as String)==1? true:false,
      nn: int.parse(json['nn'] as String)==1? true:false,
      name: json['name'] as String,
      tn: json['tn'] as String
    );
  }

  factory UserSheduleDay.fromUserTask(UserTask users){
    return UserSheduleDay(
      name: users.name,
      tn: users.tn,
      time_begin: '0',
      time_end: '0',
      nn:true,
      weekend: false
    );
  }
}