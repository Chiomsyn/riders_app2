import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/data_handler/app_data.dart';
import 'package:users_uberclone/domain/map/api_methods.dart';
import 'package:uuid/uuid.dart';
import '../../core/model/place_predictions.dart';
import '../widgets/divider.dart';
import '../widgets/map/prediction_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();

  String? _sessionToken;
  var uuid = const Uuid();

  List<PlacePredictions> placePredictionsList = [];

  void onSearchChanged(String placeName) async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    placePredictionsList =
        await ApiMethods.searchAddress(placeName, _sessionToken!);
    print(placePredictionsList);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final address = Provider.of<AppData>(context);

    String? placeAddress = address.pickUpLocation!.placeName ?? '';

    pickUpTextEditingController.text = placeAddress ?? '';

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
      children: [
        Container(
          height: 215.0,
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7))
          ]),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25.0, top: 50.0, right: 25.0, bottom: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 5.0),
                Stack(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back)),
                    const Center(
                      child: Text(
                        " Set Drop Off ",
                        style:
                            TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/pickicon.png",
                      height: 16.0,
                      width: 16.0,
                    ),
                    const SizedBox(
                      width: 18.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                  hintText: " PickUp Location ",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 11.0,
                                      top: 8.0,
                                      bottom: 8.0))), // TextField
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/desticon.png",
                      height: 16.0,
                      width: 16.0,
                    ),
                    const SizedBox(
                      width: 18.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                              onChanged: (val) => onSearchChanged(val),
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                  hintText: "Where To?",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 11.0,
                                      top: 8.0,
                                      bottom: 8.0))), // TextField
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        (placePredictionsList.isNotEmpty)
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListView.separated(
                  padding: const EdgeInsets.all(0.0),
                  itemBuilder: (context, index) {
                    return PredictionTile(
                      placePredictions: placePredictionsList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const DividerWidget(),
                  itemCount: placePredictionsList.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                ), // ListView . separated
              ) // Padding
            : Container(),
      ],
    )));
  }
}
