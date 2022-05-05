class UserData {
  String? uid;
  String? email;
  String? group;
  String? name;
  String? msgToken;
  int? latestTimestamp;
  int? notifyWhenViewCountsEqual;
  String? identity;
  bool? enableViewedNotify;

  UserData(
      {this.uid,
      this.email,
      this.group,
      this.name,
      this.identity,
      this.msgToken,
      this.latestTimestamp,
      this.notifyWhenViewCountsEqual,
      this.enableViewedNotify});

  UserData.fromJson(Map<dynamic, dynamic> json, String id) {
    uid = id;
    email = json['email'];
    group = json['group'];
    name = json['name'];
    msgToken = json['msgToken'];
    latestTimestamp = json['latestTimestamp'];
    identity = json['identity'];
    notifyWhenViewCountsEqual = json['notifyWhenViewCountsEqual'];
    enableViewedNotify = json['enableViewedNotify'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['uid'] = uid;
    data['email'] = email;
    data['group'] = group;
    data['name'] = name;
    data['msgToken'] = msgToken;
    data['latestTimestamp'] = latestTimestamp;
    data['identity'] = identity;
    data['notifyWhenViewCountsEqual'] = notifyWhenViewCountsEqual;
    data['enableViewedNotify'] = enableViewedNotify;
    return data;
  }
}
