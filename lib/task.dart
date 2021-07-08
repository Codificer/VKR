import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';


import 'main.dart';


import 'connection.dart';
import 'user.dart';


//===================================================================
//=========================================
//Необходимо добавить проверку, чтобы директор не мог пометить как прочитанную задачу, находящуюся у сотрудника.
//=========================================
//===================================================================

//=========================
//==============
//=========================



//===========================================
//====================================
//====================================
//===========================================

class Tasks extends StatefulWidget{
  Tasks({Key key}) : super(key:key);

  @override 
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks>{

  bool _isLoading=true;
  bool _isTasks=false;

  List<Task> _tasks;
  List<UserTask> _users;
  List<bool> _isOpen;
  List<bool> _isTaskOpen;
  List<int> _countTasks;
  List <List<int>> _numberTasks;

//===================
//===================
//===================
//===================
  setData() async{

    String querry="";
    if(user.ruler){//убрать ! после отладки следующего пункта
      //querry - все пользователи
      querry="SELECT * from tasks, place_of_work where tasks.tn=place_of_work.tn and place_of_work.place_id='${user.placeID}' and tasks.closed=0;";
    }else{
      //querry - только один пользователь
      querry="SELECT * from tasks where tn=${user.tn} and closed=0 and finished=0;";
    }
    var jsonData= await Utility.getData(querry) ?? 1;
    //print(jsonData);
    if(jsonData==1){
      print("error");
    }else{
      _tasks=(jsonData as List).map((i) => Task.fromJson(i)).toList();

      _tasks.sort((a,b)=>b.date.compareTo(a.date));
    
    if(user.ruler){
      //querry - все пользователи
      querry="select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name from worker, place_of_work where place_of_work.tn=worker.tn and place_of_work.place_id='${user.placeID}';";
    }else{
      //querry - только один пользователь
      querry="select tn, concat(name, ' ', substr(famili, 1, 1),'.') as name from worker where tn=${user.tn};";
    }

    jsonData= await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error");
      _users.add(UserTask(name: user.name, tn: user.tn));
    }else{
      _users=(jsonData as List).map((i) => UserTask.fromJson(i)).toList();
      _users.sort((a,b)=> a.name.compareTo(b.name));
      _isOpen=new List<bool>();     
      _isTaskOpen=new List<bool>(); 
      _countTasks=new List<int>();
      _numberTasks=new List<List<int>>();
      for(int i=0;i<_users.length;i++){
        (!user.ruler)?_isOpen.add(true):_isOpen.add(false);
        _countTasks.add(0);
        _numberTasks.add(new List<int>());
      }
      _isTasks=true;
      for(int i=0;i<_tasks.length;)
      { 
        if(!((_tasks[i].starter==user.tn)||((_tasks[i].tn==user.tn)&&(!_tasks[i].finished)))){_tasks.remove(_tasks[i]);}
        else{i++;}
        }
      _tasks.forEach((task){
        
          _countTasks[_users.indexWhere((u)=>u.tn==task.tn)]++;
          _numberTasks[_users.indexWhere((u)=>u.tn==task.tn)].add(_tasks.indexWhere((u)=>(u.id==task.id)));
         
          _isTaskOpen.add(false);
      });
      print(_numberTasks);
      print(_isTaskOpen);
    }
    }
    }
//===================
//===================
//===================

  loadingData() async{
    print("loadData tasks");
    await setData();    
    if(_isLoading){
      setState(() {
      _isLoading=false;
    print("set state complete");
    });}

  }
  
  initState(){
    loadingData();
  }

  @override 

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[500],
        title:Center(
          child: Column(
          children: <Widget>[
            Text("Задачи", style: TextStyle(fontSize: 30)),
            //Text("на $_datenow"),
          ]
          ),
        ),
        actions: <Widget>[
          IconButton( 
            onPressed: (){},
            icon:Icon(
              Icons.filter_list,
              size:30,  
            )
          )
        ],
      ),
      body:_isLoading? Center(
        child:CircularProgressIndicator(
          backgroundColor: Colors.green[100],
          //индикатор загрузки
        ),
      ): _isTasks ? 
      Center(
        child:RefreshIndicator(
          onRefresh:()async{
            _isLoading=true;
            setState(() {});
            loadingData();
          },
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _users.length,
          itemBuilder:(BuildContext cont,int i){
            return Column(
            children:<Widget>[
              Card(
                margin: EdgeInsets.fromLTRB(10,0,10,10),
                child: InkWell(
                  splashColor: Colors.deepPurple.withAlpha(30),
                  onTap: () {
                    setState(() {
                      _isOpen[i]=!_isOpen[i];
                    });
                  },
                  child:Center(
                    child:Container(
                      constraints: BoxConstraints(
                        minHeight:80,
                      ),
                      alignment: Alignment.center,
                      child:Column(
                        children:<Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children:<Widget>[
                              Text( "${_users[i].name}",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color:(_users[i].tn==user.tn)?Colors.deepPurple[500]:Colors.green[700],
                                )
                              ),
                              Icon(
                                _isOpen[i]?Icons.arrow_drop_down:Icons.arrow_right,
                                size:50,
                              ),
                            ]
                          ),
                        ]
                      )
                    ),
                  )
                )
              ),
              _isOpen[i]?
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemCount:_numberTasks[i].length,
                itemBuilder: (BuildContext context, int j){
                  return Column(
                    children: <Widget> [
                      Card(
                        margin: EdgeInsets.all(5),
                        child:InkWell(
                          hoverColor: (_users[i].tn==user.tn)?Colors.deepPurple[500]:Colors.green[700],
                          child:Container(
                            alignment: Alignment.centerLeft,
                            child:Row(
                              children: <Widget>[
                                Expanded(//name and icons
                                  flex:4,
                                  child:Column(
                                    children:<Widget>[
                                      Container(
                                        padding: EdgeInsets.only(left:10),
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        child:Text(
                                        "${_tasks[_numberTasks[i][j]].name.substring(0,(_tasks[_numberTasks[i][j]].name.length < 20) ?_tasks[_numberTasks[i][j]].name.length : 20)}",
                                        style:TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                        )
                                      ),
                                      ),
                                      _isTaskOpen[_numberTasks[i][j]]?Container(
                                        padding: EdgeInsets.only(left:10, bottom:10),
                                        alignment: Alignment.centerLeft,
                                        child:Text("${_tasks[_numberTasks[i][j]].what}",
                                          style:TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 15,
                                            color:Colors.grey[400],
                                          )
                                        ),
                                      ):Container(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,

                                        children: <Widget>[
                                          Container(
                                            height:30,
                                            padding: EdgeInsets.fromLTRB(10,0,5,20),
                                            child:Icon(
                                              _tasks[_numberTasks[i][j]].readed ? Icons.mail_outline:Icons.mail_outline,
                                              size: 20.0,
                                              color: _tasks[_numberTasks[i][j]].readed ? Colors.green : Colors.red,
                                            ),
                                          ),
                                          Container(
                                            height:30,
                                            padding: EdgeInsets.fromLTRB(5,0,5,20),
                                            child:Opacity(
                                              opacity: _tasks[_numberTasks[i][j]].finished ? 1:0,
                                              child:Icon(
                                                Icons.check,
                                                size: 20.0,
                                                color:Colors.green,
                                              ) 
                                            ),
                                          ),
                                          Container(
                                            height:30,
                                            padding: EdgeInsets.fromLTRB(5,0,5,20),
                                            child:Opacity(
                                              opacity: _tasks[_numberTasks[i][j]].returned ? 1:0,
                                              child:Icon(
                                                Icons.rotate_right,
                                                size: 20.0,
                                                color: Colors.red,
                                              ),
                                            )
                                          ),
                                          Container(
                                            height:30,
                                            padding: EdgeInsets.fromLTRB(5,0,5,20),
                                            child:Opacity(
                                              opacity: (_tasks[_numberTasks[i][j]].date.compareTo(DateTime.now())<0) ? 1:0,
                                              child:Icon(
                                                Icons.timer,
                                                size: 20.0,
                                                color: Colors.red,
                                              ),
                                            )
                                          )
                                        ],
                                      )
                                    ]
                                  )
                                ),
                                Expanded(//time
                                  flex:2,
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children:<Widget>[
                                      Container(
                                        //padding:EdgeInsets.only(top:10),
                                        alignment: Alignment.topCenter,
                                        child:Text(
                                        "${_tasks[_numberTasks[i][j]].time}",
                                        style:TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          )
                                        ) 
                                      ),
                                      _isTaskOpen[_numberTasks[i][j]] ? Container(
                                        padding:EdgeInsets.only(left:10,top:10,right: 10),
                                        child: OutlineButton( 
                                          borderSide: BorderSide(
                                            color: (_users[i].tn==user.tn)?Colors.deepPurple[300]:Colors.green[300],
                                            width: 2,
                                            ),
                                          child:Text("Подробнее",
                                          style:TextStyle(
                                            fontSize: 10,
                                            )
                                          ),

                                          onPressed: ()async{
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditConfirmTask(task: _tasks[_numberTasks[i][j]],users:_users)),);
                                          },
                                        ),
                                      ):Container(),
                                    ]
                                  )
                                )
                              ],
                              )
                            ),
                          onTap: ()async{
                            setState((){
                            _isTaskOpen[_numberTasks[i][j]]=!_isTaskOpen[_numberTasks[i][j]];
                              //добавить пересоздание задачи, чтобы обновило статус "прочтенная"
                              });
                            if(!_tasks[_numberTasks[i][j]].readed&&user.tn==_tasks[_numberTasks[i][j]].tn){
                              String querry="update tasks set readed=1 where task_id=${_tasks[_numberTasks[i][j]].id};";
                              var jsonData=await Utility.getData(querry) ?? 1;
                              _tasks[_numberTasks[i][j]].readed=true;
                              setState((){});
                            }
                          },
                        )
                      ),
                      
                  ]);
                },
              ):Container()
            ])
            ;
          },
          ),)
      ):Center( 
        child:Text('Not Tasks')
      ),
      floatingActionButton: user.ruler ? FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SetTask()),).then((value){_isLoading=true; loadingData();});
        },
        child:Icon(
          Icons.add,
        ),
        backgroundColor: Colors.grey[700],
      ):null,// 
    );
  }
}



//====================================================
//====================================================
//====================================================

//Создание новой задачи

//====================================================
//====================================================
//====================================================

//виджет постановки задачи
class SetTask extends StatefulWidget{
  SetTask({Key key}) : super(key:key);

  @override 
  _SetTaskState createState() => _SetTaskState();
}


class _SetTaskState extends State<SetTask>{
  
  bool _isTaskNotSetted=true;
  
  var _currentdate;
  var _datenow;
  var _date;
  var _selectedDate;
  String dropdownvalue;
  bool _isLoading=true;
  bool _forAllWorkers=false;
  

  List <UserTask> _users;//список сотрудников. работающих на точке
  
  TextEditingController _nameOfTask=new TextEditingController();
  TextEditingController _whatToDo=new TextEditingController();
  TextEditingController _howToDo=new TextEditingController();
  TextEditingController _whyToDo=new TextEditingController();

  bool _needPhoto=false;

  setData() async{
    _currentdate = new DateTime.now();
    _datenow = "${_currentdate.day} ${Utility.month(_currentdate.month)} ${_currentdate.year}";
    _selectedDate=new DateTime(_currentdate.year,_currentdate.month,_currentdate.day,_currentdate.hour+1, _currentdate.minute);
    //print(_currentdate);
    //print(_selectedDate);
    String querry= "select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name from worker, place_of_work where place_of_work.tn=worker.tn and place_of_work.place_id='${user.placeID}';";
    
    var jsonData= await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error");
    }else{
      _users=(jsonData as List).map((i) => UserTask.fromJson(i)).toList();
      _users.add(new UserTask(name: "Весь штат", tn:user.placeID));
      dropdownvalue=_users[0].name;
    }
  }

  loadingData() async{
    print("loadData set task");
    await setData();    
    if(_isLoading){
      setState(() {
      _isLoading=false;
    //print("set state complete");

    });}

  }
  
  initState(){
    loadingData();
  }
  @override 

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.grey[700],
      title:Center(
        child: Column(
        children: <Widget>[
          Text("Поставить задачу"),
          //Text("на $_datenow"),
        ]
        ),
      ),
      actions: <Widget>[
         Container(
          width:70,
          height:50,
          child:IconButton(
            onPressed: ()async{
              if(_isTaskNotSetted){
                String querry;
                _date="'${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}-${_selectedDate.hour}-${_selectedDate.minute}'";
                if(_users[_users.indexWhere((userT)=>userT.name.startsWith(dropdownvalue))].tn!=user.placeID){

                querry="INSERT INTO tasks (tn, starter, time, name, what, how, why,need_photo,photo_link) VALUES (${_users[_users.indexWhere((user)=>user.name.startsWith(dropdownvalue))].tn},${user.tn},$_date, '${_nameOfTask.text}', '${_whatToDo.text}', '${_howToDo.text}', '${_whyToDo.text}', ${_needPhoto?1:0}, '');";

                Utility.getData(querry);

                }else{
                  _users.removeLast();
                  _users.forEach((userT){

                  querry="INSERT INTO tasks (tn, starter, time, name, what, how, why,need_photo,photo_link) VALUES (${userT.tn},${user.tn},$_date, '${_nameOfTask.text}', '${_whatToDo.text}', '${_howToDo.text}', '${_whyToDo.text}', ${_needPhoto?1:0}, '');";

                Utility.getData(querry);
                  });
                }
                _isTaskNotSetted=false;
                Navigator.pop(context); 
              }
            },
            icon:Icon(
              Icons.check_box,
              size: 30.0,
            ),
          ),
        ),
      ],
      ),
      body:_isLoading ? Center(
        child:CircularProgressIndicator(
        backgroundColor: Colors.green[100],
        //индикатор загрузки
      ),
      )
    :Center(
        child:Column( 
        children:<Widget>[
          Divider( 
            height: 10,
            thickness: 10,
          ),
          Row(
            children: <Widget>[ 
              Expanded( 
                flex:1,
                child:Center(
                  child:Text("Кому:",style:TextStyle(fontSize: 20,)),
                ),
              ),
              Expanded(
                flex:2,
                child:Center(
                  child:DropdownButton(
                    
                    value: dropdownvalue,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size:50,
                    ),
                    elevation: 1,
                    style:TextStyle(
                      color: Colors.deepPurple[800],
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                    setState(() {
                      dropdownvalue = newValue;
                    });
                    },
                    items:_users
                    .map<DropdownMenuItem<String>>((UserTask value){
                      return DropdownMenuItem<String>(
                        value:value.name,
                        child:Text(value.name,
                        style: TextStyle(
                          fontSize: 20,
                        ),),
                      );
                    }
                    ).toList(),
                  ),
                )
              ),
            ]
          ),
          Divider( 
            height: 10,
            thickness: 0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card( 
                child: RaisedButton( 
                  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.grey[300],
                  elevation:6,
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(_selectedDate.year, _selectedDate.month-1, _selectedDate.day,_selectedDate.hour,_selectedDate.minute),
                      maxTime: DateTime(_selectedDate.year+1, _selectedDate.month, _selectedDate.day), 
                      onConfirm: (date) {
                        _selectedDate=date;
                        //print('confirm $_selectedDate');
                        setState((){});
                      }, 
                      currentTime: _selectedDate, 
                      locale: LocaleType.ru);
                      setState((){});
                  },
                  child:Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Text(
                          "До ${_selectedDate.day} ${Utility.month(_selectedDate.month)} ${_selectedDate.year}   ${_selectedDate.hour}:${(_selectedDate.minute==0)?'00':_selectedDate.minute}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                        ),
                      ],
                    )
                  )
                )
              ),
            ],
          ),
          Divider( 
            height: 10,
            thickness: 0,
          ),
          Expanded(
          child:ListView(
          children:<Widget>[
          Card(
            margin: EdgeInsets.all(10),
            child:TextField(
              maxLength: 50,
              minLines: 1,
              maxLines: 3,
              controller:_nameOfTask,
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
                labelText: 'Название задачи',
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child:TextField(
              minLines: 1,
              maxLines: 3,
              controller: _whatToDo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Что сделать?',
              ),
            ),
          ),
          Card( 
            margin: EdgeInsets.all(10),
            child:TextField(
              minLines: 1,
              maxLines: 3,
              controller: _howToDo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Как сделать?',
              ),
              ),
            ),
            Card(
            margin: EdgeInsets.all(10),
            child:TextField(
              minLines: 1,
              maxLines: 3,
              controller: _whyToDo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Зачем это требуется?',
              ),
              ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child:Center(
              child:Row( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Фото-подтверждение '),
                  Checkbox(
                    activeColor: Colors.grey,
                    value: _needPhoto,
                    onChanged: (check){
                      _needPhoto=check;
                      setState(() {});
                    },
                  )
                ],
              )
            )
          ),
        ]
        )
      )
      ]
      ),
      ),
    );
  }
}

//===========================================================
//===========================================================
//===========================================================



//===========================================================
//===========================================================
//===========================================================

class EditConfirmTask extends StatefulWidget{
  Task task;
  List <UserTask> users;
  EditConfirmTask({Key key,this.task,this.users}):super(key:key);

  @override 
  _EditConfirmTaskState createState() => _EditConfirmTaskState();
}



class _EditConfirmTaskState extends State<EditConfirmTask>{


  bool _isChanging=false;
  bool _isTaskNotSetted=true;
  bool _isLoading=true;
  String dropdownvalue;
  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  bool _isPhotoSelect=false;
  bool _isPhotoNetwork=false;

  
  TextEditingController _nameOfTask=new TextEditingController();
  TextEditingController _whatToDo=new TextEditingController();
  TextEditingController _howToDo=new TextEditingController();
  TextEditingController _whyToDo=new TextEditingController();

  setData() async{
    _nameOfTask.text=widget.task.name;
    _whatToDo.text=widget.task.what;  
    _howToDo.text=widget.task.how;  
    _whyToDo.text=widget.task.why;  
    dropdownvalue=widget.users[widget.users.indexWhere((user)=> user.tn==widget.task.tn)].name;
    if(widget.task.photo_link!=null){
      _isPhotoSelect=true;
    }
  }

  sendData(BuildContext context) async{
    //print("send data");
    if(user.tn!=widget.task.starter){
      String querry="update tasks set finished=1 where task_id=${widget.task.id};";
      await Utility.getData(querry);
    }
    Navigator.pop(context);
  }

  upload()async{
    String querry;
    String ImageStr=Utility.base64String(tmpFile.readAsBytesSync());
    querry="update tasks set photo_link='${ImageStr}'where task_id=${widget.task.id};";
    Utility.getData(querry);
  }
//загрузка изображений=
//=====================




chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
}
makeImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.camera);
    });
}



Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          //print(base64Image);
          _isPhotoSelect=true;
          return Flexible(
            child: InkWell(
              child:
              Image.file(
                snapshot.data,
                fit: BoxFit.contain, 
              ),
              onTap:(){ Navigator.push(context, MaterialPageRoute(builder: (context) =>ImagePage(image:base64Image)));},
              )
          );
        } else if (null != snapshot.error) {
          _isPhotoSelect=false;
          return const Text(
            'Ошибка выбора фото',
            textAlign: TextAlign.center,
          );
        } else {
          _isPhotoSelect=false;
          return const Text(
            'Не выбрано фото',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }



//=====================
//=====================



  loadingData() async{

    print("loadData editing task");
    await setData();  
    if(_isLoading){
      setState(() {
      _isLoading=false;
    });}
  }

  @override

  initState(){
    loadingData();
  }


  Widget build(BuildContext contextMain){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title:Container(
          child:
            Text( _isChanging? "Редактирование\nзадачи":"Просмотр задачи"),
          ),
        actions: <Widget>[
          (!widget.task.finished)&&(widget.task.starter==user.tn)?
          Container(
            width:70,
            height:50,
            child:IconButton(
              onPressed: ()async{
                _isChanging=!_isChanging;
                setState(() {});
              },
              icon:Icon(
                _isChanging? Icons.check_box:Icons.edit,
                size: 30.0,
              ),
            ), 
          ):Container(),
        ],
      ),
      //тело начинается здесь =======================
      body:_isLoading ? Center(
        child:CircularProgressIndicator(
        backgroundColor: Colors.green[100],
        //индикатор загрузки
      ),
      )
    :Center(
        child:Column( 
          children:<Widget>[
            Divider( 
              height: 10,
              thickness: 10,
            ),
            Row(
              children: <Widget>[ 
                Expanded( 
                  flex:1,
                  child:Center(
                    child:Text("Кому:",style:TextStyle(fontSize: 20,)),
                  ),
                ),
                Expanded(
                  flex:2,
                  child:Center(
                    child:_isChanging? DropdownButton(
                      
                      value: dropdownvalue,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size:50,
                        ),
                      elevation: 1,
                      style:TextStyle(
                        color: Colors.deepPurple[800],
                        ),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                        ),
                      onChanged: _isChanging?(String newValue) {
                      setState(() {
                        dropdownvalue = newValue;
                        });
                        }:(String newValue){},
                      items:widget.users
                        .map<DropdownMenuItem<String>>((UserTask value){
                          return DropdownMenuItem<String>(
                            value:value.name,
                            child:Text(value.name,
                            style: TextStyle(
                              fontSize: 20,
                            ),),
                          );
                        }
                        ).toList(),
                      ):FlatButton( 
                        child: Text(dropdownvalue,
                        style:TextStyle(
                          fontSize: 20,
                          color: Colors.deepPurple[800],
                        ),                    
                        ),
                        onPressed: null,
                      ),
                    )
                  ),
                ]
              ),
              Divider( 
                height: 10,
                thickness: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card( 
                    child: RaisedButton( 
                      //сделать дисейблд
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                      color: Colors.grey[300],
                      elevation:6,
                      onPressed: _isChanging? () {
                        DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(widget.task.date.year, widget.task.date.month-1, widget.task.date.day,widget.task.date.hour,widget.task.date.minute),
                          maxTime: DateTime(widget.task.date.year+1, widget.task.date.month, widget.task.date.day), 
                          onConfirm: (date) {
                            widget.task.date=date;
                            //print('confirm $widget.task.date');
                            setState((){});
                          }, 
                          currentTime: widget.task.date, 
                          locale: LocaleType.ru);
                          setState((){});
                      } : null,
                      child:Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        child: Row(
                          children: <Widget>[
                            Text(
                              "До ${widget.task.date.day} ${Utility.month(widget.task.date.month)} ${widget.task.date.year}   ${widget.task.date.hour}:${(widget.task.date.minute==0)?'00':widget.task.date.minute}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0),
                            ),
                          ],
                        )
                      )
                    )
                  ),
                ],
              ),
              Divider( 
                height: 10,
                thickness: 0,
              ),
              Expanded(
                child:ListView(
                  children:<Widget>[
                    Card(
                      margin: EdgeInsets.all(10),
                      child:TextField(
                        enabled: _isChanging,
                        maxLength: 50,
                        minLines: 1,
                        maxLines: 3,
                        controller:_nameOfTask,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(),
                          labelText: 'Название задачи',
                          ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.all(10),
                      child:TextField(
                        enabled: _isChanging,
                        minLines: 1,
                        maxLines: 3,
                        controller: _whatToDo,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Что сделать?',
                          ),
                      ),
                    ),
                    Card( 
                      margin: EdgeInsets.all(10),
                      child:TextField(
                        enabled: _isChanging,
                        minLines: 1,
                        maxLines: 3,
                        controller: _howToDo,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Как сделать?',
                          ),
                      ),
                    ),
                    Card(
                    margin: EdgeInsets.all(10),
                    child:TextField(
                      enabled: _isChanging,
                      minLines: 1,
                      maxLines: 3,
                      controller: _whyToDo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Зачем это требуется?',
                        ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(10),
                    child:Center(
                      child:Column(
                        children:<Widget>[
                          Row( 
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Фото-подтверждение: ${(!widget.task.need_photo)&&(user.tn!=widget.task.starter)?'не требуется':''}'),
                              ((user.tn==widget.task.starter)&&(!widget.task.finished))?Checkbox(//если я поставил сам себе задачу и задача не в статусе выполнено
                                activeColor: Colors.grey,
                                value: widget.task.need_photo,
                                onChanged: _isChanging? (check){
                                  widget.task.need_photo=check;
                                  setState(() {});
                                  }:null,
                              ):
                              ((widget.task.starter==user.tn)&&(widget.task.need_photo))? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Utility.imageFromBase64String(widget.task.photo_link,contextMain),
                                ],
                              ):Container(
                                height:60
                              ),//здесь должны быть загруженные фото или кнопка загрузить фото
                            ],
                          ),
                          (widget.task.need_photo)&&(widget.task.starter!=user.tn)? Row(  
                            children: <Widget>[
                              ButtonBar(  
                                children: <Widget>[
                                  OutlineButton( 
                                    child:Text("Выбрать фото"),
                                    onPressed: (){chooseImage();},
                                  ),
                                  OutlineButton( 
                                    onPressed: (){makeImage();},
                                    child: Icon( 
                                      Icons.camera_alt,
                                      size:30,
                                    )
                                  )
                                ],
                              ),
                              showImage(),
                            ],
                          )
                          :Container(),
                        ]
                      )
                    )
                  ),  
                  (user.tn==widget.task.starter)? 
                  Container(//это если задачу создал сотрудник (можно удалить, подтвердить, если задача самому себе, если задача другому чуваку - то можно подтвердить выполнение(и закрыть) или вернуть в работу (допишется текст))
                    child:
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          buttonPadding: EdgeInsets.all(10),
                          buttonMinWidth: 120,
                          children: <Widget>[
                            ((!widget.task.finished)||(user.tn==widget.task.tn))?OutlineButton(//удалить - еще не выполнена или я себе поставил
                              child:Text("Удалить"),
                              onPressed: ()async{
                                String querry="delete from tasks where task_id=${widget.task.id};";
                                Utility.getData(querry);
                                Navigator.pop(contextMain);
                              },
                            ):null,
                            (widget.task.finished&&(user.tn!=widget.task.tn))?OutlineButton(//вернуть - выполнена и не себе
                              child:Text("Вернуть"),
                              onPressed: ()async{
                                String querry="update tasks set finished=0, returned=1 where task_id=${widget.task.id};";
                                Utility.getData(querry);
                                Navigator.pop(contextMain);
                              },
                            ):null,
                            OutlineButton(//подтвердить - выполнена или я себе поставил
                              child:Text("Завершить"),
                              onPressed: ()async{
                                String querry="update tasks set closed=1, photo_link=NULL where task_id=${widget.task.id};";
                                Utility.getData(querry);
                                Navigator.pop(contextMain);
                                },
                            )
                          ],
                        ),
                  ):
                  Container(//это если задача назначена сотруднику кем то другим. Можно только подтвердить выполнение,предварительно прикрепив фото.
                    child:OutlineButton(
                      child: Text("Подтвердить выполнение"),
                      onPressed: widget.task.need_photo? ()async{
                        //если не выбрано фото - диалог подтверждения
                        if(_isPhotoSelect){
                          upload();
                          sendData(contextMain);
                        }else{showDialog(context: context,
                          barrierDismissible: false,
                          builder:(_) =>AlertDialog(
                            title:Text("Вы не приложили фотографию!"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("ОК"),
                                onPressed: (){Navigator.pop(context);},
                              )
                            ],
                          ),
                        );}
                      }:()async{
                        sendData(contextMain);
                        //print("confirm task");
                      },
                    )
                  ),
                ]
              )
            ),
          ]
        ),
      ),
    );
  }
}





