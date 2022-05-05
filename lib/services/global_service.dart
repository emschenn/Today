import 'package:pichint/models/user_model.dart';

class GlobalService {
  static final GlobalService _instance = GlobalService._internal();

  factory GlobalService() => _instance;

  GlobalService._internal() {
    user = null;
  }

  UserData? user;

  UserData? get getUserData => user;

  set setUserData(UserData value) => user = value;
}
