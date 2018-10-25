
import 'package:chattao_app/controllers/chat_list_controller.dart';
import 'package:chattao_app/models/chat.dart';

class AppState{
  final List<Chat> chats;
  final List<User> friends;
  bool logined;
  bool listenerRegistered = false;
  String targetPeerId;
  User me;
  InitState initState =  InitState.Initing;
  String message = "--";
  String pushNotificationToken;
  String currentRouteName = "route";
  
  ChatListController chatListCtrler;


  AppState(this.chats, this.friends, this.logined);

  factory AppState.initial()=>AppState(List(), List(),false);

}


enum InitState{
  Initing, Inited,Error
}