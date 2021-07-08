import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'main.dart';
import 'user.dart';
import 'login.dart';
import 'main_u.dart';

class Utility {


  static getData(String querry) async{
    print("строка запроса: $querry");
    var _client = new HttpClient();
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    var url = 'http://f0408504.xsph.ru/get.php';
    http.Response response = await http.post(url, body:{"querry" : querry});
    if(response.statusCode==200){
      if(response.body.length<=2){
        return null;
        }
      else{
        var jsondecoded=jsonDecode(response.body);
        return jsondecoded;
        }
    }  
  }


  static month(int m){
    switch(m){
      case 1:return "января";
      case 2:return "февраля";
      case 3:return "марта";
      case 4:return "апреля";
      case 5:return "мая";
      case 6:return "июня";
      case 7:return "июля";
      case 8:return "августа";
      case 9:return "сентября";
      case 10:return "октября";
      case 11:return "ноября";
      case 12:return "декабря";
    }
  }
  static monthName(int m){
    switch(m){
      case 1:return "Январь";
      case 2:return "Февраль";
      case 3:return "Март";
      case 4:return "Апрель";
      case 5:return "Май";
      case 6:return "Июнь";
      case 7:return "Июль";
      case 8:return "Август";
      case 9:return "Сентябрь";
      case 10:return "Октябрь";
      case 11:return "Ноябрь";
      case 12:return "Декабрь";
    }
  }
  static monthDaysCount(int m,int y){
    switch(m){
      case 1:return 31;
      case 2:return y%4==0?29:28;
      case 3:return 31;
      case 4:return 30;
      case 5:return 31;
      case 6:return 30;
      case 7:return 31;
      case 8:return 31;
      case 9:return 30;
      case 10:return 31;
      case 11:return 30;
      case 12:return 31;
    }
  }
  static dayOfWeek(DateTime date){
    switch(date.weekday){
      case 1:return "Пн, ${date.day}.${(date.month<10)?'0':''}${date.month}";
      case 2:return "Вт, ${date.day}.${(date.month<10)?'0':''}${date.month} ";
      case 3:return "Ср, ${date.day}.${(date.month<10)?'0':''}${date.month}";
      case 4:return "Чт, ${date.day}.${(date.month<10)?'0':''}${date.month}";
      case 5:return "Пт, ${date.day}.${(date.month<10)?'0':''}${date.month}";
      case 6:return "Сб, ${date.day}.${(date.month<10)?'0':''}${date.month}";
      case 7:return "Вс, ${date.day}.${(date.month<10)?'0':''}${date.month}";
    }
  }

  static addSavedSettings(String tn, bool ruler, String fio, String place, String placeid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('TN', tn);
    prefs.setBool('Ruler', ruler);
    prefs.setString('FIO', fio);
    prefs.setString('Place', place);
    prefs.setString('PlaceID', placeid);
  }

  //Прочесть настройки и загрузить нужную версию
  static readSavedSettings(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('TN');
    if(checkValue){
      user=User.fromSettings(prefs);
      printUser();
      Navigator.pushReplacementNamed(context, '/main');
    }
    else{
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  static removeSettings() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    pref.remove('TN');
    pref.remove('Ruler');
    pref.remove('FIO');
    pref.remove('Place');
    pref.remove('PlaceID');
  }
   
  static Widget imageFromBase64String(String base64String, BuildContext context) {
    return Flexible(
            child: InkWell(child:
              Image.memory(
              base64Decode(base64String),
              fit: BoxFit.scaleDown,
              height:200,
              ),
              onTap:(){ Navigator.push(context, MaterialPageRoute(builder: (context) =>ImagePage(image:base64String)));},
              )
          );
  }
 
  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }
 
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

}


class ImagePage extends StatelessWidget{
Task task;
String image;
ImagePage({Key key, this.task, this.image}) : super(key:key);

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
      ),
      body: Center(
        child:Image.memory(
              base64Decode(image),
              fit: BoxFit.fill,)
      )
    );
  }
}