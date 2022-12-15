import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/global/auth/auth.dart';
import '../../../data_handler/app_data.dart';
import '../auth/login_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    final address = Provider.of<AppData>(context);
    return Center(
      child: ElevatedButton(
          child: const Text("Sign Out"),
          onPressed: () {
            fAuth.signOut();
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const LoginScreen()));
          }),
    ); // Center
  }
}
