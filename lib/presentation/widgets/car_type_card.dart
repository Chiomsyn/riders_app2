import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_handler/app_data.dart';

class SelectCarTypeCard extends StatelessWidget {
  int trip;
  VoidCallback onClick;
  Color? cardColor;
  String carType;
  String carTypeText;
  SelectCarTypeCard(
      {Key? key,
      required this.trip,
      required this.carTypeText,
      required this.carType,
      required this.onClick,
      required this.cardColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final address = Provider.of<AppData>(context);

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        color: cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Image.asset(
              "assets/images/taxi.png",
              height: 50.0,
              width: 80.0,
            ),
            const SizedBox(
              width: 16.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(carTypeText,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Brand-Bold",
                    )),
                // Text
                Text(
                  (address.tripDirectionDetails != null)
                      ? address.tripDirectionDetails!.distanceText ?? '0km'
                      : '',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
            Text(
              (address.tripDirectionDetails != null)
                  ? '₦${trip.toString()}'
                  : '₦0.0',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
