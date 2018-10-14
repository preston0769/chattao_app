import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/models/app_state.dart';

AppState appReducer(AppState state, action){
  if(action is newChatMsgReceivedAction){
    return new AppState(state.chats,state.listState,action.content);
  }
return state; 
}