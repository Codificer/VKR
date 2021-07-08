import 'package:flutter/material.dart';
//Классы виджетов
import 'user.dart';
import 'connection.dart';
import 'login.dart';
import 'main_u.dart';


//String username, usertn, userplace;
//bool userruler;

User user;
//var url = 'https://codificer.000webhostapp.com/get.php';
//Имя Ф. пользователя для отображения (чтобы не хранить в приложении вечно)
//хотя можно и в сеттинги записать

List <Plans> plans;

printUser(){
    print("=======Далее данные пользователя:========");
    print(user);
    print(user.name);
    print(user.tn);
    print(user.place);
    print(user.ruler);
    print(user.placeID);
    print("======Конец данных пользователя========");
}


void main() {
  plans=Plans.getPlans();
  //read settings
  
  //if login is = go switch betwin can rule or not
  //else - run login
  return(
    runApp(
      MaterialApp(
        title: "Задачи Мегафон",
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (context) => new SplashScreen(),
          '/login': (context) => new LoginPage(title:"Добро пожаловать!"),
          '/main': (context) => new MainPageU(),
        },
        )
      )
    );
}

//splashcreen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Utility.readSavedSettings(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: Center(
        child: Icon(Icons.ac_unit, size: 150, color: Colors.blue,)
      ),
    );
  }
}