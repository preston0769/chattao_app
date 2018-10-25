import 'dart:core';

import 'package:chattao_app/models/chat_message.dart';

class Chat {
  final User me;
  final User peer;

  DateTime lastUpdated;
  bool enableNotification = true;
  bool isFavorite;
  ChatMessage latestMsg;
  int unreadMessage = 0;
  Chat(this.me, this.peer, {this.latestMsg});

  factory Chat.init(me, peer) => Chat(me, peer);

  Chat.fromJson(Map<String, dynamic> json)
      : me = User.fromJson(json["me"]),
        peer = User.fromJson(json["peer"]) {
    lastUpdated = DateTime.parse(json['lastUpdated']);
    enableNotification = json['enableNotification'];
    isFavorite = json['isFavorite'];
    latestMsg = ChatMessage.fromJson(json['latestMsg']);
    unreadMessage = json['unreadMessage'];
  }

  Map<String, dynamic> toJson() => {
        'me': me,
        'peer': peer,
        'lastUpdated': lastUpdated.toIso8601String(),
        'enableNotification': enableNotification,
        'isFavorite': isFavorite,
        'latestMsg': latestMsg,
        'unreadMessage': unreadMessage
      };
}

class User {
  final String uid;

  String name;
  String avataURL;
  String nickName;

  User(this.uid);

  User.fromJson(Map<String, dynamic> json) : uid = json['uid'] {
    name = json['name'];
    avataURL = json['avataURL'];
    nickName = json['name'];
  }

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'name': name, 'avataURL': avataURL, 'nickName': nickName};
}

class ChatList {
  List<Chat> activeChatList;
  ChatList(this.activeChatList);

  factory ChatList.init() => ChatList(List.unmodifiable([]));

  ChatList orderByDate({bool des = true}) {
    this.activeChatList.sort((current, next) =>
        current.lastUpdated.isAfter(next.lastUpdated) ? -1 : 1);
    return this;
  }
}
