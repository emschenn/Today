class UserData {
  String? uid;
  String? email;
  String? group;
  String? name;
  bool? isParent;

  UserData({this.uid, this.email, this.group, this.name, this.isParent});

  UserData.fromJson(Map<dynamic, dynamic> json) {
    uid = json['uid'];
    email = json['email'];
    group = json['group'];
    name = json['name'];
    isParent = json['isParent'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['id'] = uid;
    data['email'] = email;
    data['group'] = group;
    data['name'] = name;
    return data;
  }
}
