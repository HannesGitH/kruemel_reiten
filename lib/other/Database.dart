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
    String dbPath = join(await getDatabasesPath(), 'theRealDatabase_TT.db');
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
    CREATE TABLE groupi(
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
  String groups = 'groupi';
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


//---------------------------------------------------------------------- ADD Stuff


//ADD a single user
  Future<int> _addUser(name) async{
    Database db = await _database;

    UserD user = new UserD(name: name, tel: "noch keine Nummer");

    int id = await db.insert(tdb.users, 
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }


//ADD a Group 
  Future<void> addGroup(Group group) async{
    print("adding group: ${group.toString()}");
    int id1 = await _addUser(group.kids[0].name);
    int id2 = await _addUser(group.kids[1].name);
    int id3 = await _addUser(group.kids[2].name);

    await _addGroup([id1,id2,id3], name: group.name);

    return;
  }

  Future<int> _addGroup(List<int> names, {String name, bool isSec}) async{

    Database db = await _database;

    var qr = await db.rawQuery('''
      SELECT *
      FROM ${tdb.groups}
      ORDER BY id DESC
      LIMIT 1
    ''');

    int lastId=0;
    if (qr.length!=0){
      lastId =(qr.first??{'id':0})['id'];
    }

    GroupD group = new GroupD(name: name??"Gruppe ${lastId+1}", kid1: names[0], kid2: names[1], kid3: names[2]);

    int id = await db.insert(tdb.groups, 
      group.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }


//---------------------------------------------------------------------- GET Stuff

//GET groups 
   Future<List<List<String>>> getAllGroups_onlyNames() async{
    print("getting all group names..");
    //this might be slower than the complete variant 
    Database db = await _database;
    List<Map<String,dynamic>> allIds = await db.query(tdb.groups,
      columns: ['name'],
    );
    List<List<String>> groups=[[]];
    for(int i=0 ; i<allIds.length ; i++){
      Map<String,dynamic> map=allIds[i];
      String groupName=map['name'];
      groups.add(await getGroupMembersByName_onlyNames(groupName));
    }
    return groups;
  }

  Future<List<Group>> getAllGroups_noBalance() async{
    print("Getting all Groups..");
    Database db = await _database;
    List<Map<String,dynamic>> allIds = await db.query(tdb.groups,
      columns: ['kid1','kid2','kid3','name'],
    );
    List<Group> groups=[];
    for(int i=0 ; i<allIds.length ; i++){
      Map<String,dynamic> map=allIds[i];
      String groupName=map['name'];
      List<Kid> kids=[];
    print("gettin' all those kids: ${map.toString()}");
      for(int j=1 ; j<map.length ; j++){//jep my kids index starts at 1, shame on me
        kids.add(await _getKidById(map['kid$j']));
      }
      groups.add(Group(name: groupName, kids: kids));
    }
    return groups;
  }

//GET Group
  Future<List<int>> _getGroupMembersByName_id(groupName) async{
    print("getting Groupmembers from Group $groupName");
    Database db = await _database;

    Map<String, dynamic> kidsMap = (await db.query(tdb.groups,
      columns: ['kid1','kid2','kid3'],
      where: 'name = ?',
      whereArgs: [groupName],
    )).first;

    List<int> kids=[];

    void append(String kidid, dynamic kid) {
      kids.add(kid);
    }

    kidsMap.forEach(append);

    return kids;
  }

  Future<List<String>> getGroupMembersByName_onlyNames(groupName) async{
    print("getting GroupmemberNames from Group $groupName");
    List<Kid> kids = await getGroupMembersByName_noBalance(groupName);
    return List.generate(kids.length, (i){
      return kids[i].name;
    });
  }

  Future<List<Kid>> getGroupMembersByName_noBalance(groupName) async{
    List<int> kidIDs = await _getGroupMembersByName_id(groupName);

    List<Kid> kids=[];
    void getKid (kidID) async{
      kids.add(
        await _getKidById(kidID)
      );
    }
    await Future.forEach(kidIDs,getKid);
    return kids;
  }

  Future<List<Kid>> getGroupMembersByName_complete(groupName) async{
    List<Kid> kids = await getGroupMembersByName_noBalance(groupName);
    List<int> kidIDs = await _getGroupMembersByName_id(groupName);
    //ich hab iwie sorge dass die groupmembers nach aufruf von ..._nobalance aufgrund das async forEach nicht mehr sortiert sind ; wird sich in testcases herausfinden

    List<Kid> newKids=[];
    for(int i=0;i<kids.length;i++){
      newKids.add(
        Kid(
          name: kids[i].name,
          tel: kids[i].tel,
          balance: await _getBalanceByUserID(kidIDs[i]),
        )
      );
    }
    print(newKids);
    return newKids;
  }

//GET Kid
  Future<Kid> _getKidById(kidID)async{
    print("getting kid from id $kidID .. ");
    Database db = await _database;

    List<Map<String, dynamic>> kids = await db.query(tdb.users,
        where: 'id = ?',
        whereArgs: [kidID??0],
      );
    if (kids.length>0){
      var kid=kids.first;
      return Kid(
        name: kid['name'],
        tel: kid['tel'],
        balance: null, //kid['balance']///this is probably not the correct balance
      );
    }
    return null;

  }

//GET Lessons
  Future<int> _getLessonAmountByUserId(int uid) async{
    Database db = await _database;
    return (await db.query(tdb.lessons,
      columns: ['Count(*)'], 
      where:'id = ?' , 
      whereArgs: [uid]
    )).first['Count(*)'];
  }

//GET Payments
  Future<int> _getBalanceByUserID(int uid) async{
    print("getbalenceFrom $uid");
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


//---------------------------------------------------------------------- DELETE Stuff

//DELETE Group
 Future<void> deleteGroup(Group group) async{
    print("deleting Group ${group.name}");

    Database db = await _database;
    await db.delete(tdb.groups,
      where: 'name = ?',
      whereArgs: [group.name],
    );
    return;

  }


//---------------------------------------------------------------------- UPDATE Stuff

//Updating a kid
  Future<void> changeKidsName({@required oldname, @required newname})async{
    print("changing $oldname's name to $newname");

    Database db = await _database;
    await db.update(tdb.users,
      {'name':newname},
      where: 'name = ?',
      whereArgs: [oldname],
    );
    return;
  }

  Future<void> changeKidsTel({@required name, @required tel})async{
    print("changing $name's number to $tel");

    Database db = await _database;
    await db.update(tdb.users,
      {'tel':tel},
      where: 'name = ?',
      whereArgs: [name],
    );
    return;
  }
}