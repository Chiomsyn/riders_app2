import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:users_uberclone/presentation/pages/auth/login_screen.dart';
import 'package:users_uberclone/presentation/pages/auth/register_screen.dart';
import 'package:users_uberclone/presentation/pages/main_screen.dart';
import 'package:provider/provider.dart';

import 'data_handler/app_data.dart';

void main() async
{
  // setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppData())
        ],
        child: const MyApp(
        ),
      ));
}

class MyApp extends StatefulWidget {


  const MyApp({super.key});

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Users App',
      theme : ThemeData (
        fontFamily : "Brand Bold" ,
        primarySwatch : Colors.blue ,
        visualDensity : VisualDensity.adaptivePlatformDensity ,
      ),
      initialRoute : LoginScreen.idScreen ,
      routes :
      {
        RegisterScreen.idScreen : ( context ) => RegisterScreen( ) ,
        LoginScreen.idScreen : ( context ) => LoginScreen( ) ,
        MainScreen.idScreen : ( context ) => MainScreen( ) ,
      } ,
    );
  }
}

