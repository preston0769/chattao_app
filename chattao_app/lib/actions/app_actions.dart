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
