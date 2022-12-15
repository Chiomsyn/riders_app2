import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_handler/app_data.dart';
import 'custom_text.dart';

class DriverNotFound extends StatefulWidget {
  const DriverNotFound({super.key});

  @override
  State<DriverNotFound> createState() => _DriverNotFoundState();
}

class _DriverNotFoundState extends State<DriverNotFound> {
  @override
  Widget build(BuildContext context) {
    final address = Provider.of<AppData>(context);
    return SizedBox(
      height: 200,
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "DRIVERS NOT FOUND! \n TRY REQUESTING AGAIN"),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      address.show == Show.idleTime;
                    });
                    address.resetApp(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.0),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20.0,
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
