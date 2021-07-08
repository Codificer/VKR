import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'main.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import 'connection.dart';
import 'user.dart';




//===========================================================
//===========================================================
//===========================================================

//График
//===========================================================
//===========================================================
//===========================================================


class Shedule extends StatefulWidget{
  Shedule ({Key key}):super(key:key);
  @override
  _SheduleState createState() => _SheduleState();
}


class _SheduleState extends State<Shedule> with SingleTickerProviderStateMixin{

  bool _isLoadingDay=true;
  bool _isLoadingMonth=true;
  TabController _tabController;
  DateTime _currentDate;
  DateTime _month;
  List<UserSheduleDay> _dayShedule;  
  List<List<UserSheduleDay>> _monthShedule;
  List<UserTask> _users;
  List<String> _names;
  List<String> _days;
  List<List<String>> _work;

//======================
//==========
//Цвета
//==========
//======================

  int _selectedRow;

  Color getContentColor(int i) {
    if (i == _selectedRow) {
      return Colors.cyan[100];
    } else {
      return Colors.transparent;
    }
  }

//======================
//==========
//Первичные данные
//==========
//======================


  void setData() async{
    String querry="select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name from worker, place_of_work where place_of_work.tn=worker.tn and place_of_work.place_id='${user.placeID}' order by name;";

    var jsonData= await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error loading user");
      _users.add(UserTask(name: user.name, tn: user.tn));
    }else{
      _users=(jsonData as List).map((i) => UserTask.fromJson(i)).toList();
      _users.sort((a,b)=> a.name.compareTo(b.name));
    }
    _selectedRow=_users.indexWhere((test)=>test.tn==user.tn);
    _names=new List<String>(); 
    _users.forEach((f)=>_names.add(f.name));
    await setDataDay();
    //await setDataMonth();
  }

//=================
//день
//=================
  void setDataDay() async{

    String querry="select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name, shedule.weekend as weekend, shedule.nn as nn, shedule.begin as time_begin, shedule.end as time_end from worker, shedule, place_of_work where place_of_work.tn=worker.tn and place_of_work.place_id='${user.placeID}' and shedule.tn=worker.tn and shedule.date='${_currentDate.year}-${_currentDate.month}-${_currentDate.day}' order by nn,weekend,name;";

    var jsonData= await Utility.getData(querry) ?? 1;

    _dayShedule=new List<UserSheduleDay>();

    if(jsonData==1){
      print("error loading day");
      _users.forEach((f)=>_dayShedule.add(UserSheduleDay.fromUserTask(f)));
    }else{
      _dayShedule=(jsonData as List).map((i) => UserSheduleDay.fromJson(i)).toList();
    }
    print("set day complete");
  }

//=================
//месяц
//=================
  void setDataMonth() async{

    String tMonthStart="'${_month.year}-${_month.month}-1'";
    String tMonthEnd="'${_month.year}-${_month.month}-${Utility.monthDaysCount(_month.month, _month.year)}'";
    String querry="select worker.tn as tn, concat(worker.name, ' ', substr(worker.famili, 1, 1),'.') as name, shedule.weekend as weekend, shedule.nn as nn, shedule.begin as time_begin, shedule.end as time_end, shedule.date as date from worker, place_of_work, shedule  where place_of_work.tn=worker.tn and place_of_work.place_id='U067' and shedule.tn=worker.tn and shedule.date<=$tMonthEnd and shedule.date>=$tMonthStart order by name";

    _monthShedule=new List <List <UserSheduleDay>>();
    _days=new List<String>();
    _work=new List<List<String>>();
    for(int i=0;i<_users.length;i++)
      {
        _monthShedule.add(new List<UserSheduleDay>());
        _work.add(new List<String>());
        for(int j=0;j<Utility.monthDaysCount(_month.month, _month.year);j++)
        {
          _monthShedule[i].add(UserSheduleDay.fromUserTask(_users[i]));
          _work[i].add("");
        }
      }
    _days=new List<String>();
    for(int i=0;i<Utility.monthDaysCount(_month.month, _month.year);i++)
    {
      _days.add("${Utility.dayOfWeek(DateTime(_month.year,_month.month,i+1))}");
    }

    var jsonData= await Utility.getData(querry) ?? 1;

    if(jsonData==1){
      print("error loading month");
    }else{
      for(int i=0;i<jsonData.length;i++){
        int tday=DateTime.parse(jsonData[i]['date']).day;
        _monthShedule[_users.indexWhere((test) => test.tn==jsonData[i]['tn'])][tday-1]=UserSheduleDay.fromJson(jsonData[i]);
      }
    }
    for(int i=0;i<_users.length;i++){
      for(int j=0;j<Utility.monthDaysCount(_month.month, _month.year);j++)
      {
        _work[i][j]=_monthShedule[i][j].nn?"НН": _monthShedule[i][j].weekend?"В":"с ${_monthShedule[i][j].time_begin}:00\nдо ${_monthShedule[i][j].time_end}:00";
      }
    }
    print("set month complete");
  }

//======================
//Загрузка и SetState
//======================
  void loadData() async {
    await setData();

    if(_isLoadingDay){setState(() {_isLoadingDay=false;});}
  }

  void loadDataD() async{
    await setDataDay();
    if(_isLoadingDay){setState(() {_isLoadingDay=false;});}
  }
  void loadDataM() async{
    await setDataMonth();
    if(_isLoadingMonth){setState(() {_isLoadingMonth=false;});}
  }

  //====================
  //Диалог редактирования
  //====================




  @override 


  void initState(){
    super.initState();
    _tabController=TabController(length: 2, initialIndex: 0, vsync: this);
    _currentDate=DateTime.now();
    _month=_currentDate;
    loadData();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        title:Center(
          child: Column(
            children: <Widget>[
              Text("График работы", style: TextStyle(fontSize: 30)),
            ]
          ),
        ),
      ),
      body:Center(
        child:RefreshIndicator(
          onRefresh:()async{
            _tabController.index==0? _isLoadingDay=true:_isLoadingMonth=true;
            setState(() {});
            _isLoadingDay?await loadDataD():await loadDataM();            
          },
        child:ListView(
          semanticChildCount: 2,
          children:<Widget>[
            Column(
              children:<Widget>[
              Container(
                child:TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelPadding: EdgeInsets.all(0),
                  indicator: BoxDecoration(
                    border: Border(
                      top: BorderSide(color:Colors.cyan[700],width: 2),
                      right: BorderSide(color:Colors.cyan[700],width: 2),
                      left: BorderSide(color:Colors.cyan[700],width: 2),
                    ),
                  ),
                  tabs: [
                    Tab(//DAY
                      child:Container(
                        height:50,
                        width:500, 
                        alignment: Alignment.center,
                        decoration: _tabController.index==0?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.cyan[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
                        child:Text(
                          "Сегодня",
                          style: TextStyle(
                            fontSize: 20
                          )
                        ),
                      )
                    ),
                    Tab(//MONTH
                      child: Container(
                        height:50, 
                        width:500,
                        alignment: Alignment.center,
                        decoration: _tabController.index==1?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.cyan[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
                        child:Text(
                          "На месяц",
                          style: TextStyle(
                            fontSize: 20
                          )
                        ),
                      )
                    ),
                  ],
                  onTap:(index)async{
                    print("${index}, ${_isLoadingDay}, ${_isLoadingMonth}");
                    index==0?(_isLoadingDay?await loadDataD():null) : (_isLoadingMonth?await loadDataM():null);
                    setState(() {
                    });
                  }
                )
              ),
              Container(
                child:Container(
                  height: 500,
                  alignment: Alignment.center,
                  child:TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children:[
                       _isLoadingDay?Center(
                        child:CircularProgressIndicator(
                          backgroundColor: Colors.blue[100],
                      )):Center(//DAY
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[                  
                            Card(//Сегодня работают
                              child: Column(
                                children:<Widget>[
                                  Container(width:300, height:20),
                                  DataTable(
                                    columnSpacing: 0,
                                    horizontalMargin: 0,

                                    columns: [
                                      DataColumn(
                                        label:FlatButton(child:Text("Сотрудник"),onPressed: (){},),
                                        numeric: false,
                                      ),
                                      DataColumn(
                                        label:FlatButton(child:Text("Часы работы"),onPressed: (){},),
                                        numeric: false,
                                      ),
                                    ],
                                    rows:_dayShedule
                                    .map(
                                      (data) =>
                                        DataRow(

                                        cells: [
                                          DataCell(
                                            FlatButton(child:Text("${data.name}"),color: getContentColor(_users.indexWhere((test)=>test.tn==data.tn)),onPressed: (){},)
                                          ),
                                          DataCell(
                                            data.weekend?FlatButton(child:Text("Выходной (В)"), onPressed: (){},color: getContentColor(_users.indexWhere((test)=>test.tn==data.tn))): data.nn? FlatButton(child:Text("Отсутствует (НН)"), onPressed: (){},color: getContentColor(_users.indexWhere((test)=>test.tn==data.tn))) : FlatButton(child:Text("${data.time_begin}:00 - ${data.time_end}:00 (${((int.parse(data.time_end)-int.parse(data.time_begin))<4)?(int.parse(data.time_end)-int.parse(data.time_begin)):(int.parse(data.time_end)-int.parse(data.time_begin)-1)}ч.)"), onPressed: (){},color: getContentColor(_users.indexWhere((test)=>test.tn==data.tn))),
                                          ),
                                        ]
                                        )
                                    ).toList()
                                  )
                                ]
                              )
                            ),
                          ]
                        )
                      ),
                       Center(
                        child:Column(//MONTH
                          children: <Widget>[
                            Card(//переключатель месяца
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(//-1
                                    alignment: Alignment.center,
                                    onPressed: ()async{
                                      _month=new DateTime(_month.year, _month.month-1, 1);
                                      _isLoadingMonth=true;
                                      setState(() {});
                                      await loadDataM();
                                    },
                                    icon: Icon(Icons.arrow_left, size: 30,),
                                  ),
                                  Container(//текст
                                    child:Text("${Utility.monthName(_month.month)} ${_month.year}г.",style:TextStyle( fontSize: 20),),
                                  ),
                                  IconButton(//+1
                                    icon: Icon(Icons.arrow_right, size: 30,),
                                    onPressed: ()async{
                                      _month=new DateTime(_month.year, _month.month+1, 1);
                                      if(_currentDate.compareTo(_month)<0){_month=_currentDate;}
                                      else{
                                      _isLoadingMonth=true;
                                      setState(() {});
                                      await loadDataM();
                                      }                         
                                    },
                                  ),
                                ],
                              )
                            ),
                            _isLoadingMonth?Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.cyan[100],
                            )):Center(//table
                                child:Container(
                                  height:400,
                                  width:500,
                                  child:StickyHeadersTable(
                                  columnsLength: _days.length,
                                  rowsLength: _names.length,
                                  cellDimensions: CellDimensions(
                                    //contentCellHeight: 30
                                    ),
                                  cellFit: BoxFit.contain,
                                  //cellFit: BoxFit.fill,
                                  columnsTitleBuilder: (i) => Container(
                                    height:45,
                                    width:58,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Container(child:Column(mainAxisAlignment: MainAxisAlignment.center,children:_days[i].split(',').map((f)=>Text(f),).toList()),alignment: Alignment.center),
                                    onPressed: (){}),                                    
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.cyan[800],width: 2),
                                      right: BorderSide(color:Colors.cyan[800],width: 2))),
                                    ),
                                  rowsTitleBuilder: (i) => Container(
                                    height:45,
                                    width:118,
                                    child:FlatButton(
                                    color: getContentColor(i),
                                    padding: EdgeInsets.all(0),
                                    child: Text(_names[i]),
                                    onPressed: (){},),                                    
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.cyan[800],width: 2),
                                      right: BorderSide(color:Colors.cyan[800],width: 2))),
                                      ),
                                  legendCell: Container(
                                    height:45,
                                    width:118,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text("Сотрудник"),
                                    onPressed: (){}),
                                    
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.cyan[800],width: 2),
                                      right: BorderSide(color:Colors.cyan[800],width: 2))),
                                      ),
                                  contentCellBuilder: (i, j) => Container(
                                    height:45,
                                    width:58,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Container(child:Column(mainAxisAlignment: MainAxisAlignment.center,children:_work[j][i].split('\n').map((f)=>Text(f),).toList()),alignment: Alignment.center),
                                    color: getContentColor(j),
                                    onPressed: ()async{

                                      if(user.ruler){
                                      UserSheduleDay temp= await showDialog(context: context,

                                      builder:(context){

                                        bool _isTimeSelect=false;
                                        int _selected=1;
                                        String dropdownvalue="9:00";
                                        String dropdownvalue1="19:00";
                                        List <String> tTime=["9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00"];
                                        List <String> tTime1=["9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00"];
                                        List <String> tTime2=["10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00"];
                                        return StatefulBuilder(
                                          builder:( context, StateSetter setState){
                                            return Dialog(
                                              //backgroundColor: Colors.cyan[100],
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                                              child: Container( 
                                                height:260,
                                                width:200,
                                                child:Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                                      child:Container(
                                                      //width:200,
                                                      height:50,
                                                      //color:Colors.white70,
                                                      alignment: Alignment.center,
                                                      child:RadioListTile(
                                                        title: Text("Выходной"),
                                                        groupValue: _selected,
                                                        value:1,
                                                        onChanged: (val){
                                                          setState(() {
                                                          _selected=1;
                                                            _isTimeSelect=false;
                                                          });
                                                        },
                                                      )
                                                    ),),
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                      child:Container(
                                                      //width:200,
                                                      height:50,
                                                      //color:Colors.white70,
                                                      alignment: Alignment.center,
                                                      child:RadioListTile(
                                                        title: Text("Отсутствует"),
                                                        groupValue: _selected,
                                                        value:2,
                                                        onChanged: (val){
                                                          _selected=2;
                                                          setState(() {
                                                            _isTimeSelect=false;
                                                          });
                                                        },
                                                      ) 
                                                    ),),
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                      child:Container(
                                                      //width:200,
                                                      height:50,
                                                      //color:Colors.white70,
                                                      alignment: Alignment.center,
                                                      child:RadioListTile(
                                                        title: Container(
                                                          child:Row(
                                                            children: <Widget>[
                                                              Text("с "),
                                                              _isTimeSelect?DropdownButton( 
                                                                
                                                                value:dropdownvalue,
                                                                items: tTime1
                                                                .map<DropdownMenuItem<String>>((String value){
                                                                  return DropdownMenuItem<String>(
                                                                    value:value,
                                                                    child:Text(value,
                                                                    style: TextStyle(
                                                                      //fontSize: 20,
                                                                    ),)
                                                                );}).toList(),
                                                                onChanged: (String newValue) {
                                                                  setState(() {
                                                                    dropdownvalue = newValue;
                                                                    var _temp1=new List<String>();
                                                                    tTime.forEach((f)=>_temp1.add(f));
                                                                    tTime2=_temp1;
                                                                    tTime2.removeRange(0, tTime1.indexOf(dropdownvalue));
                                                                    (tTime2.indexOf(dropdownvalue1)<0)?dropdownvalue1=tTime2[1]:null;
                                                                  });
                                                                  },
                                                              ):Text(dropdownvalue),
                                                              Text(" до "),
                                                              _isTimeSelect?DropdownButton( 
                                                                value:dropdownvalue1,
                                                                items: tTime2
                                                                .map<DropdownMenuItem<String>>((String value){
                                                                  return DropdownMenuItem<String>(
                                                                    value:value,
                                                                    child:Text(value,
                                                                    style: TextStyle(
                                                                      //fontSize: 20,
                                                                    ),)
                                                                );}).toList(),
                                                                onChanged: ((String newValue) {
                                                                  setState(() {
                                                                    dropdownvalue1 = newValue;
                                                                  });
                                                                  }),
                                                              ):Text(dropdownvalue1),
                                                            ],
                                                          )
                                                        ),
                                                        groupValue: _selected,
                                                        value:3,
                                                        onChanged: (val){
                                                          setState(() {
                                                          _selected=3;
                                                            _isTimeSelect=true;
                                                          });
                                                        },
                                                      ),
                                                    ),),
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                                                      child:RaisedButton( 
                                                        color: Colors.cyan[100],
                                                        child:Text("Завершить"),
                                                        onPressed: (){
                                                          String timeB=dropdownvalue.substring(0,dropdownvalue.indexOf(':'));
                                                          print(timeB);
                                                          String timeE=dropdownvalue1.substring(0,dropdownvalue1.indexOf(':'));
                                                          print(timeE);
                                                          Navigator.of(context).pop(UserSheduleDay(name: _monthShedule[j][i].name,tn: _monthShedule[j][i].tn,nn: (_selected==2)?true:false, weekend: (_selected==1)?true:false, time_begin:(_selected==3)?timeB:'0',time_end: (_selected==3)?timeE:'0'));},
                                                      )
                                                    )
                                                  ],
                                                )
                                              ),
                                            );
                                          }
                                        );
                                        }
                                        );
                                        print("юзверь ${i+1}, день ${j+1}");
                                        (temp!=null)? _monthShedule[j][i]=temp:null;

                                        if(temp!=null){
                                          _work[j][i]=_monthShedule[j][i].nn?"НН": _monthShedule[j][i].weekend?"В":"с ${_monthShedule[j][i].time_begin}:00\nдо ${_monthShedule[j][i].time_end}:00";    
                                          String _tt="${((int.parse(_monthShedule[j][i].time_end)-int.parse(_monthShedule[j][i].time_begin))<4)?(int.parse(_monthShedule[j][i].time_end)-int.parse(_monthShedule[j][i].time_begin)):(int.parse(_monthShedule[j][i].time_end)-int.parse(_monthShedule[j][i].time_begin)-1)}";
                                          String querry="insert into shedule(tn,place_id,date,weekend,nn,begin,end,hours) VALUES (${_monthShedule[j][i].tn},'${user.placeID}','${_month.year}-${_month.month}-${i+1}',${_monthShedule[j][i].weekend?1:0},${_monthShedule[j][i].nn?1:0},${_monthShedule[j][i].time_begin},${_monthShedule[j][i].time_end},${_tt}) ON DUPLICATE KEY UPDATE weekend=${_monthShedule[j][i].weekend?1:0}, nn=${_monthShedule[j][i].nn?1:0}, begin=${_monthShedule[j][i].time_begin},end=${_monthShedule[j][i].time_end},hours=${_tt};";
                                          var jsonData= await Utility.getData(querry) ?? 1;             
                                        }
                                        setState(() {});
                                      }
                                      },
                                    ),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.cyan[800],width: 2),
                                      right: BorderSide(color:Colors.cyan[800],width: 2))),
                                      ),
                                  ),
                                )
                                )
                          ],
                        )
                      ),
                    ]
                  )
                )
              )
            ]
            )
          ]
        )
      )
      )
    );
  }

}
