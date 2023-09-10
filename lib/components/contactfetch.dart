import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'database/contact.dart';
import 'database/database_hepler.dart';
import 'networkConnection/apiStatus.dart';
import 'networkConnection/apis.dart';
import 'networkConnection/httpConnection.dart';

List<ContactListJson> contactslist = [];
List<ContactListJson> contactsfetchServer = [];
var db = DatabaseHelper();

Future<List<ContactListJson>> contactsfetch(context) async {
  bool contactFetch = false;
  List<String> data = [];
  data.add("");
  List contactList = [];

  Iterable<Contact> contacts =
      await ContactsService.getContacts(withThumbnails: false);
  for (var contact in contacts) {
    var phones = [];
    for (var phone in contact.phones!) {
      phones.add(phone.value);
    }
    for (var number in phones) {
      var contactData = {};
      String numberSplit = number
          .toString()
          .replaceAll("(", "")
          .replaceAll(")", "")
          .replaceAll("-", "")
          .replaceAll("*", "")
          .replaceAll("#", "")
          .replaceAll(" ", "")
          .trim();
      // if (numberSplit.contains("+")) {} else {
      //   numberSplit = country_code + numberSplit;
      // }
      if (data.contains(numberSplit)) {
      } else {
        contactData = {
          "name": contact.displayName.toString().trim(),
          "number": numberSplit.toString().trim(),
          "email": contact.displayName.toString(),
        };
        data.add(numberSplit);

        contactList.add(contactData);
      }
    }
  }
  var phones = [];
  for (var contact in contacts) {
    for (var phone in contact.phones!) {
      phones.add(phone.value);
    }
  }

  if (contactList.length < 1) {
    showToast("No contact avaialble.");
  }
  Map map = {
    "numbers": contactList,
  };
  Map decoded = jsonDecode(await apiRequestMainPage(fetchContactUrl, map));
  String status = decoded['status'];
  String message = decoded['message'];
  if (status == success_status) {
    List listContacts = decoded['record']['in_app'] as List;
    // db.deleteAll();
    contactsfetchServer = listContacts
        .map<ContactListJson>((json) => ContactListJson.fromJson(json))
        .toList();
    // addDatabaseContact(listContacts);
    return contactsfetchServer;
  } else if (status == already_login_status) {
    return contactsfetchServer;
  } else if (status == "408") {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    contactsfetch(context);
    return contactsfetchServer;
  } else {
    _showToast(context, message);
    return contactsfetchServer;
  }
}

Future getData(bool param0) async {
  var db = DatabaseHelper();
  List AllContacts = [];
  List contacts = await db.getUser();
//  contactsfetchServer = contacts
//      .map<ContactListJson>((json) => ContactListJson.fromJson(json))
//      .toList();
  for (int i = 0; i < contacts.length; i++) {
//  list[i]['name'],
//           list[i]['number'],
//           list[i]['id'],
//           list[i]['name_in_app'],
//           list[i]['user_type'],
//           list[i]['country_code'],
//           list[i]['email'],
//           list[i]['profile']);
    var data = {
      "name": contacts[i].name,
      "number": contacts[i].number,
      "id": contacts[i].id,
      "name_in_app": contacts[i].name_in_app,
      "user_type": contacts[i].user_type,
      "country_code": contacts[i].country_code,
      "email": contacts[i].email,
      "profile": contacts[i].profile,
    };
    AllContacts.add(data);
  }
  contactslist =
      AllContacts.map<ContactListJson>((json) => ContactListJson.fromJson(json))
          .toList();
}

Future<void> addDatabaseContact(List listContacts) async {
  for (int i = 0; i < listContacts.length; i++) {
    // var invited_data=gson.encode(listContacts[i]['invited_data']);
    var user = ContactsData(
        listContacts[i]['name'],
        listContacts[i]['number'],
        listContacts[i]['id'],
        listContacts[i]['name_in_app'],
        listContacts[i]['user_type'],
        listContacts[i]['country_code'],
        listContacts[i]['email'],
        listContacts[i]['profile']);
    await db.saveUser(user);
  }
}

class ContactListJson {
  // "name": "tom",
//                 "number": "2452554",
//                 "id": "7",
//                 "name_in_app": "Ismael TIMITE",
//                 "user_type": "1",
//                 "country_code": "225",
//                 "email": "is_timite@hotmail.com",
//                 "profile": "https://alphaxtech.net/ecity/uploads/user_profile/thumb/image_picker1802888394770639223.jpg"
  var name, number, id, name_in_app, user_type, country_code, email, profile;

  ContactListJson._(
      {this.name,
      this.number,
      this.id,
      this.name_in_app,
      this.user_type,
      this.country_code,
      this.email,
      this.profile});

  factory ContactListJson.fromJson(Map<String, dynamic> json) {
    return ContactListJson._(
      name: json['name'],
      number: json['number'],
      id: json['id'],
      name_in_app: json['name_in_app'],
      user_type: json['user_type'],
      country_code: json['country_code'],
      email: json['email'],
      profile: json['profile'],
    );
  }
}

Widget? _showToast(BuildContext context, String message) {
  if (message.toLowerCase() != "success")
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
}
