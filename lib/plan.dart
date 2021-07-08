import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';

import 'main.dart';
import 'package:flutter/services.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';


import 'connection.dart';

//===========================================================
//===========================================================
//===========================================================

//Планы личные

//===========================================================
//===========================================================
//===========================================================
class Plan extends StatefulWidget{
  bool office;
  Plan({Key key, this.office}):super(key:key);
  @override
  _PlanState createState() => _PlanState();
}


class _PlanState extends State<Plan> with SingleTickerProviderStateMixin{

  bool _isLoadingDay=true;
  bool _isLoadingMonth=true;
  TabController _tabController;
  DateTime _currentDate;
  DateTime _day,_lastday,_month;
  List<String> _plansNames;
  List<String> _columnsD=["План","Факт"];
  List<String> _columnsM=["План","Факт", "Прогноз", "В день"];
  List<List<String>> _countsD, _countsM;

  //================
  //установка данных
  //================
  void setData() async{
    _plansNames=new List<String>();
    plans.forEach((f)=>_plansNames.add(f.strName));
    _lastday=new DateTime(2000);
    await setDataD();
  }

  void setDataD()async{
    String querry;
    var jsonData;
    _countsD=new List<List<String>>();
    _columnsD.forEach((f)=>_countsD.add(new List<String>()));
    querry="select ";
    if(_day.day==_currentDate.day && _day.month==_currentDate.month  && _day.year==_currentDate.year )
    {
      if(!widget.office){
        querry+=" sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_day.year}-${_day.month}-${_day.day}' and date>='${_day.year}-${_day.month}-1';";      
        jsonData=await Utility.getData(querry) ?? 1;
        int i=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;
        querry="select sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_day.year}-${_day.month}-${_day.day}' and date>='${_day.year}-${_day.month}-1' and tn=${user.tn};";      
        jsonData=await Utility.getData(querry) ?? 1;
        int j=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;
        double hours=j/i;
        if(hours>=1){
          querry="select COUNT(tn) as hours from place_of_work where place_id='${user.placeID}';";
          jsonData=await Utility.getData(querry) ?? 1;
          hours=jsonData[0]['hours']!=null?1/int.parse(jsonData[0]['hours'] as String):1;
        }
        querry="select ";
        plans.forEach((f)=>querry+="CEIL((sales_plan.${f.dbName}-SUM(sales_fact.${f.dbName}))/(1+${Utility.monthDaysCount(_day.month, _day.year)}-${_day.day})) as ${f.dbName}, ");
        querry+="sales_plan.month from sales_plan,sales_fact where sales_plan.month='${_day.year}-${_day.month}-1' and sales_plan.place_id='${user.placeID}' and sales_plan.place_id=sales_fact.place_id and sales_fact.date<='${_day.year}-${_day.month}-${_day.day}' and sales_fact.date>='${_day.year}-${_day.month}-1';";
      }else{
        plans.forEach((f)=>querry+="CEIL((sales_plan.${f.dbName}-SUM(sales_fact.${f.dbName}))/(1+${Utility.monthDaysCount(_day.month, _day.year)}-${_day.day})) as ${f.dbName}, ");
      querry+="sales_plan.month from sales_plan,sales_fact where sales_plan.month='${_day.year}-${_day.month}-1' and sales_plan.place_id='${user.placeID}' and sales_plan.place_id=sales_fact.place_id and sales_fact.date<='${_day.year}-${_day.month}-${_day.day}' and sales_fact.date>='${_day.year}-${_day.month}-1';";
      }
    }else{
      if(!widget.office){
        querry+=" sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_day.year}-${_day.month}-${_day.day}' and date>='${_day.year}-${_day.month}-1';";      
        jsonData=await Utility.getData(querry) ?? 1;
        int i=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;
        querry="select sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_day.year}-${_day.month}-${_day.day}' and date>='${_day.year}-${_day.month}-1' and tn=${user.tn};";      
        jsonData=await Utility.getData(querry) ?? 1;
        int j=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;
        double hours=j/i;
        if(hours>=1){
          querry="select COUNT(tn) as hours from place_of_work where place_id='${user.placeID}';";
          jsonData=await Utility.getData(querry) ?? 1;
          hours=jsonData[0]['hours']!=null?1/int.parse(jsonData[0]['hours'] as String):1;
        }
        querry="select ";
        plans.forEach((f)=>querry+="CEIL(${f.dbName}*${hours}/${Utility.monthDaysCount(_day.month, _day.year)}) as ${f.dbName}, ");
        querry+="month from sales_plan where month='${_day.year}-${_day.month}-1' and place_id='${user.placeID}';";
      }else{
        plans.forEach((f)=>querry+="CEIL(${f.dbName}/${Utility.monthDaysCount(_day.month, _day.year)}) as ${f.dbName}, ");
      querry+="month from sales_plan where month='${_day.year}-${_day.month}-1' and place_id='${user.placeID}';";
      }
    }

    jsonData=await Utility.getData(querry) ?? 1;

    if(jsonData==1){
      print("plan of day error");
      plans.forEach((f)=>_countsD[0].add("0"));
    }else{
      plans.forEach((f)=>_countsD[0].add(int.parse(jsonData[0][f.dbName] as String)<0?'0':(jsonData[0][f.dbName] as String)));
    }
    querry="select ";
    if(widget.office){
      plans.forEach((f)=>querry+="sum(${f.dbName}) as ${f.dbName}, ");
      querry+="date from sales_fact where place_id='${user.placeID}' and date='${_day.year}-${_day.month}-${_day.day}';";
    }else{
      querry+="* from sales_fact where tn=${user.tn} and date='${_day.year}-${_day.month}-${_day.day}';";
    }

    jsonData=await Utility.getData(querry) ?? 1;

    if(jsonData==1){
      print("facts of day error");
      plans.forEach((f)=>_countsD[1].add("0"));
    }else{
      plans.forEach((f)=>_countsD[1].add((jsonData[0][f.dbName]as String)==null?"0":(jsonData[0][f.dbName]as String) ));
    }    

    print(_countsD);  
  }

  void setDataM()async{
    _countsM=new List<List<String>>();
    _columnsM.forEach((f)=>_countsM.add(new List<String>()));

    String querry;
    var jsonData;
    //выгрузка плана
    querry="select ";
    double hours=1;
    int hoursleft=0;
    int hoursall=0;
    if(!widget.office){
        querry+=" sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_month.year}-${_month.month}-${Utility.monthDaysCount(_month.month, _month.year)}' and date>='${_month.year}-${_month.month}-1';";      

        jsonData=await Utility.getData(querry) ?? 1;

        int i=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;

        querry="select sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_month.year}-${_month.month}-${Utility.monthDaysCount(_month.month, _month.year)}' and date>='${_month.year}-${_month.month}-1' and tn=${user.tn};";      

        jsonData=await Utility.getData(querry) ?? 1;

        int j=jsonData[0]['hours']!=null?int.parse(jsonData[0]['hours'] as String):1;
        hours=j/i;
        if(hours>=1){
          querry="select COUNT(tn) as hours from place_of_work where place_id='${user.placeID}';";
          jsonData=await Utility.getData(querry) ?? 1;
          hours=jsonData[0]['hours']!=null?1/int.parse(jsonData[0]['hours'] as String):1;
        }
        if(_month.year==_currentDate.year && _month.month==_currentDate.month){
          querry="select sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_month.year}-${_month.month}-${_currentDate.day}' and date>='${_month.year}-${_month.month}-1' and tn=${user.tn};";
        }else{
        querry="select sum(hours) as hours from shedule where place_id='${user.placeID}' and date<='${_month.year}-${_month.month}-${Utility.monthDaysCount(_month.month, _month.year)}' and date>='${_month.year}-${_month.month}-1' and tn=${user.tn};";}

        jsonData=await Utility.getData(querry) ?? 1;
        int k=(jsonData[0]['hours'])!=null?int.parse(jsonData[0]['hours'] as String):0;
        hoursleft=j-k;
        hoursleft==0?hoursleft=1:null;
        hoursall=j;
        print("${hoursleft}, ${hoursall}");
    }

    querry="select ";
    plans.forEach((f)=>querry+="CEIL(${hours}*${f.dbName}) as ${f.dbName}, ");
    querry+="month from sales_plan where place_id='${user.placeID}' and month='${_month.year}-${_month.month}-1';";

    jsonData=await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error loading month");
      plans.forEach((f)=> _countsM[0].add('0'));
    }else{
      plans.forEach((f)=>_countsM[0].add(jsonData[0]['${f.dbName}'] as String));
    }

    querry="select ";
    plans.forEach((f)=>querry+="sum(${f.dbName}) as ${f.dbName}, ");
    if(widget.office){
      hoursall=Utility.monthDaysCount(_day.month, _day.year);
      hoursleft=hoursall-_day.day+1;
      querry+="date from sales_fact where place_id='${user.placeID}' and date<='${_month.year}-${_month.month}-${Utility.monthDaysCount(_month.month, _month.year)}' and date>='${_month.year}-${_month.month}-1';";
    }else{
      querry+="date from sales_fact where place_id='${user.placeID}' and tn=${user.tn} and date<='${_month.year}-${_month.month}-${Utility.monthDaysCount(_month.month, _month.year)}' and date>='${_month.year}-${_day.month}-1';";
    }

    jsonData=await Utility.getData(querry) ?? 1;

    if(jsonData==1){
      print("error loading month");
      plans.forEach((f)=> _countsM[1].add('0'));
    }else{
      plans.forEach((f)=>_countsM[1].add((jsonData[0]['${f.dbName}'] as String)==null?"0":(jsonData[0]['${f.dbName}'] as String)));
    }

        int hour=hoursall-hoursleft;
    plans.forEach((f)=>_countsM[2].add("${(int.parse(_countsM[1][plans.indexOf(f)])*100*hoursall)~/((int.parse(_countsM[0][0])!=0?int.parse(_countsM[0][0]):1)*(hour==0?1:hour))}%"));
    plans.forEach((f)=>_countsM[3].add("${(((int.parse(_countsM[0][plans.indexOf(f)])-int.parse(_countsM[1][plans.indexOf(f)]))*((widget.office||hoursleft==1)?1:8))~/(hoursleft))<0?0:(((int.parse(_countsM[0][plans.indexOf(f)])-int.parse(_countsM[1][plans.indexOf(f)]))*((widget.office||hoursleft==1)?1:8))~/(hoursleft))}"));
  }

  //=============
  //Загрузка данных
  //=============
  void loadData() async {
    await setData();
    if(_isLoadingDay){setState(() {_isLoadingDay=false;});}
  }

  void loadDataD() async{
    print("start set day!!!!!");
    await setDataD();
    print("aster await function");
    if(_isLoadingDay){setState(() {print("setDay ready");_isLoadingDay=false;});}
  }
  void loadDataM() async{
    await setDataM();
    if(_isLoadingMonth){setState(() {_isLoadingMonth=false;});}
  }

  @override

  void initState(){
    super.initState();
    _tabController=TabController(length: 2, initialIndex: 0, vsync: this);
    _currentDate=DateTime.now();
    _day=_currentDate;
    //_lastday=_currentDate;
    _month=_currentDate;
    loadData();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title:Center(
          child: Column(
            children: <Widget>[
              Text(widget.office?"Цели салона":"Личные цели", style: TextStyle(fontSize: 30)),
            ]
          ),
        ),
        actions: <Widget>[
          IconButton( 
            onPressed: (){
              print("сравнение по сотрудникам");
              //открыть сравнение по сотрудникам
            },
            icon:Icon(
              Icons.filter_list,
              size:30,  
            )
          )
        ],
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
                      top: BorderSide(color:Colors.green[700],width: 2),
                      right: BorderSide(color:Colors.green[700],width: 2),
                      left: BorderSide(color:Colors.green[700],width: 2),
                    ),
                  ),
                  tabs: [
                    Tab(//DAY
                      child:Container(
                        height:50,
                        width:500, 
                        alignment: Alignment.center,
                        decoration: _tabController.index==0?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.green[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
                        child:Text(
                          "На день",
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
                        decoration: _tabController.index==1?null:UnderlineTabIndicator(borderSide: BorderSide(width:2, color:Colors.green[700]),insets: EdgeInsets.fromLTRB(0,0,0,-2)),
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
                      Center(
                        child: Column(
                          children: <Widget>[//DAY
                            Card(//переключатель дня
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(//-1
                                    alignment: Alignment.center,
                                    onPressed: ()async{
                                      _lastday=_day;
                                      _day=_day.subtract(new Duration(days: 1));
                                      _isLoadingDay=true;
                                      setState(() {});
                                      await loadDataD();
                                    },
                                    icon: Icon(Icons.arrow_left, size: 30,),
                                  ),
                                  Container(//текст
                                    child:Text("${_day.day} ${Utility.month(_day.month)} ${_day.year}г.", style:TextStyle(fontSize: 20),),
                                  ),
                                  IconButton(//+1
                                    icon: Icon(Icons.arrow_right, size: 30,),
                                    onPressed: ()async{
                                      _lastday=_day;
                                      _day=_day.add(new Duration(days: 1));
                                      if(_currentDate.compareTo(_day)<0){_day=_currentDate;}
                                      else{
                                      _isLoadingDay=true;
                                      setState(() {});
                                      await loadDataD();
                                      }                        
                                    },
                                  ),
                                ],
                              )
                            ),
                            _isLoadingDay?Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green[100],
                                )
                            ):Center(//table
                              child:Container(
                                height:400,
                                width:500,
                                alignment: Alignment.center,
                                child:StickyHeadersTable(
                                  columnsLength: _columnsD.length,
                                  rowsLength: _plansNames.length,
                                  cellDimensions: CellDimensions(
                                    //contentCellHeight: 30
                                    
                                    ),
                                  cellFit: BoxFit.contain,
                                  legendCell: Container(
                                    height:30,
                                    width:120,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text("Название", style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: (){}),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                  columnsTitleBuilder: (i) => Container(                                    
                                    width:118,
                                    height:30,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text(_columnsD[i], style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: (){}
                                    ),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                  rowsTitleBuilder: (i) => Container(
                                    width:120,
                                    height:30,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text(_plansNames[i], style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: (){},
                                    ),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                  contentCellBuilder: (i, j) => Container(
                                    alignment: Alignment.center,
                                    width:118,
                                    height:30,
                                    padding: EdgeInsets.all(0),
                                    child:Text(_countsD[i][j],),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                )
                              )
                            )
                          ],
                        ),
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
                                    child:Text("${Utility.monthName(_month.month)} ${_month.year}г.",style:TextStyle(/*decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid, decorationThickness: 2,decorationColor: Colors.green,*/ fontSize: 20),),
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
                                backgroundColor: Colors.green[100],
                              )
                            ):Center(
                              child:Container(//table view
                                height:400,
                                width:500,
                                child:StickyHeadersTable(
                                  columnsLength: _columnsM.length,
                                  rowsLength: _plansNames.length,
                                  cellDimensions: CellDimensions(
                                    //contentCellHeight: 30
                                    ),
                                  cellFit: BoxFit.contain,
                                  legendCell: Container(
                                    height:30,
                                    width:85,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text("Название", style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: (){}),
                                    
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                  columnsTitleBuilder: (i) => Container(
                                    
                                    width:69,
                                    height:30,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text(_columnsM[i], style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: (){}
                                    ),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                  rowsTitleBuilder: (i) => Container(
                                    width:85,
                                    height:30,
                                    child:FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text(_plansNames[i], style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: (){},
                                  ),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                      ),
                                  contentCellBuilder: (i, j) => Container(
                                    alignment: Alignment.center,
                                    width:69,
                                    height:30,
                                    padding: EdgeInsets.all(0),
                                    child:Text(_countsM[i][j],),
                                    decoration: BoxDecoration(border: Border(
                                      top: BorderSide(color:Colors.green[800],width: 2),
                                      right: BorderSide(color:Colors.green[800],width: 2))),
                                  ),
                                )
                              )
                            ),
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


//===========================================================
//===========================================================
//===========================================================

//Планы офиса

//===========================================================
//===========================================================
//===========================================================
class PlanOffice extends StatefulWidget{
  PlanOffice({Key key}):super(key:key);
  @override
  _PlanOfficeState createState() => _PlanOfficeState();
}


class _PlanOfficeState extends State<Plan>{
  @override
  Widget build(BuildContext context){


    return Scaffold(

    );
  }
}

//===========================================================
//===========================================================
//===========================================================

//ОТправка факта продаж за день
//Отправка/редактирование планов на месяц

//===========================================================
//===========================================================
//===========================================================
class Fact extends StatefulWidget{//отправка факта продаж
bool setFacts;
  Fact({Key key, bool this.setFacts}):super(key:key);
  @override
  _FactState createState() => _FactState();
}


class _FactState extends State<Fact>{//отправка факта продаж
  
  Map< String, String> _facts={};
  var _currentdate;
  var _datenow;
  var _date;
  bool _isLoading=true;
  bool _isNotSended=true;
  Map<String,TextEditingController> _textController={};

  setFacts() async{
    _currentdate = new DateTime.now();
    _datenow = "${_currentdate.day} ${Utility.month(_currentdate.month)} ${_currentdate.year}";
    _date=widget.setFacts ? "${_currentdate.year}-${_currentdate.month}-${_currentdate.day}": "${_currentdate.year}-${_currentdate.month}-1";
    String querry;
    querry= widget.setFacts? "select * from sales_fact where place_id='${user.placeID}' and tn='${user.tn}' and date='${_date}';" : "select * from sales_plan where place_id='${user.placeID}' and month='${_date}';";  
    print(querry);
    var jsonData= await Utility.getData(querry) ?? 1;
    if(jsonData==1){
      print("error");
      plans.forEach((plans){
        var temp='0';
        _facts.putIfAbsent(plans.dbName, () => temp);
      });
    }else{
      plans.forEach((plans){
        _facts.putIfAbsent(plans.dbName,() => jsonData[0][plans.dbName]);
      });
    }
    print(_facts);
    plans.forEach((plans) {
      var textController = new TextEditingController(text: _facts[plans.dbName]);
       _textController.putIfAbsent(plans.dbName, () => textController);
    });
  }

  loadingData() async{
    await setFacts();
    

    if(_isLoading){
      setState(() {
      _isLoading=false;
    print("set state complete");

    });}
  }
  @override
  initState(){
    loadingData();
  }


  Widget build(BuildContext context){
    return Scaffold(//Здесь должна быть таблица со всеми параметрами, в шапке - Дата 
    appBar: AppBar(
      backgroundColor: Colors.green[700],
      title:Center(
        child: Column(
        children: <Widget>[
          widget.setFacts? Text("Факт продаж"): Text("Планы"),
          widget.setFacts? Text("на ${_datenow}"):Text("на ${Utility.monthName(_currentdate.month)} ${_currentdate.year}г."),
        ]
      )),
      actions: <Widget>[
        Container(
          width:70,
          height:50,
          child:IconButton(
            //color: Colors.lightGreen,
            onPressed: () async{
              print("pressed");
              if(_isNotSended){

                String querry;
                querry=widget.setFacts?"INSERT INTO sales_fact (place_id, tn, date ":"INSERT INTO sales_plan (place_id, month ";

                plans.forEach((plans){
                  querry+=", ${plans.dbName}";
                });

                querry+=widget.setFacts? " ) VALUES ('${user.placeID}','${user.tn}','${_date}'":" ) VALUES ('${user.placeID}', '${_date}'";

                plans.forEach((plans){
                  if(_textController[plans.dbName].text==''){
                    querry+= ', 0';
                  }else{querry+= ', ${_textController[plans.dbName].text}';}
                });

                querry+=") ON DUPLICATE KEY UPDATE ";

                plans.forEach((plans){
                  querry+="${plans.dbName}=";
                  if(_textController[plans.dbName].text==''){
                    querry+= '0 '; 
                  }else{querry+= '${_textController[plans.dbName].text},' ;}
                });

                querry=querry.replaceFirst(",",";",querry.length-1);

                _isNotSended=false;
                var jsonData=await Utility.getData(querry);
                print(jsonData);
                Navigator.pop(context);   
              }           
            },
            icon:Icon(
              Icons.check_box,
              size: 30.0,
            ),
          )
        )
      ],
    ),
    body:_isLoading ? Center(
      child: CircularProgressIndicator(
        //индикатор загрузки
      ),
      )
    :Center(
            child:SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 0,
        columns: [
          DataColumn(
            label:Text("Наименование"),
            numeric: false,
            
          ),
          DataColumn(
            label: Text("Факт продаж"),
            numeric: false,
          ),
        ],
        rows:plans
        .map(
          (data) => DataRow(
            cells: [
              DataCell(
                Text(data.strName),
              ),
              DataCell(
                TextField(
                  decoration: InputDecoration(
                    border:OutlineInputBorder(),
                    counterText: "",
                    contentPadding: EdgeInsets.fromLTRB(10,0,0,0)
                  ),
                  controller: _textController[data.dbName],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,\\-|\\|\\+|\\(|\\)|\\=|\\%|\\~|\\{|\\}|\\<|\\>|\\*|\\/|\\#]')),
                    //new WhitelistingTextInputFormatter(new RegExp("^\$|^(0|([1-9][0-9]{0,3}))?\$"))],
                  ],
                  maxLength: data.num_count,
                  onChanged: (text){
                    if(text.substring(0,1).toString()=='0')
                    {
                      var temp=text.substring(1);
                      _textController[data.dbName].text=temp;
                      final val = TextSelection.collapsed(offset: _textController[data.dbName].text.length);
                      _textController[data.dbName].selection = val;
                    }
                  },
                ),
              ),
            ]
          )
        ).toList(),
      )
      ),
      ),
    );
  }
}



//===========================================================
//===========================================================
//===========================================================

//Сравнение продаж

//===========================================================
//===========================================================
//===========================================================

class PlanDiff extends StatefulWidget{//сравнение продаж по продавцам
  final String user;
  final bool ruler;
  PlanDiff({Key key, this.user, this.ruler}):super(key:key);
  @override
  _PlanDiffState createState() => _PlanDiffState();
}


class _PlanDiffState extends State<PlanDiff>{//сравнение продаж по продавцам
  @override
  Widget build(BuildContext context){


    return Scaffold(//здесь должна быть таблица (горизонтальная) с продажами продавцов. В случае, если управляющий - плюс кнопка "редактировать"

    );
  }
}