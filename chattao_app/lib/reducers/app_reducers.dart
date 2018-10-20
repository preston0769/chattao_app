import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/models/app_state.dart';

AppState appReducer(AppState state, action){

  if(action is NewChatMsgReceivedAction){
    state.message = action.msg.content;
    return state;
  }

  if(action is UpdatePushNotificationTokenAction){
    state.pushNotificationToken= action.token;
    return state;
  }

  if(action is StartLoadActiveChatAction){
    state.initState = InitState.Initing;
    return state;
  }

  if(action is LoadActiveChatsFinishedAction){
    state.chats.clear();
    state.chats.addAll(action.chats);
    return state;
  }

   if(action is UserLogined){

     var newstate = new AppState(state.chats, state.friends, true);
     newstate.me = action.me;
     return newstate;

   }
   if(action is CloudListenerRegistered){
     state.listenerRegistered = true;
     return state;
   }

   if(action is UpdateFriends){
     state.friends.clear();
     state.friends.addAll(action.friends);
     return state;
   }

   if(action is UpdateChatList){
     state.chats.clear();
     state.chats.addAll(action.chats);
     return state;
   }

   if(action is SetJumpToPeerAction){
     state.targetPeerId = action.jumpToPeerId;
     return state;
   }
   if(action is  ClearJumpToPeerAction){
     state.targetPeerId =  "";
     return state;
   }

return state; 
}