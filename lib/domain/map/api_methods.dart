import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/domain/firebase/firebase_methods.dart';
import '../../core/global/maps/base_urls.dart';
import '../../core/global/maps/map_key.dart';
import '../../core/model/address.dart';
import '../../core/model/dir_details.dart';
import '../../core/model/place_predictions.dart';
import '../../data/api_services.dart';
import '../../data_handler/app_data.dart';
import '../../core/global/maps/base_urls.dart' as geo;
import '../../presentation/widgets/progress_dialog.dart';

class ApiMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String? st1 = '', st2 = '', st3 = '', st4 = '';

    String url =
        "${geo.geoCodeBaseUrl}?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      // placeAddress = response["results"][0]["formatted_address"];

      st1 = response["results"][0]["address_components"][2]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][1]["long_name"];
      st4 = response["results"][0]["address_components"][1]["long_name"];
      placeAddress = "${st1!}, ${st2!}, ${st3!}, ${st4!}";

      Address userPickUpAddress = Address(placeName: '');
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocation =
          userPickUpAddress;
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> placeDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    DirectionDetails directionDetails = DirectionDetails();

    String request =
        "$placeDirDetailsBaseUrl?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    try {
      var res = await RequestAssistant.getRequest(request);

      // Navigator.pop(context);

      if (res == "failed") {
        return null;
      }

      if (res["status"] == "OK") {
        directionDetails.distanceValue =
            res['routes'][0]['legs'][0]['distance']['value'];
        directionDetails.durationValue =
            res['routes'][0]['legs'][0]['duration']['value'];
        directionDetails.distanceText =
            res['routes'][0]['legs'][0]['distance']['text'];
        directionDetails.durationText =
            res['routes'][0]['legs'][0]['duration']['text'];
        directionDetails.encodedPoints =
            res["routes"][0]["overview_polyline"]["points"];
      }
    } catch (e) {
      print(e);
    }
    return directionDetails;
  }

  static Future<List<PlacePredictions>> searchAddress(
      String placeName, String sessionToken) async {
    List<PlacePredictions> placePredictionsList = [];
    // String type = "address";
    if (placeName.length > 1) {
      String request =
          '$autoCompleteBaseUrl?input=$placeName&key=$mapKey&sessiontoken=$sessionToken&components=country:ng';

      try {
        var res = await RequestAssistant.getRequest(request);

        if (res == "failed") {
          return [];
        }

        if (res["status"] == "OK") {
          var predictions = res["predictions"];

          var placeList = (predictions as List)
              .map((e) => PlacePredictions.fromJson(e))
              .toList();
          placePredictionsList = placeList;
        }
      } catch (e) {
        print(e);
      }
    }
    return placePredictionsList;
  }

  static Future<void> selAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: " Setting Dropoff , Please wait ... ",
            ));
    String request = '$selAddDetailsBaseUrl?place_id=$placeId&key=$mapKey';

    try {
      var res = await RequestAssistant.getRequest(request);

      Navigator.pop(context);

      if (res == "failed") {
        return;
      }

      if (res["status"] == "OK") {
        Address address = Address(
          placeName: res['result']['name'],
          placeId: placeId,
          latitude: res['result']["geometry"]["location"]["lat"],
          longitude: res['result']["geometry"]["location"]["lng"],
        );
        Provider.of<AppData>(context, listen: false).updateDropOffLocation =
            address;
        Navigator.pop(context, "obtainDirection");
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> calculateFares(
      DirectionDetails directionDetails, context) async {
    // in terms usd
    // double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    // double distanceTraveledFare = (directionDetails.distanceValue! / 1000) * 0.20;

    Map<String, dynamic> data = await FirebaseMethods.getRideAddedPrice();
    double nairaCharge = 0;
    double premiumCharge = 0;
    double surgePrice = 0;
    int promoPercentage = 0;

    if (data.isNotEmpty) {
      if (data["priceDistanceAndTime"] != "") {
        nairaCharge = double.parse(data["priceDistanceAndTime"]);
      }

      if (data["addedPremiumPrice"] != "") {
        premiumCharge = double.parse(data["addedPremiumPrice"]);
      }

      if (data["surgePrice"] != "") {
        surgePrice = double.parse(data["surgePrice"]);
      }
    }

    double timeTraveledFare = ((directionDetails.durationValue ?? 0) / 60);

    double distanceTraveledFare =
        ((directionDetails.distanceValue ?? 0) / 1000);
    double totalFaredAmount = timeTraveledFare + distanceTraveledFare;

    // 1$ = 710 Naira
    double totalLocalAmount = (totalFaredAmount * nairaCharge) + surgePrice;

    Provider.of<AppData>(context, listen: false).premiumTripPrice =
        (totalLocalAmount + premiumCharge).truncate();

    Provider.of<AppData>(context, listen: false).poorTripPrice =
        totalLocalAmount.truncate();
  }
}
