class PhotoData {
  String? pid;
  DateTime? date;
  String? description;
  String? authorId;
  String? path;
  String? filename;
  String? blurHash;
  int? timestamp;

  PhotoData(
      {this.pid,
      this.blurHash,
      this.date,
      this.description,
      this.authorId,
      this.path,
      this.filename,
      this.timestamp});

  PhotoData.fromJson(id, Map<dynamic, dynamic> json) {
    pid = id;
    date = DateTime.parse(json['date']);
    blurHash = json['blurHash'];
    authorId = json['authorId'];
    description = json['description'];
    path = json['path'];
    filename = json['filename'];
    timestamp = json['timestamp'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['date'] = date.toString();
    data['description'] = description;
    data['blurHash'] = blurHash;
    data['authorId'] = authorId;
    data['path'] = path;
    data['filename'] = filename;
    data['timestamp'] = timestamp;
    return data;
  }
}
