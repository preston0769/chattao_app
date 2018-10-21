import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/models/chat_message.dart';

class NewChatMsgReceivedAction {
  ChatMessage msg;
  NewChatMsgReceivedAction(this.msg);
}

class UpdateStatusAction{
  String statusMsg;
  UpdateStatusAction(this.statusMsg);
}

class UpdatePushNotificationTokenAction {
  final String token;

  UpdatePushNotificationTokenAction(this.token);
}

class StartLoadActiveChatAction{

}
class LoadActiveChatsFinishedAction{
  final List<Chat> chats;

  LoadActiveChatsFinishedAction(this.chats);
}

class UserLogined{
  final User me;
  
  UserLogined(this.me);
}

class CloudListenerRegistered{

}

class UpdateFriends{
  final List<User> friends;

   UpdateFriends(this.friends);
}

class UpdateChatList{
  final List<Chat> chats;
  UpdateChatList(this.chats);
}

class SetJumpToPeerAction{
  String jumpToPeerId;
  SetJumpToPeerAction(this.jumpToPeerId);
}

class ClearJumpToPeerAction{
}

