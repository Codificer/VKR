import 'connection.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'user.dart';
import 'connection.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

    final _tnController = TextEditingController();
    final _smsController = TextEditingController();
    bool _smsVisible=false;

  @override
  Widget build(BuildContext context) {
    String _tn='';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child:Column(
                children:<Widget>[
                  Container(//ввод табельного номера
                    child:TextField(
                      controller: _tnController,
                      decoration: InputDecoration(
                        border:OutlineInputBorder(),
                        labelText:'Табельный номер',
                      ),
                      keyboardType: TextInputType.number,
                    )
                  ),
                  Visibility(//поле ввода смс кода
                    visible: _smsVisible,
                    child:TextField(
                      controller: _smsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'код из SMS-сообщения',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        child: const Text('Запросить СМС'), 
                        onPressed: (){
                          setState(() {
                            _smsVisible = true;
                          });
                        },
                      ),

                      FlatButton(
                        color:Colors.green.shade400,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.blueAccent,    
                        child: const Text('Войти'),     
                        onPressed: () async {             
                          _tn=_tnController.text;             
                            //проверка совпадения отправляемого кода и введеного
                          if(_tn.isNotEmpty){
                            if(_tn.length==8){
                              String querry="select concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name, worker.tn as tn, place.place_name as place, position.ruler as ruler, place.place_id as placeid from worker, position, place, place_of_work where worker.position_id=position.position_id and place.place_id=place_of_work.place_id and worker.tn=place_of_work.tn and worker.tn=$_tn;";
                              
                              var jsonData=await Utility.getData(querry) ?? 1;
                              if(jsonData==1)
                              {
                                print('error');
                              }
                              else{
                                user= User.fromJson(jsonData[0]);
                                printUser();
                                Utility.addSavedSettings(user.tn, user.ruler,user.name,user.place,user.placeID);
                                Navigator.pushReplacementNamed(context, '/main');                                
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
