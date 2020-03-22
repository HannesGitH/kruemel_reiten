import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class TheDatabase {
  static final TheDatabase _instance = TheDatabase._();
  static Database _database;

  TheDatabase._();

  factory TheDatabase() {
    return _instance;
  }


  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await init();

    return _database;
  }

  Future<Database> init() async {
    String dbPath = join(await getDatabasesPath(), 'theDatabase.db');
    var database = openDatabase(
        dbPath, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return database;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
    CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      tel TEXT)
    ''');

    db.execute('''
    CREATE TABLE group(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kid1 INTEGER,
      kid2 INTEGER,
      kid3 INTEGER,
      name TEXT,
      isSec INTEGER)
    ''');

    db.execute('''
    CREATE TABLE lesson(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kid INTEGER,
      date INTEGER,
      presence INTEGER,
      paymentStatus INTEGER,
      description TEXT)
    ''');

    db.execute('''
    CREATE TABLE payment(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kid INTEGER,
      cents INTEGER,
      date INTEGER,
      extra TEXT)
    ''');

  }

  String users = 'user';
  String groups = 'group';
  String lessons = 'lesson';
  String payments = 'payment';

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

}

enum Presence {
  future,
  wasThere,
  canceledInTime,
  canceledJust,
  canceledNot
}

class UserD{
  final String name;
  final String tel;

  UserD({this.name, this.tel});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tel': tel,
    };
  }

  @override
  String toString() {
    return 'Kind: $name, nummer: $tel ';
  }
}

class GroupD{
  final String name;
  final int kid1;
  final int kid2;
  final int kid3;
  final bool isSec;

  GroupD({this.name, this.kid1,this.kid2,this.kid3,this.isSec});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'kid1':kid1,
      'kid2':kid2,
      'kid3':kid3,
      'isSec':isSec,
    };
  }

  @override
  String toString() {
    return 'Gruppe: $name: {rythmus: ${isSec?"1":"2"}, KinderNr: {$kid1,$kid2,$kid3} }';
  }
}

class LessonD{
  final String description;
  final int kid;
  final DateTime date;
  final Presence presence;
  final bool isPaid;

  LessonD({this.description, this.kid, this.date, this.presence,this.isPaid});

  Map<String, dynamic> toMap() {
    return {
      'kid':kid,
      'date':date,
      'presence':presence,
      'paymentStatus':isPaid,
      'description':description,
    };
  }

  @override
  String toString() {
    return 'Stunde am ${date.day}: {KindNr: $kid: $presence, wurde ${isPaid?'':'nicht'} bezahlt.}';
  }
}

class PaymentD{
  final String description;
  final int kid;
  final DateTime date;
  final int cents;

  PaymentD({this.description, this.kid, this.date, this.cents});

  Map<String, dynamic> toMap() {
    return {
      'kid':kid,
      'date':date,
      'cents':cents,
      'extra':description,
    };
  }

  @override
  String toString() {
    return 'am ${date.day} wurde für Kind Nr $kid $cents bezahlt. ($description)}';
  }
}

class Kid{

  Kid({this.name, this.tel, this.balance});

  String name;
  String tel;
  int balance;
}

class Group{

  Group({this.name, this.kids});

  String name;
  List<Kid>kids;
} 

class DataHandler{
  static final DataHandler _instance = DataHandler._();
  static TheDatabase tdb = TheDatabase();
  static Future<Database> _database = tdb.db;

  DataHandler._();

  factory DataHandler() {
    return _instance;
  }

  Future<int> _addUser(name) async{
    Database db = await _database;

    UserD user = new UserD(name: name, tel: "noch keine Nummer");

    int id = await db.insert(tdb.users, 
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }

  Future<int> _addGroup(List<int> names, {String name, bool isSec}) async{

    Database db = await _database;

    int lastId =(await db.rawQuery('''
      SELECT *
      FROM history
      ORDER BY id DESC
      LIMIT 1
    ''')
    ).first['id']
    ??0;

    GroupD group = new GroupD(name: name??"Gruppe ${lastId+1}", kid1: names[0], kid2: names[1], kid3: names[2]);

    int id = await db.insert(tdb.groups, 
      group.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }

  Future<void> addGroup( String name1, String name2, String name3, [String groupName]) async{
    int id1 = await _addUser(name1);
    int id2 = await _addUser(name2);
    int id3 = await _addUser(name3);

    await _addGroup([id1,id2,id3], name: groupName);

    return;
  }

  Future<List<int>> _getGroupMembersByName_id(groupName) async{
    Database db = await _database;

    Map<String, dynamic> kidsMap = (await db.query(tdb.groups,
      columns: ['kid1','kid2','kid3'],
      where: 'name = ?',
      whereArgs: [groupName],
    )).first;

    List<int> kids;

    void append(String kidid, dynamic kid) {
      kids.add(kid);
    }

    kidsMap.forEach(append);

    return kids;
  }

  Future<List<String>> getGroupMembersByName_onlyNames(groupName) async{
    List<Kid> kids = await getGroupMembersByName_noBalance(groupName);
    return List.generate(kids.length, (i){
      return kids[i].name;
    });
  }

  Future<Kid> _getKidById(kidID)async{
    Database db = await _database;
    Map<String, dynamic> kid = (await db.query(tdb.users,
        where: 'id = ?',
        whereArgs: [kidID],
      )).first;

      
    return Kid(
      name: kid['name'],
      tel: kid['tel'],
      balance: null, //kid['balance']///this is probably not the correct balance
    );
  }
  
  Future<List<Kid>> getGroupMembersByName_noBalance(groupName) async{
    List<int> kidIDs = await _getGroupMembersByName_id(groupName);

    List<Kid> kids;
    void getKid (kidID) async{
      kids.add(
        await _getKidById(kidID)
      );
    }
    await Future.forEach(kidIDs,getKid);
    return kids;
  }

  Future<int> _getLessonAmountByUserId(int uid) async{
    Database db = await _database;
    return (await db.query(tdb.lessons,
      columns: ['Count(*)'], 
      where:'id = ?' , 
      whereArgs: [1]
    )).first['Count(*)'];
  }

  Future<int> _getBalanceByUserID(int uid) async{

    int price=2500;//der Preis für eine Reitstunde in cent

    Database db = await _database;
    List<Map<String, dynamic>> payments = await db.query(tdb.payments,
      columns: ['cents'],
      where: 'kid = ?',
      whereArgs: [uid],
    );

    List<int> paymentsInCents = List.generate(payments.length, (i){
      return payments[i]['cents'];
    });

    int negativeBalance = -(await _getLessonAmountByUserId(uid))*price;

    int balance=paymentsInCents.fold(negativeBalance, (bal,paid){return bal+paid;});
    
    return balance;

  }

  Future<List<Kid>> getGroupMembersByName_complete(groupName) async{
    List<Kid> kids = await getGroupMembersByName_noBalance(groupName);
    List<int> kidIDs = await _getGroupMembersByName_id(groupName);
    //ich hab iwie sorge dass die groupmembers nach aufruf von ..._nobalance aufgrund das async forEach nicht mehr sortiert sind ; wird sich in testcases herausfinden

    List<Kid> newKids;
    for(int i=0;i<kids.length;i++){
      kids.add(
        Kid(
          name: kids[i].name,
          tel: kids[i].tel,
          balance: await _getBalanceByUserID(kidIDs[i]),
        )
      );
    }
    return newKids;
  }

}