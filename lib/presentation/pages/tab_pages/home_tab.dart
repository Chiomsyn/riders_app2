import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/core/model/dir_details.dart';
import 'package:users_uberclone/domain/firebase/firebase_methods.dart';
import 'package:users_uberclone/domain/map/api_methods.dart';
import 'package:users_uberclone/presentation/pages/search_screen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../core/global/auth/auth.dart';
import '../../../core/model/avail_drivers.dart';
import '../../../data_handler/app_data.dart';
import '../../widgets/divider.dart';
import '../../widgets/progress_dialog.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  double bottomPaddingOfMap = 0;
  bool close = false;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  DirectionDetails? tripDirectionDetails;

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;

  String jobId = "";

  String _carType = "";

  Color? _poorCarColor = Colors.tealAccent[100];
  Color? _premiumCarColor = Colors.tealAccent[100];

  bool nearbyAvailableDriverKeysLoaded = false;

  BitmapDescriptor? nearByIcon;

  @override
  void initState() {
    super.initState();

    FirebaseMethods.getCurrentUserInfo();
    locatePosition();
  }

  Future<void> requestForDrivers(String carType) async {
    jobId = await FirebaseMethods.saveRideRequest(context, carType);

    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      close = false;
    });
  }

  Future<void> cancelRideRequest() async {
    await FirebaseMethods.cancelRequest(jobId);
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

  resetApp() {
    setState(() {
      close = false;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 300.0;
      requestRideContainerHeight = 0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 290.0;
      bottomPaddingOfMap = 250.0;
      close = true;
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Position? currentPosition;

  LocationPermission? permission;

  bool serviceEnabled = true;

  Future<void> locatePosition() async {
    // Test if location services are enabled.

    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    if (mounted) {
      await ApiMethods.searchCoordinateAddress(position, context);
    }

    print("jelly");

    getAvailableDrivers();

    // setState(() {
    //
    // });
  }

  @override
  void dispose() {
    newGoogleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    final address = Provider.of<AppData>(context);
    return Scaffold(
        // appBar: AppBar(),
        body: Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          polylines: polylineSet,
          markers: markersSet,
          circles: circlesSet,
          onMapCreated: (GoogleMapController controller) async {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            // applyDarkTheme(newGoogleMapController);

            await locatePosition();

            setState(() {
              bottomPaddingOfMap = 300;
            });
          },
        ),
        close
            ? Positioned(
                top: 30.0,
                left: 22.0,
                child: GestureDetector(
                    onTap: () => resetApp(),
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
            child: Container(
              height: searchContainerHeight,
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
                      style:
                          TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const SearchScreen()));

                        if (res == "obtainDirection") {
                          displayRideDetailsContainer();
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
                              Text(" Search Drop Off/ Pick Up ")
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
                                      color: Colors.black54, fontSize: 12.0),
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
        Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
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
                  padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                  child: Column(children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _carType = "premium";
                          _premiumCarColor = Colors.black;
                          _poorCarColor = Colors.tealAccent[100];
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        color: _premiumCarColor,
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
                                const Text("Premium Car",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Brand-Bold",
                                    )),
                                // Text
                                Text(
                                  (tripDirectionDetails != null)
                                      ? tripDirectionDetails!.distanceText ??
                                          '0km'
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
                              (tripDirectionDetails != null)
                                  ? '₦${ApiMethods.calculateFares(tripDirectionDetails!, type: "premium")}'
                                  : '₦0.0',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _carType = "poor";
                          _poorCarColor = Colors.black;
                          _premiumCarColor = Colors.tealAccent[100];
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        color: _poorCarColor,
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
                                const Text("Poor Car",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Brand-Bold",
                                    )),
                                // Text
                                Text(
                                  (tripDirectionDetails != null)
                                      ? tripDirectionDetails!.distanceText ??
                                      '\$0km'
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
                              (tripDirectionDetails != null)
                                  ? '₦${ApiMethods.calculateFares(tripDirectionDetails!)}'
                                  : '₦0.0',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                           if(_carType == ""){

                           }else{
                             print(tokenList);
                             requestForDrivers(_carType);
                           }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.yellowAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11.0),
                                side: const BorderSide(color: Colors.yellow)),
                            disabledForegroundColor: Colors.blue[800],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            )),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
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
            height: requestRideContainerHeight,
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
                    cancelRideRequest();
                    resetApp();
                  },
                  child: Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26.0),
                      border: Border.all(width: 2.0, color: Colors.grey[300]!),
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
      ],
    ));
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait ...",
            ));
    var details =
        await ApiMethods.placeDirectionDetails(pickUpLatLng, dropOffLatLng);
    tripDirectionDetails = details;
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylineResult =
        polylinePoints.decodePolyline(details!.encodedPoints!);

    pLineCoordinates.clear();
    if (decodePolylineResult.isNotEmpty) {
      for (var pointLatLng in decodePolylineResult) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          polylineId: const PolylineId("PolylineID"));

      polylineSet.add(polyline);
    });
    // makes the polines fit in the map to avoid scrolling
    LatLngBounds? latlngBounds;

    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latlngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latlngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latlngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latlngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latlngBounds, 70));

    Marker picUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: 'my Location'),
        position: pickUpLatLng,
        markerId: const MarkerId("pickUpId"));

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: 'DropOff Location'),
        position: dropOffLatLng,
        markerId: const MarkerId("dropOffId"));

    setState(() {
      markersSet.add(picUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeColor: Colors.blueAccent,
        strokeWidth: 4,
        circleId: const CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeColor: Colors.deepPurple,
        strokeWidth: 4,
        circleId: const CircleId("dropOffId"));

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });

//     double totalDistance = 0.0;
//     String placeDistance = '';
//
// // Calculating the total distance by adding the distance
// // between small segments
//     for (int i = 0; i < pLineCoordinates.length - 1; i++) {
//       totalDistance += _coordinateDistance(
//         pLineCoordinates[i].latitude,
//         pLineCoordinates[i].longitude,
//         pLineCoordinates[i + 1].latitude,
//         pLineCoordinates[i + 1].longitude,
//       );
//     }
//
// // Storing the calculated total distance of the route
//     setState(() {
//       placeDistance = totalDistance.toStringAsFixed(2);
//       print('DISTANCE: $placeDistance km');
//     });
  }

  void getAvailableDrivers() {
    // get the collection reference or query
    var collectionReference = fireStore.collection('available_drivers');

    double radius = 50;
    String field = 'position';

    // Create a geoFirePoint
    GeoFirePoint center = geo.point(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude);

    geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field)
        .listen((event) {
      for (var val in event) {

        NearByAvailDrivers nearDrivers = NearByAvailDrivers();
        Map<String, dynamic> c = val.data() as Map<String, dynamic>;

        GeoPoint p = c["position"]["geopoint"];

        nearDrivers.key = c["position"]["geohash"];
        nearDrivers.latitude = p.latitude;
        nearDrivers.longitude = p.longitude;
        nearDrivers.id = c["id"];
        nearDrivers.token = c["token"];

        tokenList.add(c["token"]);

        listNearDrivers.add(nearDrivers);
      }

      updateAvailableDriversOnMap(listNearDrivers);
    });
  }

  void updateAvailableDriversOnMap(List<NearByAvailDrivers> point) {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMarkers = <Marker>{};

    for (NearByAvailDrivers p in point) {
      LatLng driverAvailablePosition = LatLng(p.latitude!, p.longitude!);

      Marker marker = Marker(
        markerId: MarkerId('driver${p.key}'),
        position: driverAvailablePosition,
        icon: nearByIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        rotation: 0,
      );

      tMarkers.add(marker);
    }

    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(10, 10));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_ios.png")
          .then((value) {
        nearByIcon = value;
      });
    }
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
