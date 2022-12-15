const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

exports.locationReachedNotification = functions.https.onRequest(
  async (request, response) => {
    const info = J;
    const riderId = info["riderId"];
    const driverId = info["driverId"];
    const requestId = info["requestId"];

    if (riderId === null) {
      console.log("USER NAME IS EMPTY");
      console.log("USER NAME IS EMPTY");
    } else {
      console.log(`the user is ${riderId}`);
      console.log(`the user is ${riderId}`);
    }

    const user = await db.collection("users").doc(riderId).get();
    const token = user.data()?.token;

    try {
      const payload = {
        notification: {
          title: "Your ride is here",
          body: `Hey there, your ride is at the pickup location`,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          riderId: riderId,
          requestId: requestId,
          driverId: driverId,
          type: "DRIVER_AT_LOCATION",
        },
      };

      console.log("Token is" + token);
      fcm.sendToDevice([token], payload).catch((error) => {
        response.status(500).send(error);
      });
      response.send("notification sent");
    } catch (error) {
      console.log("ERROR:: " + error);
      response.send("Notification not sent").status(500);
    }
  }
);

exports.rideAcceptedNotification = functions.firestore
  .document("ride_requests/{requestId}")
  .onUpdate(async (snapshot) => {
    const rideRequest = snapshot.after.data();

    if (rideRequest.requestStatus === "Accepted") {
      const tokens = [];

      const users = await db
        .collection("users_uber")
        .where("id", "==", rideRequest.rider_id)
        .get();

      users.forEach((document) => {
        const userData = document.data();

        tokens.push(userData.token);
      });

      const payload = {
        notification: {
          title: "Ride request accepted",
          body: `Hey there, your ride is on the way`,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          destination: rideRequest.dropoff_address,
          distance_text: rideRequest.distance.text,
          distance_value: rideRequest.distance.value,
          destination_latitude: rideRequest.dropoff.latitude,
          destination_longitude: rideRequest.dropoff.longitude,
          id: rideRequest.request_id,
          driverId: rideRequest.driverId,
          type: "REQUEST_ACCEPTED",
        },
      };

      console.log(`NUMBER OF TOKENS IS: ${tokens.length}`);

      return fcm.sendToDevice(tokens, payload);
    } else if (
      rideRequest.driverId === "Waiting" &&
      rideRequest.requestStatus !== "Cancelled"
    ) {
      const dInfo = rideRequest.driversInfo;

      return sendNot(rideRequest, snapshot.after);
    } else {
      return;
    }
  });

exports.rideRequestNotification = functions.firestore
  .document("ride_requests/{requestId}")
  .onCreate(async (snapshot) => {
    const rideRequest = snapshot.data();

    return sendNot(rideRequest, snapshot);
  });

async function sendNot(rideRequest, snapshot) {
  let tokens = "";
  let id = "";

  let dInfo = Array();

  dInfo = rideRequest.driversInfo;

  if (dInfo.length > 0) {
    dInfo.map((o, i) => {
      if (i == 0) {
        id = o[`driverId`];
        tokens = o[`tokenId`];
        console.log(tokens);
      }
    });

    dInfo.shift();

    const payload = {
      notification: {
        title: "Ride request",
        body: `${rideRequest.riderName} is looking for a ride to ${rideRequest.dropoffAddress}`,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        riderName: rideRequest.riderName,
        dropoffAddress: rideRequest.dropoffAddress,
        // price: rideRequest.price,
        // distance_text: rideRequest.distance.text,
        // distance_value: rideRequest.distance.duration,
        // destination_latitude: rideRequest.dropoff.latitude,
        // destination_longitude: rideRequest.dropoff.longitude,
        // user_latitude: rideRequest.pickUp.latitude,
        // user_longitude: rideRequest.pickUp.longitude,
        id: rideRequest.requestId,
        userId: rideRequest.riderId,
        driverId: id,
        type: "RIDE_REQUEST",
      },
    };

    const options = {
      priority: "high",
    };
    try {
      await fcm.sendToDevice(tokens, payload, options).then(
        (onfulfilled) => console.log(onfulfilled), // shows "done!" after 1 second
        (onrejected) => console.log(onrejected),
        () => {
          console.log("i had to fall to finally see..");
        }
      );
    } catch (error) {
      console.log("Error sending Notifications");
    }

    snapshot.ref.update({
      driverId: id,
      requestStarted: true,
      driversInfo: dInfo,
    });
  } else {
    snapshot.ref.update({
      driverId: "Waiting",
      requestStarted: false,
      requestStatus: "NoReply",
    });
  }
}
