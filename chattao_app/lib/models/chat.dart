import 'dart:async';
import 'dart:io';

import 'package:chattao_app/chats.dart';
import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Chat{
  final User me;
  final User peer;

  DateTime lastUpdated;
  bool enableNotification = true;
  bool isFavorite;
  ChatMessage latestMsg;
  Chat(this.me,this.peer,{this.latestMsg});

  factory Chat.init(me,peer)=>Chat(me,peer);

}

class User{
   final String uid;
   
   String name; 
   String avataURL;
   String nickName;

   User(this.uid);

}


class ChatList{
  List<Chat> activeChatList;
  ChatList(this.activeChatList);

  factory ChatList.init()=>ChatList(List.unmodifiable([]));

  ChatList orderByDate({bool des=true}){
    this.activeChatList.sort((current,next)=>current.lastUpdated.isAfter(next.lastUpdated)?-1:1);
    return this;
  }
}

