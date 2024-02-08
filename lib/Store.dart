class Store{
  int? id;
  String name;
  String path;
  int listId;

  Store({required this.name, required this.path,
    required this.listId});

  Store.fromMap(Map<dynamic, dynamic> item):
        id = item["id"], name = item["name"], path = item["path"],
        listId = item["listId"];

  Map<String, Object> toMap(){
    return {'name': name, 'path': path, 'listId': listId};
  }
}