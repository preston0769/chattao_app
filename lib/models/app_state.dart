
import 'package:chattao_app/models/chat.dart';
import 'package:meta/meta.dart';

@immutable
class AppState{
  final List<Chat> chats;
  final ListState listState;
  final String message;

  AppState(this.chats,this.listState,this.message);
  factory AppState.initial()=>AppState(List.unmodifiable([]),ListState.listOnly,'Inited');
}


enum ListState{
  listOnly,listWithNewItem
}