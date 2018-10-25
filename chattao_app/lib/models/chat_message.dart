import 'dart:async';
import 'dart:io';

import 'package:chattao_app/chats.dart';
import 'package:chattao_app/keys/global_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final int type;
  String content;
  final String idFrom;
  final String idTo;
  final String timeStamp;
  String documentId;
  String serverFileName;
  String localFilePath;

  final File localImageFile;

  bool synced = false;
  bool syncing = false;
  bool syncFailed = false;
  String chatId = "";

  ChatMessage(
      {@required this.type,
      @required this.content,
      @required this.idFrom,
      @required this.idTo,
      @required this.timeStamp,
      this.documentId,
      this.localImageFile}) {
    if (idFrom.hashCode <= idTo.hashCode) {
      chatId = '$idFrom-$idTo';
    } else {
      chatId = '$idTo-$idFrom';
    }
  }

  ChatMessage.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        content = json['content'],
        idFrom = json['idFrom'],
        idTo = json['idTo'],
        timeStamp = json['timeStamp'],
        documentId = json['documentId'],
        localImageFile = null {
    synced = json['synced'];
    syncing = json['syncing'];
    syncFailed = json['syncFailed'];
  }

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'content': content,
        'documentId': documentId,
        'idFrom': idFrom,
        'idTo': idTo,
        'timeStamp': timeStamp,
        'synced': synced,
        'syncing': syncing,
        'syncFailed': syncFailed,
      };

  Future<String> _uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    serverFileName = fileName;

    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(localImageFile);

    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    var imageUrl = downloadUrl.toString();

    return imageUrl;
  }

  void Delete() async {
    final chatState = (chatScreenKey.currentState as ChatScreenState);
    chatState.chatMessages.remove(this);
    chatState.onMessageDelele();

    deleteOnServer(this);
  }

  void deleteOnServer(ChatMessage message) async {
    if (message.type == 1) {}
    var documentReference = Firestore.instance
        .collection('messages')
        .document(message.chatId)
        .collection(message.chatId)
        .document(message.documentId);
    documentReference.delete();

    // Firestore.instance.runTransaction((transaction) async {
    //   await transaction.delete(documentReference);
    // });
  }

  Future syncToServer() async {
    try {
      syncing = true;
      if (type == 1 && localImageFile != null) content = await _uploadFile();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      // var chatListReference =
      //     Firestore.instance.collection('messages').document(chatId);
      // var contentShort =
      //     type == 1 ? "[Image]" : type == 2 ? "[Sticker]" : content;
      // chatListReference.get().then((message) {
      //   if (message.data.length > 0) {
      //     Firestore.instance.runTransaction((transaction) async {
      //       await transaction.update(
      //         chatListReference,
      //         {
      //           'lastmsg': contentShort,
      //           'unread-$idTo': message['unread-$idTo'] + 1,
      //           'lastUpdated': this.timeStamp,
      //         },
      //       );
      //     });
      //   } else {
      //     chatListReference.setData({
      //       'uids': [idFrom, idTo],
      //       'lastUpdated': DateTime.now().millisecondsSinceEpoch.toString(),
      //       'unread-$idFrom': 0,
      //       'unread-$idTo': 1,
      //       'lastmsg': contentShort,
      //     });
      //   }
      // });

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': idFrom,
            'idTo': idTo,
            'timestamp': this.timeStamp,
            'content': content,
            'type': type
          },
        );

        syncing = false;
        synced = true;
      });
    } catch (error) {
      print(error);
      syncing = false;
      syncFailed = true;
      return;
    }
    synced = true;
  }
}
