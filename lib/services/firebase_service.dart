import 'package:firebase_database/firebase_database.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/global_service.dart';

class FirebaseService {
  final _database = FirebaseDatabase.instance.ref();

  Future<UserData> getUserData(uid) async {
    UserData? user;
    final usersRef = _database.child('/users/$uid');
    await usersRef.once().then((event) {
      final json = event.snapshot.value as Map<dynamic, dynamic>;
      user = UserData.fromJson(json, uid);
    });
    print(user!.uid);
    return user!;
  }

  Future<String> getUserName(uid) async {
    String name = '';
    final usersRef = _database.child('/users/$uid/name');
    await usersRef.once().then((event) {
      name = event.snapshot.value.toString();
    });
    return name;
  }

  Future<void> updateLatestTimestamp(uid, timestamp) async {
    Map<String, Object?> updates = {};
    updates['latestTimestamp'] = timestamp;
    final usersRef = _database.child('/users/$uid/');
    await usersRef.update(updates).then((snapshot) {});
  }

  Future<void> updateSetting(uid, name, notifyFreq, enableViewedNotify) async {
    Map<String, Object?> updates = {};
    updates['name'] = name;
    updates['notifyWhenViewCountsEqual'] = notifyFreq;
    updates['enableViewedNotify'] = enableViewedNotify;
    final usersRef = _database.child('/users/$uid/');
    await usersRef.update(updates).then((snapshot) {});
  }

  Future<void> setUserMsgToken(uid, token) async {
    Map<String, Object?> updates = {};
    updates['msgToken'] = token;
    final usersRef = _database.child('/users/$uid/');
    await usersRef.update(updates).then((snapshot) {});
  }

  Future<void> updatePhotoDescription(group, pid, desc) async {
    Map<String, Object?> updates = {};
    updates['description'] = desc;
    final usersRef = _database.child('/groups/$group/photos/$pid');
    await usersRef.update(updates).then((snapshot) {});
  }

  Future<void> updatePhotoViewCount(user, pid, authorId) async {
    Map<String, Object?> updates = {};
    int updateValue;
    final countsRef = _database.child('/groups/${user.group}/photos/$pid');
    await countsRef.child('viewCounts/${user.identity}').once().then((event) {
      if (event.snapshot.value != null) {
        var currentCounts = int.parse(event.snapshot.value.toString());
        updateValue = currentCounts + 1;
      } else {
        updateValue = 1;
      }
      updates['${user.identity}'] = updateValue;
      if (authorId != user.uid &&
          updateValue == user.notifyWhenViewCountsEqual) {
        ApiService().sendViewCountNotification(user.uid, pid, updateValue);
      }
    });
    countsRef.update(updates).then((snapshot) {});
  }
}
