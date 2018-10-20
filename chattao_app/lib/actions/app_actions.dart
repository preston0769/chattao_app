import 'package:chattao_app/models/chat.dart';

class NewChatMsgReceivedAction {
  final int idFrom;
  final int idTo;
  final String content;
  NewChatMsgReceivedAction(this.idFrom, this.idTo, this.content);
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

