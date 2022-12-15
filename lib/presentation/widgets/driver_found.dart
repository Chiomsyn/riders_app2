import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_handler/app_data.dart';
import 'custom_btn.dart';
import 'custom_text.dart';

class DriverFound extends StatelessWidget {
  const DriverFound({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return SizedBox(
      height: 400,
      child: DraggableScrollableSheet(
          builder: (BuildContext context, myscrollController) {
        return Container(
            decoration: BoxDecoration(color: Colors.white,
//                        borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(20),
//                            topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(.8),
                      offset: const Offset(3, 2),
                      blurRadius: 7)
                ]),
            child: ListView(
              controller: myscrollController,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: "7 MIN AWAY",
                      color: Colors.green,
                      weight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: appData.driverModel.photo == null,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(40)),
                        child: const CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 45,
                          child: Icon(
                            Icons.person,
                            size: 65,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: appData.driverModel.photo != null,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(40)),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              NetworkImage(appData.driverModel.photo!),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(text: appData.driverModel.name ?? "Nada"),
                  ],
                ),
                const SizedBox(height: 10),
                appData.stars(
                    rating: appData.driverModel.rating!,
                    votes: appData.driverModel.votes!),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.directions_car),
                        // add car
                        label: Text(appData.driverModel.phone ?? "Nan")),
                    CustomText(
                      //add plate number
                      text: appData.driverModel.email!,
                      color: Colors.deepOrange,
                    )
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomBtn(
                      text: "Call",
                      onTap: () {},
                      bgColor: Colors.green,
                      shadowColor: Colors.green,
                    ),
                    CustomBtn(
                      text: "Cancel",
                      onTap: () {},
                      bgColor: Colors.red,
                      shadowColor: Colors.redAccent,
                    ),
                  ],
                )
              ],
            ));
      }),
    );
  }
}
