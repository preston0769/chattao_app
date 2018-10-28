import 'dart:async';

import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/local_processing/local_rw.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:redux/redux.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class ChatListController {
  final Store<AppState> store;
  StreamSubscription sub;
  User loginUser;

  ChatListController(this.store) {
    assert(store.state.me != null);
    loginUser = store.state.me;
    store.state.chatListCtrler = this;
  }

  updateMsgToServer(User peer, ChatMessage lastMsg) async {
    var chatExists = store.state.chats.any((chat) => chat.peer == peer);
    if (chatExists) {
      var chat = store.state.chats.where((chat) => chat.peer == peer).first;
      chat.lastUpdated =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastMsg.timeStamp));
      chat.latestMsg = lastMsg;
    }

    await _updateChatListOnServer(lastMsg);
    // _updateNewMsgToServer(lastMsg);
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
      try {
        FlutterAppBadger.isAppBadgeSupported().then((supported) {
          if (supported) {
            var count = 0;
            chats.forEach((chat) {
              count = count + chat.unreadMessage;
            });
            FlutterAppBadger.updateBadgeCount(count);
          }
        });
      } catch (ex) {}
    });
  }

  Future _updateChatListOnServer(ChatMessage lastMsg) {
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
      if (message.data != null && message.data.length > 0) {
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

      // Update new message to server
      () async {
        lastMsg.syncing = true;
        // if (lastMsg.type == 1 && lastMsg.localImageFile != null)
        lastMsg.content = await _uploadFile(lastMsg);
        var documentReference = Firestore.instance
            .collection('messages')
            .document(chatId)
            .collection(chatId)
            .document(DateTime.now().millisecondsSinceEpoch.toString());

        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
            {
              'idFrom': idFrom,
              'idTo': idTo,
              'timestamp': lastMsg.timeStamp,
              'content': lastMsg.content,
              'type': lastMsg.type
            },
          );

          lastMsg.syncing = false;
          lastMsg.synced = true;
        });
      }();
    });
  }

  Future _updateNewMsgToServer(ChatMessage newMsg) async {
    try {
      var idFrom = newMsg.idFrom;
      var idTo = newMsg.idTo;
      var chatId = "";
      if (idFrom.hashCode <= idTo.hashCode) {
        chatId = '$idFrom-$idTo';
      } else {
        chatId = '$idTo-$idFrom';
      }

      newMsg.syncing = true;
      if (newMsg.type == 1 && newMsg.localImageFile != null)
        newMsg.content = await _uploadFile(newMsg);
      var documentReference = Firestore.instance
          .collection('messages')
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': idFrom,
            'idTo': idTo,
            'timestamp': newMsg.timeStamp,
            'content': newMsg.content,
            'type': newMsg.type
          },
        );

        newMsg.syncing = false;
        newMsg.synced = true;
      });
    } catch (error) {
      print(error);
      newMsg.syncing = false;
      newMsg.synced = true;
      return;
    }
    newMsg.synced = true;
  }

  Future<String> _uploadFile(ChatMessage newMsg) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    newMsg.serverFileName = fileName;

    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(newMsg.localImageFile);

    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    var imageUrl = downloadUrl.toString();
    newMsg.localImageFile.delete();

    return imageUrl;
  }
}
