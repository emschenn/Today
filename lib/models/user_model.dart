class UserData {
  String? uid;
  String? email;
  String? group;
  String? name;
  String? msgToken;
  int? latestTimestamp;
  bool? isParent;

  UserData(
      {this.uid,
      this.email,
      this.group,
      this.name,
      this.isParent,
      this.msgToken,
      this.latestTimestamp});

  UserData.fromJson(Map<dynamic, dynamic> json, String id) {
    uid = id;
    email = json['email'];
    group = json['group'];
    name = json['name'];
    msgToken = json['msgToken'];
    latestTimestamp = json['latestTimestamp'];
    isParent = json['isParent'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['uid'] = uid;
    data['email'] = email;
    data['group'] = group;
    data['name'] = name;
    data['msgToken'] = msgToken;
    data['latestTimestamp'] = latestTimestamp;
    data['isParent'] = isParent;
    return data;
  }
}
