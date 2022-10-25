import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:users_uberclone/presentation/pages/auth/register_screen.dart';

import '../../../core/global/auth/auth.dart';
import '../../widgets/progress_dialog.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String idScreen = "login" ;
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 35.0,
            ),
            const Image(
              image: AssetImage("assets/images/logo.png"),
              width: 390.0,
              height: 250.0,
              alignment: Alignment.center,
            ), // Image
            const SizedBox(
              height: 1.0,
            ),

            const Text(
              " Login as a Rider ",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ), // Text
            const SizedBox(
              height: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: [
                const SizedBox(
                  height: 1.0,
                ),
                TextField(
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: " Email ",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ), // TextStyle
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.8,
                      )),
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(
                  height: 1.0,
                ),
                TextField(
                  controller: passwordTextEditingController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: " Password ",
                    labelStyle: TextStyle(
                      fontSize: 14.8,
                    ), // TextStyle
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                  ),
                  style: TextStyle(fontSize: 14.0),
                ), // TextField
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: () {
                      logInUser(context);

                  },
                  child: const SizedBox(
                    height: 50.0,
                    child: Center(
                      child: Text(
                        " Login ",
                        style:
                        TextStyle(fontSize: 18.0, fontFamily: " Brand Bold "),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil ( context , RegisterScreen.idScreen , ( route ) => false ) ;

                  },
                  child: const Text(
                    " Do not have an Account ? Register Here ",
                  ),
                )
              ]),
            ),
          ]),
        ));
  }

  void logInUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Processing,Please wait...",
          );
        });

    final User? firebaseUser = (await fAuth
        .signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text)
        .catchError((errmsg) {
      Navigator.pop(context);
      print(" Error : $errmsg");
    }))
        .user;
    if (firebaseUser != null) // user created
        {
      currentFirebaseUser = firebaseUser;
      Navigator.pop(context);
      print("Congratulations, Login Successfuly");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const MainScreen()));
    } else {
      Navigator.pop(context);
      print("Error : Account was not created");
    }
  }
}
