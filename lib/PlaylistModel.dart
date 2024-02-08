class PlayListModel {
  int? id;
  String name;

  PlayListModel({required this.name});

  PlayListModel.fromMap(Map<dynamic, dynamic> item):
        id = item["id"], name = item["name"];

  Map<String, Object> toMap(){
    return {'name': name};
  }
}