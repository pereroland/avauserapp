import 'dart:convert';
import 'dart:io';

import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apis.dart';

const apiLogTag = "apiLogTag";

/*........created by shirsh shukla......*/
Future<String> apiRequest(String url, Map jsonMap, context) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authtoken = prefs.getString('authtoken') ?? "";
  print("auth token");
  print(authtoken);
  request.headers.set('authtoken', authtoken.toString().trim().toString());
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> apiRequestMainPageWithOutCx(String url, Map jsonMap) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authtoken = prefs.getString('authtoken') ?? "";
  request.headers.set('authtoken', "$authtoken");
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> apiRequestMainPage(String url, Map jsonMap) async {
  HttpClient httpClient = HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authtoken = prefs.getString('authtoken') ?? "";
  request.headers.set('authtoken', "$authtoken");
  request.headers.set('Accept', "application/json");
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> getApiDataRequest(String url, BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authtoken = prefs.getString('authtoken') ?? "";
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  request.headers.set('authtoken', "$authtoken");
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> apiAuthentificationRequest(
    String url, Map jsonMap, BuildContext context) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String typeScreen = prefs.getString('typeScreen') ?? "";
  request.headers.set('app_key', "affricanfood#2020");
  request.headers.set('app_secret', "SHA15AHYVSGJ3#");
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  List headerData = response.headers['authtoken'] ?? [];
  if (headerData != null && headerData.isNotEmpty) {
    prefs.setString('authtoken', headerData[0].toString());
  }
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> chatapiRequest(
    String url, Map jsonMap, BuildContext context) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers.set('Content-Type', "application/json");
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.headers.set('Authorization',
      "key=AAAAAnP7Vdo:APA91bG2vnkuZf9L2d4R5LpXKTrXFeipWbCSNc_TWFvRFOYTiVRvfi8OaxLShMRE2oEetVV2vYNdjTBqOGp4jlmWBGRLrhje19LqwH4TCefmcA8aRFeolrQdF0NZinnomkNMUpdKeybF");
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> apiRefreshRequest(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ?? "";
  String authtoken = prefs.getString('authtoken') ?? "";
  Map jsonMap = {"oldToken": authtoken};
  /**/
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(refreshUrl));
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.headers.set('app_key', "affricanfood#2020");
  request.headers.set('app_secret', "SHA15AHYVSGJ3#");
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  List headerData = response.headers['authtoken'] ?? [];
  if (headerData == null) {
  } else {
    prefs.setString('authtoken', headerData[0].toString());
  }
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<String> apiRefreshRequestNotCX() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authtoken = prefs.getString('authtoken') ?? "";
  Map jsonMap = {"oldToken": authtoken};
  /**/
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(refreshUrl));
  request.headers.set('Accept-Language', "${allTranslations.locale}",
      preserveHeaderCase: true);
  request.headers.set('app_key', "affricanfood#2020");
  request.headers.set('app_secret', "SHA15AHYVSGJ3#");
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  List headerData = response.headers['authtoken'] ?? [];
  if (headerData == null) {
  } else {
    prefs.setString('authtoken', headerData[0].toString());
  }
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

void _showToast(BuildContext context, String mesage) {
  Fluttertoast.showToast(
      msg: mesage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0);
}

Future<String?> checkLoginStatus(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('userLogin');
  prefs.remove('authtoken');
  Navigator.pushNamedAndRemoveUntil(context, '/LoginRegistraion', (r) => false);
}

dialogShow(context, bool data) {
  if (context != null) {
    if (data == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: Image.asset("assets/loadder.gif"));
          });
    } else {
      Navigator.pop(context);
    }
  }
}
