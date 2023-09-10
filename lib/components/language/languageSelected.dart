import 'dart:convert';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map> langTxt(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String lang = prefs.getString('lang') ?? "";
  String locale = await Devicelocale.currentLocale ?? "";
  // ignore: unnecessary_null_comparison
  if (lang == null) {
    if (locale.contains("fr")) {
      String data = await DefaultAssetBundle.of(context)
          .loadString("assets/locale/fr.json");
      var jsonResult = json.decode(data);
      return jsonResult;
    } else {
      String data = await DefaultAssetBundle.of(context)
          .loadString("assets/locale/en.json");
      var jsonResult = json.decode(data);
      return jsonResult;
    }
  }

  if (lang == "fr") {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/locale/fr.json");
    var jsonResult = json.decode(data);
    return jsonResult;
  } else {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/locale/en.json");
    var jsonResult = json.decode(data);
    return jsonResult;
  }
}

englishLangSetAppUse(context) async {
  String data =
  await DefaultAssetBundle.of(context).loadString("assets/locale/fr.json");
  var jsonResult = json.decode(data);
  return jsonResult;
}

frenchLangSetAppUse(context) async {
  String data =
  await DefaultAssetBundle.of(context).loadString("assets/locale/fr.json");
  var jsonResult = json.decode(data);
  return jsonResult;
}
