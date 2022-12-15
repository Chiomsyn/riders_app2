import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/core/global/auth/auth.dart';
import 'package:users_uberclone/domain/firebase/firebase_methods.dart';
import 'package:users_uberclone/domain/map/api_methods.dart';
import 'package:users_uberclone/presentation/pages/search_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../data_handler/app_data.dart';
import '../../../domain/notifications/push_notification.dart';
import '../../widgets/car_type_card.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/divider.dart';
import '../../widgets/driver_found.dart';
import '../../widgets/driver_not_found.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation colorAnimation;
  late Animation sizeAnimation;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  bool nearbyAvailableDriverKeysLoaded = false;

  @override
  void initState() {
    super.initState();

    FirebaseMethods.getCurrentUserInfo();

    //    final _token = Provider.of<AppData>(context, listen: false);

    // _token.storeTokens().then((value) => print("hjhgggg"));

    // controller =
    //     AnimationController(vsync: this, duration: Duration(seconds: 2));
    // colorAnimation =
    //     ColorTween(begin: Colors.blue, end: Colors.yellow).animate(controller);
    // sizeAnimation = Tween<double>(begin: 100.0, end: 200.0).animate(controller);
  }

  static const colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Signatra',
  );

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void dispose() {
    Provider.of<AppData>(context, listen: false)
        .newGoogleMapController!
        .dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final address = Provider.of<AppData>(context);
    address.createIconMarker(context);
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: address.bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: address.polylineSet,
            markers: address.markersSet,
            circles: address.circlesSet,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              address.newGoogleMapController = controller;

              // applyDarkTheme(newGoogleMapController);

              await address.locatePosition(context);

              setState(() {
                address.bottomPaddingOfMap = 300;
              });
            },
          ),
          address.close
              ? Positioned(
                  top: 30.0,
                  left: 22.0,
                  child: GestureDetector(
                      onTap: () => address.resetApp(context),
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
                      )))
              : Container(),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 160),
              child: Visibility(
                visible: address.show == Show.idleTime,
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6.0),
                        const Text(
                          " Hi there,",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        const Text(
                          " Where to?",
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: "Brand-Bold"),
                        ),
                        const SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => const SearchScreen()));

                            setState(() {});

                            if (res == "obtainDirection") {
                              await ApiMethods.calculateFares(
                                  address.tripDirectionDetails!, context);
                              address.displayRideDetailsContainer(context);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text("Search Drop Off/ Pick Up")
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.home,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 12.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address.pickUpLocation!.placeName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    const Text(
                                      "Your living home address",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const DividerWidget(),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.work,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Add Work",
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  "Your Working address",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedSize(
                curve: Curves.bounceInOut,
                duration: const Duration(milliseconds: 160),
                child: Visibility(
                  visible: address.show == Show.rideDetailsContainer,
                  child: Container(
                    height: 290,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 10.0),
                      child: Column(children: [
                        Visibility(
                            visible: address.premiumCarsAvail,
                            child: SelectCarTypeCard(
                              onClick: () {
                                setState(() {
                                  address.carType = "premium car";
                                });
                                address.showSelectedCarTypeDriversOnMap();
                              },
                              cardColor: address.carType == "premium car"
                                  ? Colors.black
                                  : Colors.tealAccent[100],
                              carTypeText: "Premium Car",
                              carType: 'premium',
                              trip: address.premiumTripPrice,
                            )),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Visibility(
                            visible: address.poorCarsAvail,
                            child: SelectCarTypeCard(
                              onClick: () {
                                setState(() {
                                  address.carType = "poor car";
                                });
                                address.showSelectedCarTypeDriversOnMap();
                              },
                              cardColor: address.carType == "poor car"
                                  ? Colors.black
                                  : Colors.tealAccent[100],
                              carTypeText: "Poor Car",
                              carType: 'poor',
                              trip: address.poorTripPrice,
                            )),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              children: const [
                                Icon(
                                  FontAwesomeIcons.moneyCheckDollar,
                                  size: 18.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Text("Cash"),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black54,
                                  size: 16.0,
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(17.0),
                          child: ElevatedButton(
                              onPressed: () {
                                if (address.carType == "") {
                                } else {
                                  if (address.carType == "poor") {
                                    address.requestForDrivers(
                                        address.carType!,
                                        context,
                                        address.tripDirectionDetails!
                                                .distanceText ??
                                            '',
                                        address.tripDirectionDetails!
                                                .durationText ??
                                            '',
                                        address.poorTripPrice.toString());
                                  } else {
                                    address.requestForDrivers(
                                        address.carType!,
                                        context,
                                        address.tripDirectionDetails!
                                                .distanceText ??
                                            '',
                                        address.tripDirectionDetails!
                                                .durationText ??
                                            '',
                                        address.premiumTripPrice.toString());
                                  }
                                  address.listenToRequest();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.yellowAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11.0),
                                    side:
                                        const BorderSide(color: Colors.yellow)),
                                disabledForegroundColor: Colors.blue[800],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 26.0,
                                  )
                                ],
                              )),
                        ))
                      ]),
                    ),
                  ),
                ),
              )),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Visibility(
              visible: address.show == Show.requestRideContainer,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(children: [
                    const SizedBox(height: 12.0),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Requesting a Ride',
                            textAlign: TextAlign.center,
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                          ),
                          ColorizeAnimatedText(
                            'Please wait...',
                            textAlign: TextAlign.center,
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                          ),
                          ColorizeAnimatedText(
                            'Finding a driver...',
                            textAlign: TextAlign.center,
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          // print("Tap Event");
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 22.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        address.cancelRideRequest();
                        address.resetApp(context);
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border:
                              Border.all(width: 2.0, color: Colors.grey[300]!),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 26.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Cancel Ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Visibility(
              visible: address.show == Show.lookingForDriver,
              child: Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7)),
                  ],
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: "Looking for driver"),
                    CustomText(
                        text: "Waiting for driver ${address.driverModel.name}"),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Visibility(
              visible: address.show == Show.driverNotFound,
              child: AnimatedSize(
                curve: Curves.bounceInOut,
                duration: Duration(milliseconds: 160),
                child: Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7)),
                      ],
                    ),
                    child: DriverNotFound()),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Visibility(
              visible: address.show == Show.driverFound,
              child: DriverFound(),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Visibility(
              visible: address.show == Show.driverFound,
              child: Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7)),
                  ],
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: "Driver have been assigned"),
                    CustomText(text: "Hi user"),
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  // double _coordinateDistance(lat1, lon1, lat2, lon2) {
  //   var p = 0.017453292519943295;
  //   var c = cos;
  //   var a = 0.5 -
  //       c((lat2 - lat1) * p) / 2 +
  //       c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  //   return 12742 * asin(sqrt(a));
  // }
}
