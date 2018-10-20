
import 'package:chattao_app/models/chat.dart';
import 'package:meta/meta.dart';

@immutable
class AppState{
  final List<Chat> chats;
  final List<User> friends;
  final bool logined;
  bool listenerRegistered = false;
  User me;
  InitState initState =  InitState.Initing;
  String message = "Initing";
  String pushNotificationToken;

  AppState(this.chats, this.friends, this.logined);

  factory AppState.initial()=>AppState(List(), List(),false);

}


enum InitState{
  Initing, Inited,Error
}