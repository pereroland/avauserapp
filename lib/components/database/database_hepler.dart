import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ecity.db");
    var theDb = await openDatabase(path, version: 2, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE ContactsData(id INTEGER PRIMARY KEY, name TEXT, number TEXT, id TEXT, name_in_app TEXT, user_type TEXT, country_code TEXT, email TEXT, profile TEXT)");
  }

  Future<int> saveUser(ContactsData user) async {
    var dbClient = await db;
    int res = await dbClient!.insert("ContactsData", user.toMap());
    return res;
  }

  Future<List<ContactsData>> getUser() async {
    var dbClient = await db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM ContactsData');
    List<ContactsData> employees = [];
    for (int i = 0; i < list.length; i++) {
      var user = new ContactsData(
          list[i]['name'],
          list[i]['number'],
          list[i]['id'],
          list[i]['name_in_app'],
          list[i]['user_type'],
          list[i]['country_code'],
          list[i]['email'],
          list[i]['profile']);
      user.setUserId(list[i]["id"]);
      employees.add(user);
    }
    return employees;
  }

  Future<int> deleteUsers(ContactsData user) async {
    var dbClient = await db;

    int res = await dbClient
    !.rawDelete('DELETE FROM ContactsData WHERE id = ?', [user.id]);
    return res;
  }

  Future<int> deleteAll() async {
    var dbClient = await db;

    int res = await dbClient!.delete("ContactsData");
    return res;
  }

  Future<bool> update(ContactsData user) async {
    var dbClient = await db;
    int res = await dbClient!.update("ContactsData", user.toMap(),
        where: "id = ?", whereArgs: <int>[user.id]);

    return res > 0 ? true : false;
  }
}
