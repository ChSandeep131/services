// ignore_for_file: file_names

class ChatUser {
  ChatUser({
    required this.id,
    required this.name,
    required this.about,
    required this.email,
    required this.image,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
  });
  late String id;
  late String name;
  late String about;
  late String email;
  late String image;
  late String createdAt;
  late bool isOnline;
  late String lastActive;
  late String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    email = json['email'] ?? '';
    image = json['image'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['about'] = about;
    data['email'] = email;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['push_token'] = pushToken;
    return data;
  }
}
