class Topic {

  String name;
  bool is_subscribed;
  String id;

  Topic({this.id , this.name , this.is_subscribed});

  Topic.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        is_subscribed = json['is_subscribed'];

  Map toJson() {
    return {'id': id, 'name': name, 'is_subscribed': is_subscribed};
  }
}