import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/models/app_state.dart';

AppState appReducer(AppState state, action){
  if(action is NewChatMsgReceivedAction){
    return new AppState(state.chats,state.listState,action.content);
  }

  if(action is UpdatePushNotificationTokenAction){
    state.updateToken(action.token);
    return state;
  }
return state; 
}