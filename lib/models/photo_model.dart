class PhotoData {
  String? pid;
  DateTime? date;
  String? description;
  String? authorId;
  String? filename;
  String? blurHash;

  PhotoData({
    this.pid,
    this.blurHash,
    this.date,
    this.description,
    this.authorId,
    this.filename,
  });

  PhotoData.fromJson(String? id, Map<dynamic, dynamic> json) {
    pid = id;
    date = DateTime.parse(json['date']);
    blurHash = json['blurHash'];
    authorId = json['authorId'];
    description = json['description'];
    filename = json['filename'];
  }

  PhotoData.fromJsonWithId(Map<dynamic, dynamic> json) {
    pid = json['pid'];
    date = DateTime.parse(json['date']);
    blurHash = json['blurHash'];
    authorId = json['authorId'];
    description = json['description'];
    filename = json['filename'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['date'] = date.toString();
    data['description'] = description;
    data['blurHash'] = blurHash;
    data['authorId'] = authorId;
    data['filename'] = filename;
    return data;
  }

  //  @override
  // String toString() {
  //   return '{ ${this.date}, ${this.age} }';
  // }
}
