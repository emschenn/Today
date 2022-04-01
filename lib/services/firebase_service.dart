import 'package:firebase_database/firebase_database.dart';
import 'package:pichint/models/user_model.dart';

class FirebaseService {
  final _database = FirebaseDatabase.instance.ref();

  Future<UserData> getUserData(uid) async {
    UserData? user;
    final usersRef = _database.child('/users/$uid');
    await usersRef.get().then((snapshot) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      user = UserData.fromJson(json);
    });
    return user!;
  }

  Future<bool> addPhoto(group, photo) async {
    final groupRef = _database.child('/groups/$group');
    bool isSuccess = false;
    await groupRef.push().set(photo.toJson()).then((_) {
      print('write to db successfully');
      isSuccess = true;
    }).catchError((err) {
      print(err);
      isSuccess = false;
    });
    return isSuccess;
  }

  Future<bool> deletePhoto(group, photo) async {
    final groupRef = _database.child('/groups/$group/${photo.pid}');
    bool isSuccess = false;
    await groupRef.remove().then((_) {
      print('remove from db successfully');
      isSuccess = true;
    }).catchError((err) {
      print(err);
      isSuccess = false;
    });
    return isSuccess;
  }
}
