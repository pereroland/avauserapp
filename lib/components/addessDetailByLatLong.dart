import 'addressFilter.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

getUserLocationDetailByLatLng(latitude, longitude) async {
  Map map;
  try {
    String country = "";
    String state = "";
    String city = "";
    String shortAddress = "";
    // final coordinates = new Coordinates(latitude, longitude);
    GeocodingPlatform geoCode = GeocodingPlatform.instance;
    List<Placemark> addresses =
        await geoCode.placemarkFromCoordinates(latitude, longitude);
    city = addresses.first.subLocality!;
    country = addresses.first.country!;
    state = addresses.first.postalCode!;
    shortAddress = addresses.first.street!;
    if (city == "" || city.isEmpty) {
      city = addresses.first.subAdministrativeArea!;
    }

    shortAddress = addresses.first.street.toString();
    if (shortAddress.toString() == "null") {
      shortAddress = addresses.first.street.toString();
    }
    if (country.toString() == "null") {
      country = "";
    }
    if (state.toString() == "null") {
      state = "";
    }
    if (shortAddress.toString() == "null") {
      shortAddress = "";
    }
    map = {
      "Latitude": longitude,
      "Longitude": latitude,
      "Address": addresses.first.subLocality,
      "city": city,
      "country": country,
      "state": state,
      "shortAddress": shortAddress + "," + city + "," + state,
    };
    return map;
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      showToast(
          "go to settings and allow your location access for better use.");
    }
    return {};
  }
}
