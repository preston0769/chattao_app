import 'dart:async';

import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/local_processing/local_rw.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux/redux.dart';

class ChatListController {
  final Store<AppState> store;
  StreamSubscription sub;
  User loginUser;

  ChatListController(this.store) {
    assert(store.state.me != null);
    loginUser = store.state.me;
    store.state.chatListCtrler = this;
  }

  updateChatList(User peer, ChatMessage lastMsg) {
    var chat = store.state.chats.where((chat) => chat.peer == peer).first;
    if (chat != null) {
      chat.lastUpdated =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastMsg.timeStamp));
      chat.latestMsg = lastMsg;
    }

    updateServer(lastMsg);
  }

  saveToLocal() async {
    await writeChatList(store.state.chats);
  }

  Future readFromLocal() async {
    var chatList = await readChatList();
    if (chatList.length < 1) return null;
    store.state.chats.clear();
    store.state.chats.addAll(chatList);
    return null;
  }

  streamFromServer() async {
    var me = loginUser;
    assert(me != null);
    sub = Firestore.instance
        .collection('messages')
        .where('uids', arrayContains: me.uid)
        .snapshots()
        .listen((snapshot) {
      List<Chat> chats = new List();
      List<User> users = store.state.friends;

      snapshot.documents.forEach((document) {
        List<String> uids =
            List<String>.from((document['uids'] as List<dynamic>));

        String peerId = uids.where((uid) => uid != me.uid).first;

        if (peerId != null || peerId.isNotEmpty) {
          User peer = users.where((user) => user.uid == peerId).first;

          Chat chat = new Chat(me, peer);

          chat.lastUpdated = DateTime.fromMillisecondsSinceEpoch(
              int.parse(document['lastUpdated']));
          chat.unreadMessage = document['unread-${chat.me.uid}'];
          ChatMessage lastmsg = new ChatMessage(
              idFrom: peer.uid,
              idTo: me.uid,
              timeStamp: document['lastUpdated'],
              content: document['lastmsg'],
              type: -1);
          chat.latestMsg = lastmsg;
          chats.add(chat);
        }
      });

      store.dispatch(UpdateChatListAction(chats));
      saveToLocal();
    });
  }

  updateServer(ChatMessage lastMsg) {
    var idFrom = lastMsg.idFrom;
    var idTo = lastMsg.idTo;
    var type = lastMsg.type;
    var content = lastMsg.content;
    var timeStamp = lastMsg.timeStamp;

    var chatId = "";
    if (idFrom.hashCode <= idTo.hashCode) {
      chatId = '$idFrom-$idTo';
    } else {
      chatId = '$idTo-$idFrom';
    }

    var chatListReference =
        Firestore.instance.collection('messages').document(chatId);
    var contentShort =
        type == 1 ? "[Image]" : type == 2 ? "[Sticker]" : content;
    chatListReference.get().then((message) {
      if (message.data.length > 0) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            chatListReference,
            {
              'lastmsg': contentShort,
              'unread-$idTo': message['unread-$idTo'] + 1,
              'lastUpdated': timeStamp,
            },
          );
        });
      } else {
        chatListReference.setData({
          'uids': [idFrom, idTo],
          'lastUpdated': DateTime.now().millisecondsSinceEpoch.toString(),
          'unread-$idFrom': 0,
          'unread-$idTo': 1,
          'lastmsg': contentShort,
        });
      }
    });
  }
}
