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
    String dbPath = join(await getDatabasesPath(), 'theRealDatabase_T.db');
    var database = openDatabase(
        dbPath, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
      kid4 INTEGER,
      kid5 INTEGER,
      kid6 INTEGER,
      kid7 INTEGER,
      kid8 INTEGER,
      kid9 INTEGER,
      kid10 INTEGER,
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
      description TEXT,
      replacement TEXT)
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
    if (oldVersion==1 && newVersion>=2){
      db.execute('''
      ALTER TABLE lesson
      ADD COLUMN replacement TEXT
    ''');
    }
    if ( oldVersion<=3 && newVersion>=3){
      String alterStatement='''
      ALTER TABLE groupi
      ADD COLUMN ''';
      for(String col in ['kid4','kid5','kid6','kid7','kid8','kid9','kid10']){
        db.execute(alterStatement+col+' INTEGER');
      }
    }
  }

}

enum Presence {
  future,
  wasThere,
  canceledInTime,
  canceledInTime_withReplacement,
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
  final List<int> kids;
  final bool isSec;

  GroupD({this.name, this.kids,this.isSec});

  factory GroupD.fromGroupAndKidIds({@required Group group, @required List<int> kidIDs}){
    return GroupD(isSec: group.isSec,kids: kidIDs,name: group.name);
  }

  Map<String, dynamic> toMap() {
    Map<String, int> kiddos={};
    for (int i=0;i<kids.length;i++){
      kiddos.addAll({'kid${i+1}':kids[i]});
    }
    for (int i=kids.length;i<10;i++){
      kiddos.addAll({'kid${i+1}':null});
    }
    Map<String, dynamic> map={
      'name': name,
      'isSec':isSec,
    };
    map.addAll(kiddos);
    return map;
  }

  @override
  String toString() {
    return 'Gruppe: $name: {rythmus: ${isSec?"1":"2"}, KinderNr: ${kids.toString()} }';
  }
}

class LessonD{
  final String description;
  final int kid;
  final int date;
  final int presence;
  final bool isPaid;
  final String replacement;

  LessonD({this.description, this.kid, this.date, this.presence,this.isPaid,this.replacement=''});

  Map<String, dynamic> toMap() {
    return {
      'kid':kid,
      'date':date,
      'presence':presence,
      'paymentStatus':isPaid,
      'description':description,
      'replacement':replacement,
    };
  }

  @override
  String toString() {
    DateTime day=DateTime.fromMillisecondsSinceEpoch(date);
    return 'Stunde am ${day.day}: {KindNr: $kid: $presence, wurde ${isPaid?'':'nicht'} bezahlt.}';
  }
}

class PaymentD{
  final String description;
  final int kid;
  final int date;
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
    return 'am ${date} wurde für Kind Nr $kid $cents bezahlt. ($description)}';
  }
}

class Kid{

  Kid({this.name, this.tel, this.balance});

  String name;
  String tel;
  int balance;
}

class Group{

  Group({this.name, this.kids, this.isSec});

  String name;
  List<Kid>kids;
  bool isSec;
} 

class Lesson{
  final String description;
  final Kid kid;
  final DateTime date;
  final Presence presence;
  final bool isPaid;
  final String replacement;

  Lesson({this.description, this.kid, this.date, this.presence,this.isPaid,this.replacement});

  Map<String, dynamic> toMap() {
    return {
      'kid':kid,
      'date':date,
      'presence':presence,
      'paymentStatus':isPaid,
      'description':description,
      'replacement':replacement,
    };
  }



  /*Lesson fromMap(Map<String, dynamic> m){
    return Lesson(date: m['date'],kid: m['kid'],presence: m['presence'],isPaid: m['isPaid'],description: m['description']);
  }*/

  @override
  String toString() {
    return 'Stunde am ${date != null ? date.day : "unbekannt"}: {Kind: ${kid.name??"unbekannt"}: ${presence??"unbekannt"}, wurde ${(isPaid??false)?'':'nicht'} bezahlt.}';
  }
}

class Payment{
  final String description;
  final Kid kid;
  final DateTime date;
  final int cents;

  Payment({this.description, this.kid, this.date, this.cents});

  PaymentD toPaymentD(int kidID) {
    return PaymentD(
      kid:kidID,
      date:date.millisecondsSinceEpoch,
      cents:cents,
      description:description,
    );
  }

  @override
  String toString() {
    return 'am ${date.day} wurde für Kind Nr $kid $cents bezahlt. ($description)}';
  }
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
  Future<int> _addUser({String name, Kid kid}) async{
    Database db = await _database;

    if(name==null && kid==null){
      throw Exception('dafuq yo kein user den man hinzufügen könnte');
    }

    UserD user = UserD(name: name, tel: "noch keine Nummer");
    if(kid!=null){
      user= UserD(name: kid.name, tel:kid.tel);
    }

    int id = await db.insert(tdb.users, 
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }


//ADD a Group 
  Future<void> addGroup(Group group) async{
    //print("adding group: ${group.toString()}");
    List<int> kidIds=[];
    for(Kid kid in group.kids){
      kidIds.add(await _addUser(name:kid.name));
    }

    await _addGroup(kidIds, name: group.name);

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

    GroupD group = GroupD(
      name: name??'Gruppe ${lastId+1}',
      kids:names,
      isSec: lastId%2==1
    );
    print(lastId%2==1);

    int id = await db.insert(tdb.groups, 
      group.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }

  //add a payment
  Future<int> addPayment (Payment payment) async{
    Database db = await _database;

    int kidID = await _getKidsIdfromName(payment.kid.name);

    PaymentD pd= payment.toPaymentD(kidID);

    int id = await db.insert(tdb.payments, 
      pd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }

//---------------------------------------------------------------------- GET Stuff

//GET groups 
   Future<List<List<String>>> getAllGroups_onlyNames() async{
    //print("getting all group names..");
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
    //print("Getting all Groups..");
    Database db = await _database;
    List<Map<String,dynamic>> allIds = await db.query(tdb.groups,
      //columns: ['kid1','kid2','kid3','name','isSec'],
    );
    List<Group> groups=[];
    for(int i=0 ; i<allIds.length ; i++){
      Map<String,dynamic> map=allIds[i];
      String groupName=map['name'];
      List<Kid> kids=[];
    //print("gettin' all those kids: ${map.toString()}");
      for(int j=1 ; j<map.length-1 ; j++){//jep my kids index starts at 1, shame on me
        try{
          Kid kid=await _getKidById(map['kid$j']);
          if(kid!=null)kids.add(kid);
          //else kids.add(Kid(name:'lolol'));//TODO REMOVE
        }
        catch (e){print('ERROR beim GruppenBekommen (_noBalnce): $e');}
      }
      groups.add(Group(name: groupName, kids: kids,isSec: map['isSec']==1));
    }
    return groups;
  }

  Future<int> getGroupCount() async{
    //print("Getting Group Count");
    Database db = await _database;
    int count = (await db.query(tdb.groups,
      columns: ['Count(*)'],
    )).first['Count(*)'];
    return count;
  }


//GET Group
  Future<List<int>> _getGroupMembersByName_id(groupName) async{
    //print("getting Groupmembers from Group $groupName");
    Database db = await _database;

    if(groupName=='gruppe ohne Namen'||groupName==null)return [];

    Map<String, dynamic> kidsMap = (await db.query(tdb.groups,
      //columns: ['kid1','kid2','kid3'],
      where: 'name = ?',
      whereArgs: [groupName??0],
    )).first;

    List<int> kids=[];

    void append(String kidid, dynamic kid) {
      if(kidid.substring(0,2)=='ki'&&kid!=null){
        kids.add(kid);
      }
    }

    kidsMap.forEach(append);

    return kids;
  }

  Future<List<String>> getGroupMembersByName_onlyNames(groupName) async{
    //print("getting GroupmemberNames from Group $groupName");
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
    //print(newKids);
    return newKids;
  }

//GET Kid
  Future<Kid> _getKidById(kidID)async{
    //print("getting kid from id $kidID .. ");
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
      whereArgs: [uid],
    )).first['Count(*)'];
  }

  Future<DateTime> _getFirstLessonFromUserId(int uid)async{
    Database db = await _database;
    List<Map<String, dynamic>> lessons = await db.query(tdb.lessons,
      columns: ['date'], 
      where:'kid = ?' , 
      whereArgs: [uid],
    );

    int smallestDate;
    for (Map<String, dynamic> lesson in lessons){
      if (smallestDate==null || lesson['date']<smallestDate){
        smallestDate=lesson['date'];
      }
    }
    try{
    return DateTime.fromMillisecondsSinceEpoch(smallestDate);
    }catch(e){return null;}
    return null;
  }

  Future<List<Lesson>> getLessonsOnDay(DateTime day) async{
    Database db = await _database;
    List<Map<String, dynamic>> lessons = await db.query(tdb.lessons,
      columns: ['kid','presence','paymentStatus','description','replacement'], 
      where:'date = ?' , 
      whereArgs: [day.millisecondsSinceEpoch],
    );

    List<Lesson> newlessons=[];
    for(int i=0; i<lessons.length; i++){
      Kid kid = await _getKidById(lessons[i]['kid']);
      newlessons.add(
        Lesson(
          date: day,
          kid: kid,
          description: lessons[i]['description'],
          presence: Presence.values[lessons[i]['presence']],
          isPaid: lessons[i]['paymentStatus'],
          replacement:  lessons[i]['replacement'],
        )
      );
    }

    return newlessons;

  }

//GET Payments
  Future<int> _getBalanceByUserID(int uid) async{
    //print("getbalenceFrom $uid");

    //TODO: load from settings
    int price=2500;//der Preis für eine Reitstunde in cent
    int price_back=1000;//der Preis für eine Reitstunde in cent
    int price_extra=1500;//der Preis für eine Reitstunde in cent

    Database db = await _database;
    List<Map<String, dynamic>> payments = await db.query(tdb.payments,
      columns: ['cents'],
      where: 'kid = ?',
      whereArgs: [uid],
    );

    List<int> paymentsInCents = List.generate(payments.length, (i){
      return payments[i]['cents'];
    });

    int startedMonths(DateTime t1, DateTime t2){
      int dist=0;
      try{
        dist= ((t1.year*12+t1.month)-(t2.year*12+t2.month)).abs()+1;
      }catch (e) {return 0;}
      return dist;
    }

    print("startedmonths since ${await _getFirstLessonFromUserId(uid)} :${startedMonths(await _getFirstLessonFromUserId(uid),DateTime.now())}");

    int negativeBalance = - startedMonths(await _getFirstLessonFromUserId(uid),DateTime.now())*price;
    negativeBalance += await _getFreeLessonAmount(uid)*price_back;
    negativeBalance -= await _getExtraLessonAmount(uid)*price_extra;

    int balance=paymentsInCents.fold(negativeBalance, (bal,paid){return bal+paid;});
    
    return balance;

  }

  Future<int>_getExtraLessonAmount(int uid)async{
    Database db = await _database;
    try{
    return (await db.query(tdb.lessons,
      columns: ['Count(*)'],
      where: 'replacement = ? AND presence = ?',
      whereArgs: [(await _getKidById(uid)).name ,Presence.canceledInTime_withReplacement.index],
    )).first['Count(*)'];
    }on Exception{
      return 0;
    }
  }

  Future<int>_getFreeLessonAmount(int uid)async{
    Database db = await _database;
    try{
    return (await db.query(tdb.lessons,
      columns: ['Count(*)'],
      where: 'kid = ? AND presence = ?',
      whereArgs: [uid,Presence.canceledInTime_withReplacement.index],
    )).first['Count(*)'];
    }on Exception{
      return 0;
    }
  }


//---------------------------------------------------------------------- DELETE Stuff

//DELETE Group
 Future<void> deleteGroup(Group group) async{
    //print("deleting Group ${group.name}");

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
    //print("changing $oldname's name to $newname");

    Database db = await _database;
    await db.update(tdb.users,
      {'name':newname},
      where: 'name = ?',
      whereArgs: [oldname],
    );
    return;
  }

  Future<void> changeKidsTel({@required name, @required tel})async{
    //print("changing $name's number to $tel");

    Database db = await _database;
    await db.update(tdb.users,
      {'tel':tel},
      where: 'name = ?',
      whereArgs: [name],
    );
    return;
  }

//setting a lesson
  Future<void> setLesson(Lesson lesson)async{
    Database db = await _database;
    Map<String,int> id = await _isThereALesson(name: lesson.kid.name, day: lesson.date);

    LessonD newLesson = LessonD(
      description: lesson.description,
      kid:id['kidId'],
      date:lesson.date.millisecondsSinceEpoch,
      presence: lesson.presence.index,
      isPaid:lesson.isPaid,
      replacement: lesson.replacement
    );

    if(id['lessonId'] == -1){
      //insert new Lesson
      await db.insert(tdb.lessons, 
        newLesson.toMap(),
      );
    }else{
      //update Lesson
      await db.update(tdb.lessons, 
        newLesson.toMap(),
        where: 'id = ?',
        whereArgs: [id['lessonId']],
      );
    }
    return;
  }
  Future<Map<String,int>> _isThereALesson({@required String name, @required DateTime day})async{
    Database db = await _database;
    int id = await _getKidsIdfromName(name);
    List<Map<String,dynamic>> ids = await db.query(tdb.lessons,
      columns: ['id'],
      where: 'kid = ? AND date = ?',
      whereArgs: [id,day.millisecondsSinceEpoch], //TODO:eigtl wollen wir ja nicht nach der millisekunde sondern dem Tag schaune
    );
    if (ids==null ||ids.length==0){
      return {
       'kidId': id,
       'lessonId' : -1,
      };
    }
    return {
      'kidId': id,
      'lessonId' : ids.first['id'],
    };
  }
  Future<int> _getKidsIdfromName(String name)async{
    Database db = await _database;
    try{
    int id = (await db.query(tdb.users,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
    )).first['id'];
    return id;
    }catch(e){
      return null;
    }
  }

/// update a group in general (shouldn't change its name)
Future<void> updateGroup({@required Group group})async{
  Database db = await _database;

  print('kids (updateGroup) :  ${group.kids.length}');

  List<int> kidIDs=[];
  void getKid (Kid kid) async{
    kidIDs.add(
      (await _getKidsIdfromName(kid.name))??(await _addUser(kid:kid))
    );
  }
  await Future.forEach(group.kids,getKid);

  await db.update(tdb.groups, 
    GroupD.fromGroupAndKidIds(group: group,kidIDs:kidIDs).toMap(),
    where: 'name = ?',
    whereArgs: [group.name],
  );
  return;
}


//update a groups isSec
Future<void> changeGroupsIsSec({@required String groupName,@required bool isSec})async{

  Database db = await _database;
  await db.update(tdb.groups,
    {'isSec':isSec?1:0},
    where: 'name = ?',
    whereArgs: [groupName],
  );

  return;
} 

Future<void> changeGroupName({@required oldname, @required newname})async{
    //print("changing $oldname's name to $newname");

    Database db = await _database;
    await db.update(tdb.groups,
      {'name':newname},
      where: 'name = ?',
      whereArgs: [oldname],
    );
    return;
  }



}