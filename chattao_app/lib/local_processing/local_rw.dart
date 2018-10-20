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
  final file = await _localFile;
  
  // Write the file
  return file.writeAsString(json.encode(chatList));
}

Future<List<Chat>> readChatList() async {
  try {
    final file = await _localFile;

    // Read the file
    String contents = await file.readAsString();

    return json.decode(contents);
  } catch (e) {
    // If we encounter an error, return 0
    return null;
  }
}
