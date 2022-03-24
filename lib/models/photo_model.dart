class PhotoData {
  String? id;
  DateTime? date;
  String? description;
  String? author;
  String? path;

  PhotoData({this.id, this.date, this.description, this.author, this.path});

  PhotoData.fromJson(pid, Map<dynamic, dynamic> json) {
    id = pid;
    date = DateTime.parse(json['date']);
    description = json['description'];
    author = json['author'];
    path = json['path'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['date'] = date.toString();
    data['description'] = description;
    data['author'] = author;
    data['path'] = path;
    return data;
  }
}
