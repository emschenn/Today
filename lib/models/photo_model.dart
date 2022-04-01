class PhotoData {
  String? pid;
  DateTime? date;
  String? description;
  String? author;
  String? authorId;
  String? path;
  String? filename;
  int? timestamp;

  PhotoData(
      {this.pid,
      this.date,
      this.description,
      this.author,
      this.authorId,
      this.path,
      this.filename,
      this.timestamp});

  PhotoData.fromJson(id, Map<dynamic, dynamic> json) {
    pid = id;
    date = DateTime.parse(json['date']);
    authorId = json['authorId'];
    description = json['description'];
    author = json['author'];
    path = json['path'];
    filename = json['filename'];
    timestamp = json['timestamp'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['date'] = date.toString();
    data['description'] = description;
    data['author'] = author;
    data['authorId'] = authorId;
    data['path'] = path;
    data['filename'] = filename;
    data['timestamp'] = timestamp;
    return data;
  }
}
