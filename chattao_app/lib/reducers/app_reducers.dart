import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/models/app_state.dart';

AppState appReducer(AppState state, action) {
  if (action is UpdateStatusAction) {
    state.message = action.statusMsg;
    return state;
  }

  if (action is UpdateRouteNameAction) {
    state.currentRouteName = action.routeName;
    return state;
  }
  if (action is NewChatMsgReceivedAction) {
    // state.message = action.msg.content;
    var chat =
        state.chats.where((chat) => chat.peer.uid == action.msg.idFrom).first;
    chat.latestMsg = action.msg;
    return state;
  }

  if (action is UpdatePushNotificationTokenAction) {
    state.pushNotificationToken = action.token;
    return state;
  }

  if (action is StartLoadActiveChatAction) {
    state.initState = InitState.Initing;
    return state;
  }

  if (action is LoadActiveChatsFinishedAction) {
    state.chats.clear();
    state.chats.addAll(action.chats);
    return state;
  }

  if (action is UserLogined) {
    state.logined = true;
    state.me = action.me;
    return state;
  }
  if (action is CloudListenerRegistered) {
    state.listenerRegistered = true;
    return state;
  }

  if (action is UpdateFriends) {
    state.friends.clear();
    state.friends.addAll(action.friends);
    return state;
  }

  if (action is UpdateChatListAction) {
    state.chats.clear();
    state.chats.addAll(action.chats);
    state.initState = InitState.Inited;
    return state;
  }

  if (action is SetJumpToPeerAction) {
    state.targetPeerId = action.jumpToPeerId;
    return state;
  }
  if (action is ClearJumpToPeerAction) {
    state.targetPeerId = "";
    return state;
  }

  if(action is UpdateUserNameAction){
    state.me.name = action.newUsername;
    state.me.nickName = action.newUsername;
    return state;
  }

  if(action is SendNewMessageAction){
    state.chatListCtrler.updateChatList(action.peer, action.message);
    return state;
  }

  return state;
}
