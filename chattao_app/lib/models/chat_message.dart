import 'dart:io';

import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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


  void delete() async {
    final chatState = (chatScreenKey.currentState as InnterChatScreenState);
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
  }

  
}
