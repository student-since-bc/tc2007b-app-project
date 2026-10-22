import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

void main(){
  runApp(const App());
}

class App extends StatelessWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '', //TODO
      theme: appTheme,
      initialRoute: Routes.shell,
      routes: appRoutes,
    ); // Material
  } // build
} // App
