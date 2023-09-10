import 'dart:convert';
import 'dart:io';

import 'package:avauserapp/components/credential.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:place_picker/entities/location_result.dart';

Future<Map> AddressFilter(LocationResult result) async {
  if (result.latLng?.latitude.toString() == "null") {
    showToast("Address pick incorrect");
  }
  Map map =
      await addressFinder(result.latLng!.latitude, result.latLng!.longitude) ??
          {};
  return map;
}

Future<Map?> addressFinder(double latitude, double longitude) async {
  String _host = 'https://maps.google.com/maps/api/geocode/json';
  final url =
      '$_host?key=$googlePlaceKey&language=en&latlng=$latitude,$longitude';
  var dataOne = await getAddressRequest(url);
  Map data = jsonDecode(dataOne!);
  String address = "";
  String city = "";
  String country = "";
  String state = "";
  address = data["results"][0]["formatted_address"];

  List<dynamic> addressComponents = data['results'][0]['address_components'];
  try {
    country = addressComponents
        .firstWhere((entry) => entry['types'].contains('country'))['long_name']
        .toString();
  } catch (e) {}
  try {
    city = addressComponents
        .firstWhere((entry) => entry['types'].contains('locality'))['long_name']
        .toString();
  } catch (e) {}
  try {
    state = addressComponents
        .firstWhere((entry) =>
            entry['types'].contains('administrative_area_level_1'))['long_name']
        .toString();
  } catch (e) {}

  if (city == 'null') {
    try {
      city = addressComponents
          .firstWhere(
              (entry) => entry['types'].contains('sublocality'))['long_name']
          .toString();
    } catch (e) {}
  }

  Map map = {
    "Latitude": latitude.toString(),
    "Longitude": longitude.toString(),
    "Address": address,
    "city": city,
    "country": country,
    "state": state,
    "shortAddress": address,
  };
  return map;
}

showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0);
}

Future<String?> getAddressRequest(String url) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  if (response.statusCode == 200) {
    return reply;
  } else {
    return null;
  }
}
/*
Future<Map> AddressFilter(LocationResult result) async {
  var Latitude = "";
  var Longitude = "";
  var Address = "";
  var city = "";
  var country = "";
  var state = "";
  var shortAddress = "";
  var LatLng = "";
  LatLng = result.latLng.toString();
  Latitude = result.latLng.latitude.toString();
  Longitude = result.latLng.longitude.toString();
  Address = result.name.toString();
  city = result.city.name.toString();
  country = result.country.name.toString();
  state = result.administrativeAreaLevel1.name.toString();
  shortAddress = result.formattedAddress.toString();
  if (city == "null") {
    city = result.city.shortName.toString();
  }
  if (state == "null") {
    state = result.administrativeAreaLevel2.name.toString();
  }
  /* if (country == "null") {
    country = result.country.shortName.toString();
  }*/
  if (shortAddress == "null") {
    shortAddress = result.name + "," + city + "," + state;
  }
  Map map = {
    "Latitude": Latitude,
    "Longitude": Longitude,
    "Address": shortAddress,
    "city": city,
    "country": country,
    "state": state,
    "shortAddress": Address,
  };
  addressFinder(result.latLng.latitude, result.latLng.longitude);
  return map;
}*/
