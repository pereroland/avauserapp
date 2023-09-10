import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as Location;

import 'package:avauserapp/components/language/allTranslations.dart';

Future<Map?> getLocation(context) async {
  Map? map;
  var currentLocation;
  var location = new Location.Location();

  try {
    currentLocation = await location.getLocation();
    List<Placemark> addresses = await GeocodingPlatform.instance
        .placemarkFromCoordinates(
            currentLocation.latitude, currentLocation.longitude);
    Placemark placeMark = addresses.first;
    String shortAddress = getShortAddress(placeMark);
    String cityName =
        placeMark.locality ?? placeMark.administrativeArea ?? "City";
    String countryName = placeMark.country!;
    String stateName = placeMark.administrativeArea ?? "State";
    map = {
      "Latitude": currentLocation.latitude,
      "Longitude": currentLocation.longitude,
      "city": cityName,
      "country": countryName,
      "state": stateName,
      "shortAddress": shortAddress
    };
    return map;
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      _showErrorDialog(
          "go to settings and allow your location access for better use.",
          context);
    }
    currentLocation = null;
    return map;
  }
}

String getShortAddress(Placemark placeMark) {
  String completeAddress = "";
  if (placeMark.name != placeMark.locality) {
    completeAddress = completeAddress.appendIfNotNull(placeMark.name);
  }
  completeAddress = completeAddress
      .appendIfNotNull(placeMark.street)
      .appendIfNotNull(placeMark.subThoroughfare)
      .appendIfNotNull(placeMark.thoroughfare)
      .appendIfNotNull(placeMark.subLocality);
  if (completeAddress.length >= 2) {
    completeAddress =
        completeAddress.substring(0, completeAddress.length - 2).trim();
  }
  return completeAddress;
}

void _showErrorDialog(String errorMessage, context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(errorMessage),
        actions: <Widget>[
          MaterialButton(
            child: Text(allTranslations.text('OK')),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

extension StringExtensions on String {
  String appendIfNotNull(String? string) {
    if (string == null || string.isEmpty || string == "") {
      return this;
    } else {
      return this + "$string, ";
    }
  }
}
