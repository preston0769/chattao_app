import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chattao_app/models/chat.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/chatList.json');
}

Future<File> writeChatList(List<Chat> chatList) async {
  if (chatList.length < 1) return null;
  final file = await _localFile;
  // Write the file
  var jsonStr = json.encode(chatList);
  return file.writeAsString(jsonStr);
}

clearLocal() async {
  final directory = await getApplicationDocumentsDirectory();
  await directory.list().forEach((f) {
    f.delete();
  });
}

Future<List<Chat>> readChatList() async {
  try {
    List<Chat> chats = [];
    final file = await _localFile;
    // Read the file
    String contents = await file.readAsString();
    List mapList = json.decode(contents);

    mapList.forEach((map) {
      chats.add(Chat.fromJson(map));
    });
    return chats;
  } catch (e) {
    // If we encounter an error, return 0
    return [];
  }
}
