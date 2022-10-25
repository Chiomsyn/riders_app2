import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_uberclone/core/model/users.dart';

import '../../model/avail_drivers.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
final FirebaseFirestore fireStore = FirebaseFirestore.instance;
User? currentFirebaseUser;
UsersModel? currentUserInfo;

var data = fireStore.collection("available_drivers").doc(currentFirebaseUser!.uid);

final geo = Geoflutterfire();

StreamSubscription<Position>? homeTabPageStreamSubscription;

Stream<List<DocumentSnapshot>>? stream;

List<NearByAvailDrivers> listNearDrivers = [];

List<String> tokenList = [];