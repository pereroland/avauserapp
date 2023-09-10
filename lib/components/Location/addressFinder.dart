import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:place_picker/entities/entities.dart';

Future<Map?> AddressFindLocation(LocationResult address) async {
  Map? map;
  try {
    String? country = "";
    String? state = "";
    String? city = "";
    String shortAddress = "";
    GeocodingPlatform geoCode = GeocodingPlatform.instance;
    List<Location> addresses =
        await geoCode.locationFromAddress(address.formattedAddress!);
    var first = address;
    city = first.city!.name;
    state = first.administrativeAreaLevel1!.name;
    country = address.formattedAddress!
        .substring(address.formattedAddress!.lastIndexOf(",") + 1,
            address.formattedAddress!.length)
        .trim();
    shortAddress = first.name.toString();
    if (shortAddress.toString() == "null") {
      shortAddress = first.locality.toString();
    }
    if (state.toString() == "null") {
      state = "";
    }
    if (city == null) {
      city = first.subLocalityLevel1!.name;
    }
    map = {
      "Latitude": addresses.first.latitude,
      "Longitude": addresses.first.longitude,
      "Address": first.formattedAddress,
      "city": city,
      "country": country,
      "state": first.administrativeAreaLevel1!.name,
      "shortAddress": address.formattedAddress!,
    };
    return map;
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {}
    return map;
  }
}
