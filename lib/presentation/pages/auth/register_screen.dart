import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/global/auth/auth.dart';
import '../../../domain/notifications/push_notification.dart';
import '../../widgets/progress_dialog.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String idScreen = "register";

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  TextEditingController nameTextEditing = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

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
              " Register as a Rider ",
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
                  controller: nameTextEditing,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: "Name",
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
                  keyboardType: TextInputType.emailAddress,
                  controller: phoneTextEditingController,
                  decoration: const InputDecoration(
                      labelText: "Phone",
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
                  keyboardType: TextInputType.emailAddress,
                  controller: emailTextEditingController,
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
                    labelText: "Password",
                    labelStyle: TextStyle(
                      fontSize: 14.8,
                    ), // TextStyle
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                  ),
                  style: const TextStyle(fontSize: 14.0),
                ), // TextField
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: () {
                    registerNewUser(context);
                  },
                  child: const SizedBox(
                    height: 50.0,
                    child: Center(
                      child: Text(
                        "Register",
                        style:
                            TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: const Text(
                    " Already have an Account? Login Here ",
                  ),
                )
              ]),
            ),
          ]),
        ));
  }

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Processing,Please wait...",
          );
        });

    final User? firebaseUser = (await fAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errmsg) {
      Navigator.pop(context);
      print(" Error : $errmsg");
    }))
        .user;

    String token = await PushNotificationService().getToken();

    if (firebaseUser != null) // user created
    {
      // save user info to database
      Map<String, dynamic> userDataMap = {
        "id": firebaseUser.uid,
        "name": nameTextEditing.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
        "token": token
      };
      await fireStore
          .collection("users_uber")
          .doc(firebaseUser.uid)
          .set(userDataMap);

      currentFirebaseUser = firebaseUser;

      Navigator.pop(context);
      print("Congratulations, your account has been created.");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const LoginScreen()));
    } else {
      Navigator.pop(context);
      print("Error : Account was not created");
    }
  }
}
