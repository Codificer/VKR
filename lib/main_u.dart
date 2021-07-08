import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'main.dart';
import 'plan.dart';
import 'task.dart';
import 'user.dart';
import 'connection.dart';
import 'schedule.dart';

class MainPageU extends StatefulWidget{
  MainPageU({Key key}):super(key:key);
  @override
  _MainPageUState createState() => _MainPageUState();
}


class _MainPageUState extends State<MainPageU> with SingleTickerProviderStateMixin{


  List <String> _tasksU;
  List <String> _tasksO;
  List <String> _plansU;
  List <String> _plansO;
  List <UserTask> _users;
  List <UserSheduleDay> _hours;
  List <int> _plansIDU=[0,3,4,5];
  List <List<int>> _plansIDO=[[0,3],[1,4],[2,5]];
  UserSheduleDay _hourU;
  DateTime _currentDay;
  bool _isPlanLoaded=true,_isSheduleLoaded=true,_isTaskLoaded=true;


  void setData()async{
    String querry="select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name from worker, place_of_work where place_of_work.tn=worker.tn and place_of_work.place_id='${user.placeID}' order by name;";

    var jsonData= await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error loading user");
      _users.add(UserTask(name: user.name, tn: user.tn));
    }else{
      _users=(jsonData as List).map((i) => UserTask.fromJson(i)).toList();
      _users.sort((a,b)=> a.name.compareTo(b.name));
    }
  }

  void setDataP() async{
    _plansU=new List<String>();
    _plansO=new List<String>();
    String querry;
    var jsonData;

    if(user.ruler){      
    querry="select ";

    plans.forEach((f)=>querry+="CEIL((sales_plan.${f.dbName}-SUM(sales_fact.${f.dbName}))/(1+${Utility.monthDaysCount(_currentDay.month, _currentDay.year)}-${_currentDay.day})) as ${f.dbName}, ");
    querry+="sales_plan.month from sales_plan,sales_fact where sales_plan.month='${_currentDay.year}-${_currentDay.month}-1' and sales_plan.place_id='${user.placeID}' and sales_plan.place_id=sales_fact.place_id and sales_fact.date<='${_currentDay.year}-${_currentDay.month}-${_currentDay.day}' and sales_fact.date>='${_currentDay.year}-${_currentDay.month}-1'";
    jsonData=await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("ërror getting plans");
      plans.forEach((f)=>_plansO.add("0"));
    }
    else{
      plans.forEach((f)=>_plansO.add(jsonData[0]['${f.dbName}'] as String));
    }
    }

    querry="select ";
    querry+=" sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_currentDay.year}-${_currentDay.month}-${_currentDay.day}' and date>='${_currentDay.year}-${_currentDay.month}-1';";     

    jsonData=await Utility.getData(querry) ?? 1;

    int i=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;

    querry="select sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_currentDay.year}-${_currentDay.month}-${_currentDay.day}' and date>='${_currentDay.year}-${_currentDay.month}-1' and tn=${user.tn};";      

    jsonData=await Utility.getData(querry) ?? 1;

    int j=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;

    double hours=j/i;

    if(hours>=1){
      querry="select COUNT(tn) as hours from place_of_work where place_id='${user.placeID}';";
      jsonData=await Utility.getData(querry) ?? 1;
      hours=jsonData[0]['hours']!=null?1/int.parse(jsonData[0]['hours'] as String):1;
    }
    querry="select ";
    plans.forEach((f)=>querry+="CEIL((sales_plan.${f.dbName}-SUM(sales_fact.${f.dbName}))/(1+${Utility.monthDaysCount(_currentDay.month, _currentDay.year)}-${_currentDay.day})) as ${f.dbName}, ");

    querry+="sales_plan.month from sales_plan,sales_fact where sales_plan.month='${_currentDay.year}-${_currentDay.month}-1' and sales_plan.place_id='${user.placeID}' and sales_plan.place_id=sales_fact.place_id and sales_fact.date<='${_currentDay.year}-${_currentDay.month}-${_currentDay.day}' and sales_fact.date>='${_currentDay.year}-${_currentDay.month}-1';";

    jsonData=await Utility.getData(querry) ?? 1;

    if(jsonData==1){
      print("plan of day error");
      plans.forEach((f)=>_plansU.add("0"));
    }else{
      plans.forEach((f)=>_plansU.add(int.parse(jsonData[0][f.dbName] as String)<0?'0':(jsonData[0][f.dbName] as String)));
    }

    if(_isPlanLoaded){setState((){_isPlanLoaded=false;});}
  }


  void setDataT() async{
    _tasksU=new List<String>();
    _tasksO=new List<String>();
    String querry;
    querry="SELECT SUM(CASE WHEN 1 THEN 1 ELSE 0 end) AS allTasks,SUM(CASE WHEN readed=0 THEN 1 ELSE 0 end) AS newTasks,SUM(CASE WHEN finished=0 AND time<'2020-3-18' THEN 1 ELSE 0 end) AS timeTask FROM tasks WHERE tn=${user.tn} AND closed=0;";
    var jsonData=await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("ërror getting tasks");
      _tasksU.add('0');
      _tasksU.add('0');
      _tasksU.add('0');
    }
    else{
      _tasksU.add(jsonData[0]['allTasks'] as String);
      _tasksU.add(jsonData[0]['newTasks'] as String);
      _tasksU.add(jsonData[0]['timeTask'] as String);
      print(_tasksU);

      _tasksU.forEach((f)=>f==null?_tasksU[_tasksU.indexOf(f)]='0':null);
    }

    if(user.ruler){

      querry="SELECT SUM(CASE WHEN 1 THEN 1 ELSE 0 end) AS allTasks,SUM(CASE WHEN finished=1 THEN 1 ELSE 0 end) AS newTasks,SUM(CASE WHEN finished=0 AND time<'2020-3-18' THEN 1 ELSE 0 end) AS timeTask FROM tasks WHERE starter=${user.tn} AND closed=0;";
      jsonData=await Utility.getData(querry) ?? 1;
      if(jsonData==1){
        print("ërror getting tasks");
        _tasksO.add('0');
        _tasksO.add('0');
        _tasksO.add('0');
      }
      else{
        _tasksO.add(jsonData[0]['allTasks'] as String);
        _tasksO.add(jsonData[0]['newTasks'] as String);
        _tasksO.add(jsonData[0]['timeTask'] as String);
      }
    }
    if(_isTaskLoaded){setState((){_isTaskLoaded=false;});}

  }



  void setDataS() async{
    _hours=new List<UserSheduleDay>();

    String querry="select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name, shedule.weekend as weekend, shedule.nn as nn, shedule.begin as time_begin, shedule.end as time_end from worker, shedule, place_of_work where place_of_work.tn=worker.tn and place_of_work.place_id='${user.placeID}' and shedule.tn=worker.tn and shedule.date='${_currentDay.year}-${_currentDay.month}-${_currentDay.day}' order by nn,weekend,name;";

    var jsonData=await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error loading day");
      _users.forEach((f)=>_hours.add(UserSheduleDay.fromUserTask(f)));
    }else{
      _hours=(jsonData as List).map((i) => UserSheduleDay.fromJson(i)).toList();
    }
    _hourU=_hours[_hours.indexWhere((test)=>test.tn==user.tn)];
    await setDataP();
    if(_isSheduleLoaded){setState((){_isSheduleLoaded=false;});}
  }


  TabController _tabController;


  void loadData()async{

    _currentDay=DateTime.now();
    await setDataS();
    await setDataT();
  }

  @override

  void initState(){
    _tabController=new TabController(length: user.ruler ? 2:1, vsync: this,initialIndex: 0);
    setData();
    loadData();
  }

  Widget build(BuildContext context){
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: user.ruler? Colors.deepPurple[400]:Colors.green[700],//цвет в зависимости от должности
        title: Text('Привет, '+ user.name , style: TextStyle(fontSize: 20.0)),
      ),
      drawer: Drawer(
        child: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              RaisedButton(
                onPressed:(){
                  Utility.removeSettings();
                },
                child:Text("Сбросить сохранения", style: TextStyle(color: Colors.white),),
                color: Colors.deepPurple,
                highlightColor: Colors.deepPurple[300],
              ),
              FlatButton( 
                onPressed:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Fact(setFacts:false)));
                },
                child:Text("Ввести планы на месяц", style: TextStyle(color: Colors.white),),
                color: Colors.deepPurple,
                highlightColor: Colors.deepPurple[300],
              )
            ]
          ),
        ),
       ),
      body:Center(
        child:RefreshIndicator(
          onRefresh:()async{
            _isPlanLoaded=true;
            _isSheduleLoaded=true;
            _isTaskLoaded=true;
            loadData();
            setState(() {});
          },
        child:ListView(
          semanticChildCount: 2,
          children:<Widget>[
            Column(
            children: <Widget>[
              Container(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelPadding: EdgeInsets.all(0),
                  indicator: BoxDecoration(
                    border: Border(
                      top: BorderSide(color:user.ruler? Colors.deepPurple[700]: Colors.green[700],width: 2),
                      right: BorderSide(color:user.ruler? Colors.deepPurple[700]: Colors.green[700],width: 2),
                      left: BorderSide(color:user.ruler? Colors.deepPurple[700]: Colors.green[700],width: 2),
                    ),
                  ),
                  tabs: user.ruler ? [
                    Tab(
                      child:Container(
                        height:50,
                        width:500, 
                        alignment: Alignment.center,
                        decoration: _tabController.index==0?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.deepPurple[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
                        child:Text("Личное",style: TextStyle(fontSize: 20)),
                        ),
                    ),
                    Tab(
                      child:Container(
                        height:50,
                        width:500, 
                        alignment: Alignment.center,
                        decoration: _tabController.index==1?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.deepPurple[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
                        child: Text("${user.placeID}",style: TextStyle(fontSize: 20)),
                      )
                    )
                  ]:[
                    Tab(
                      child:Container(
                        height:50,
                        width:500, 
                        alignment: Alignment.center,
                        decoration: _tabController.index==0?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.green[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
                        child:Text("Личное",style: TextStyle(fontSize: 20)),
                        ),
                    ),
                  ],
                  onTap: (index){setState(() {});},
                )
              ),
              user.ruler? Container(
                height:510,
                child:
                TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: <Widget>
                 [
                  Column(
                    children:<Widget>
                    [
                      Expanded( 
                        flex:2,
                        child: _isPlanLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.red.shade50,
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Plan(office:false)));
                            },//открыть 
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child:Row(
                                children: <Widget>[
                                  Expanded(//планы на день
                                    flex:1,
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,  
                                      children:<Widget>[
                                        Container(height:10),
                                        Text('Цели на сегодня', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                        Container(height:20),
                                        _hourU.weekend?Container(child:
                                                  Text("Хорошо отдохнуть сегодня! :)", style:TextStyle(fontSize: 18)),
                                                  alignment: Alignment.center,
                                                  width:100
                                            ):_hourU.nn?Container(child:
                                                  Text("Возвращайся к нам скорее! :)", style:TextStyle(fontSize: 18)),
                                                  alignment: Alignment.center,
                                                  width:150
                                            ):Container(
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: _plansIDU.map((data)=>
                                            Container(
                                              child:Row(mainAxisAlignment: MainAxisAlignment.start,
                                                children:<Widget>[
                                                  Container(width:20),
                                                  Container(width:70, child:
                                                  Text("${plans[data].strName}:", style:TextStyle(fontSize: 18))
                                                  ),
                                                  Text("${_plansU[data]}", style:TextStyle(fontSize: 18)),
                                                ]
                                              )
                                            )
                                            ).toList()
                                          )
                                        ),
                                        Container(height:15)
                                      ],
                                    ),
                                  ),
                                  Expanded(//кнопка отправить планы
                                    flex:1,
                                    child:Container(
                                      margin:EdgeInsets.all(10.0),
                                      child:FlatButton(
                                        color:Colors.green.shade400,
                                        textColor: Colors.white,
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.black,
                                        padding: EdgeInsets.all(8.0),
                                        splashColor: Colors.blueAccent,   
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Fact(setFacts:true)));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(15.0),
                                          width: 500,
                                          height: 500,
                                          alignment: Alignment.center,
                                          child:Text("Отправить факты продаж",style:TextStyle(fontSize: 18),textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              ),
                          ),
                        )
                      )
                      ,
                      Expanded(
                        flex: 2,
                        child: _isSheduleLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.blue.shade50,
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Shedule()));
                            },
                            child: Container(
                              width:350.0,
                              //height:100.0,
                              child:Column(
                                children: <Widget>[
                                  Container(height:10),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.centerLeft,
                                    child:Text('График работы:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),                                  
                                  Container(height:10),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Text('Сегодня ты', style:TextStyle(fontWeight: FontWeight.normal, fontSize: 20)),
                                  ),             
                                  Container(height:10),
                                  _hourU.weekend?Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Text('выходной', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ):_hourU.nn?Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Text('не работаешь', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ):Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Column(children:[
                                      Text('работаешь', style:TextStyle(fontWeight: FontWeight.normal, fontSize: 20)),
                                      Container(height:10),
                                      Text('с 10:00 до 19:00', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                      ])
                                  ),             
                                ]
                              )
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex:2,
                        child: _isTaskLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.grey.shade50,
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Tasks()),);
                            },
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child: Column(
                                children: <Widget>[
                                  Container(height:10,),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.centerLeft,
                                    child:Text('Мои задачи:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),         
                                  Container(height:10,),  
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Всего активных:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksU[0]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Новых:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksU[1]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Просроченых:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksU[2]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),                 
                                ],
                              )
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),
                  Column(
                    children: <Widget>[
                      Expanded( 
                        flex:4,
                        child: _isPlanLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.red.shade50,
                            onTap:(){print('pressed card');
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Plan(office:true)));},//открыть планы салона как руководителю
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child:Row(
                                children: <Widget>[
                                  Expanded(//планы на день
                                    flex:1,
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.start,  
                                      children:<Widget>[
                                        Container(height:10),
                                        Container(
                                          height:50,
                                          child:Text('Цели салона на сегодня:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                        ),
                                        Container(
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: _plansIDO.map((data)=>
                                            Container(
                                              child:Row(mainAxisAlignment: MainAxisAlignment.start,
                                                children:<Widget>[
                                                  Container(width:30),
                                                  Expanded( 
                                                    flex:1,
                                                    child: Row(children: <Widget>[
                                                      Container(width:70, height:25,
                                                      child:
                                                        Text("${plans[data[0]].strName}:", style:TextStyle(fontSize: 18))
                                                      ),
                                                      Container(width:70, height:25,
                                                      child:Text("${_plansU[data[0]]}", style:TextStyle(fontSize: 18)),)
                                                    ],),
                                                  ),
                                                  Expanded( 
                                                    flex:1,
                                                    child: Row(children: <Widget>[
                                                      Container(width:70, height:25,
                                                      child:
                                                        Text("${plans[data[1]].strName}:", style:TextStyle(fontSize: 18))
                                                      ),
                                                      Container(width:70, height:25,
                                                      child:Text("${_plansU[data[1]]}", style:TextStyle(fontSize: 18)),)
                                                    ],),
                                                  ),
                                                ]
                                              )
                                            )
                                            ).toList()
                                          ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: _isSheduleLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.blue.shade50,
                            onTap:(){},//открыть график салона как руководителю
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child:Column(
                                      mainAxisAlignment: MainAxisAlignment.start,  
                                      children:<Widget>[ 
                                        Container(height:10),
                                        Container(
                                          height:30,
                                          child:Text('График работы:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                                        ),
                                        //Container(height:10),
                                        Column(
                                          children: _hours.map(
                                            (data)=>
                                            data.weekend||data.nn? Container():Container(
                                              width:360,
                                              height:25,
                                              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                              alignment: Alignment.center,
                                              child:Row(
                                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                              Container(
                                                width:100,
                                              child:Text("${data.name}", style:TextStyle(fontSize: 18)),
                                              ),
                                              Container(width:20),
                                              Container(
                                                width:150,
                                                alignment: Alignment.centerRight,
                                              child:Text("c ${data.time_begin}:00 до ${data.time_end}:00", style:TextStyle(fontSize: 18)),
                                              )
                                            ],)
                                            )
                                          ).toList(),
                                        )
                                      ]
                              )
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex:3,
                        child: _isTaskLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.grey.shade50,
                            onTap:(){
                              print("tasks");
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Tasks()),);
                            },
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child: Column(
                                children: <Widget>[
                                  Container(height:10,),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.centerLeft,
                                    child:Text('Задачи салона:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),         
                                  Container(height:9,),  
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Всего активных:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksO[0]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:5,),
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Выполненные:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksO[1]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:5,),
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Просроченых:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksO[2]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),                 
                                ],
                              )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              )
              ):Container(
                height:510,
                child:
                TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: <Widget>
                 [
                  Column(
                    children:<Widget>
                    [
                      Expanded( 
                        flex:2,
                        child: _isPlanLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.red.shade50,
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Plan(office:false)));
                            },//открыть 
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child:Row(
                                children: <Widget>[
                                  Expanded(//планы на день
                                    flex:1,
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,  
                                      children:<Widget>[
                                        Container(height:10),
                                        Text('Цели на сегодня', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                        Container(height:20),
                                        _hourU.weekend?Container(child:
                                                  Text("Хорошо отдохнуть сегодня! :)", style:TextStyle(fontSize: 18)),
                                                  alignment: Alignment.center,
                                                  width:100
                                            ):_hourU.nn?Container(child:
                                                  Text("Возвращайся к нам скорее! :)", style:TextStyle(fontSize: 18)),
                                                  alignment: Alignment.center,
                                                  width:150
                                            ):Container(
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: _plansIDU.map((data)=>
                                            Container(
                                              child:Row(mainAxisAlignment: MainAxisAlignment.start,
                                                children:<Widget>[
                                                  Container(width:20),
                                                  Container(width:70, child:
                                                  Text("${plans[data].strName}:", style:TextStyle(fontSize: 18))
                                                  ),
                                                  Text("${_plansU[data]}", style:TextStyle(fontSize: 18)),
                                                ]
                                              )
                                            )
                                            ).toList()
                                          )
                                        ),
                                        Container(height:15)
                                      ],
                                    ),
                                  ),
                                  Expanded(//кнопка отправить планы
                                    flex:1,
                                    child:Container(
                                      margin:EdgeInsets.all(10.0),
                                      child:FlatButton(
                                        color:Colors.green.shade400,
                                        textColor: Colors.white,
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.black,
                                        padding: EdgeInsets.all(8.0),
                                        splashColor: Colors.blueAccent,   
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Fact(setFacts:true)));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(15.0),
                                          width: 500,
                                          height: 500,
                                          alignment: Alignment.center,
                                          child:Text("Отправить факты продаж",style:TextStyle(fontSize: 18),textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              ),
                          ),
                        )
                      )
                      ,
                      Expanded(
                        flex: 2,
                        child: _isSheduleLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.blue.shade50,
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Shedule()));
                            },
                            child: Container(
                              width:350.0,
                              //height:100.0,
                              child:Column(
                                children: <Widget>[
                                  Container(height:10),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.centerLeft,
                                    child:Text('График работы:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),                                  
                                  Container(height:10),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Text('Сегодня ты', style:TextStyle(fontWeight: FontWeight.normal, fontSize: 20)),
                                  ),             
                                  Container(height:10),
                                  _hourU.weekend?Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Text('выходной', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ):_hourU.nn?Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Text('не работаешь', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ):Container(
                                    width: 320,
                                    alignment: Alignment.center,
                                    child:Column(children:[
                                      Text('работаешь', style:TextStyle(fontWeight: FontWeight.normal, fontSize: 20)),
                                      Container(height:10),
                                      Text('с 10:00 до 19:00', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                      ])
                                  ),             
                                ]
                              )
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex:2,
                        child: _isTaskLoaded?Card(child:Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                        ),)): Card(
                          child: InkWell(
                            splashColor: Colors.grey.shade50,
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Tasks()),);
                            },
                            child: Container(
                              width:350.0,
                              height:100.0,
                              child: Column(
                                children: <Widget>[
                                  Container(height:10,),
                                  Container(
                                    width: 320,
                                    alignment: Alignment.centerLeft,
                                    child:Text('Мои задачи:', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),         
                                  Container(height:10,),  
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Всего активных:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksU[0]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Новых:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksU[1]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),
                                  Container(
                                    child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget>[
                                        Container(width:20),
                                        Container(width:150, child:
                                        Text("Просроченых:", style:TextStyle(fontSize: 18))
                                        ),
                                        Container(width:70, child:Text("${_tasksU[2]}", style:TextStyle(fontSize: 20)),)
                                      ]
                                    )
                                  ),
                                  Container(height:10,),                 
                                ],
                              )
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),
                 ]
                )
              )
            ])
          ]
        )
        )
      )
  );
  }
}