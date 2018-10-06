import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattao_app/messages.dart';
import 'package:chattao_app/sticker_gallery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chattao_app/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  Chat(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // leading: Container(child: Icon(Icons.arrow_back,color: Colors.white,)),
        title: new Text(
          peerName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  State createState() =>
      new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String myAvatar;
  String myId;

  List<ChatMessage> chatMessages = new List();

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  bool showBottomSafeArea = true;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal().then((onValue) {
      Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .listen((snapShot) {
        listMessage = snapShot.documents;
        _updateLocalMessageList(snapShot);
        // print(snapShot.documents[1].data);
      });
    });
  }

  @override
  dispose() {
    focusNode.removeListener(onFocusChange);
    super.dispose();
  }

  void _updateLocalMessageList(QuerySnapshot snapShot) {
    if (chatMessages == null || chatMessages.length == 0) {
      snapShot.documents.forEach((document) {
        chatMessages.add(new ChatMessage(
            content: document['content'],
            idFrom: document['idFrom'],
            idTo: document['idTo'],
            type: document['type'],
            localImageFile: null,
            timeStamp: document['timestamp']));
      });
    } else {
      //Update message
      snapShot.documents.forEach((document) {
        if (document['idFrom'] == peerId) {
          chatMessages.firstWhere(
              (message) => message.timeStamp == document['timestamp'],
              orElse: () {
            chatMessages.add(new ChatMessage(
                content: document['content'],
                idFrom: document['idFrom'],
                idTo: document['idTo'],
                type: document['type'],
                localImageFile: null,
                timeStamp: document['timestamp']));
          });
        }
      });
    }

    chatMessages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    setState(() {
      // chatMessages = chatMessages;
    });
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        showBottomSafeArea = false;
        isShowSticker = false;
      });
      return;
    }
    setState(() {
      showBottomSafeArea = true;
    });
  }

  Future readLocal() async {
    prefs = await SharedPreferences.getInstance();
    myId = prefs.getString('id') ?? '';
    if (myId.hashCode <= peerId.hashCode) {
      groupChatId = '$myId-$peerId';
    } else {
      groupChatId = '$peerId-$myId';
    }

    myAvatar = prefs.getString('photoUrl') ?? '';

    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var chatMsg = new ChatMessage(
          localImageFile: image,
          content: "",
          idFrom: myId,
          idTo: peerId,
          timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 1);
      chatMsg.syncToServer();
      chatMessages.insert(0, chatMsg);
      setState(() {
        chatMessages = chatMessages;
      });
    }
  }

  void showStickerGallery() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = true;
      showBottomSafeArea = true;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);

    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    imageUrl = downloadUrl.toString();

    setState(() {
      isLoading = false;
    });

    onSendMessage(imageUrl, 1);
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var chatmsg = new ChatMessage(
          idFrom: myId,
          idTo: peerId,
          content: content,
          type: type,
          timeStamp: DateTime.now().millisecondsSinceEpoch.toString());

      chatmsg.syncToServer();
      chatMessages.insert(0, chatmsg);
      setState(() {
        // chatMessages = chatMessages;
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, ChatMessage message) {
    if (message.idFrom == myId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          TextMessageContent(
              message: message,
              isLastMessageRight: isLastMessageRight(index),
              highlight: true),
          ImageMessageContent(
            isLastMessageRight: isLastMessageRight(index),
            message: message,
          ),
          StickerMessageContent(
            message: message,
            isLastMessageRight: isLastMessageRight(index),
          ),
          ChatAvatar(
            avatarUrl: myAvatar,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ChatAvatar(
                  avatarUrl: peerAvatar,
                ),
                TextMessageContent(
                    message: message,
                    isLastMessageRight: isLastMessageRight(index),
                    highlight: false),
                ImageMessageContent(
                  isLastMessageRight: isLastMessageRight(index),
                  message: message,
                ),
                StickerMessageContent(
                  message: message,
                  isLastMessageRight: isLastMessageRight(index),
                )
              ],
            ),

            // Time
            shouldShowTimeSplitter(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(message.timeStamp))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool shouldShowTimeSplitter(int index) {
    return true;
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            chatMessages != null &&
            chatMessages[index - 1].idFrom != myId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              // Sticker
              (isShowSticker
                  ? StickerGallery(onStickerSelected: onSendMessage)
                  : Container()),
              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: showBottomSafeArea,
        child: Container(
          child: Row(
            children: <Widget>[
              // Button send image
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                child: new IconButton(
                  icon: new Icon(Icons.image),
                  onPressed: getImage,
                  color: primaryColor,
                ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                child: new IconButton(
                  icon: new Icon(Icons.face),
                  onPressed: showStickerGallery,
                  color: primaryColor,
                ),
              ),

              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    style: TextStyle(color: primaryColor, fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type here...',
                      hintStyle: TextStyle(color: greyColor),
                    ),
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (String content) {
                      onSendMessage(content, 0);
                    },
                  ),
                ),
              ),

              // Button send message
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 8.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => onSendMessage(textEditingController.text, 0),
                  color: themeColor,
                ),
              ),
            ],
          ),
          width: double.infinity,
          height: 50.0,
          decoration: new BoxDecoration(
              border: new Border(
                  top: new BorderSide(color: greyColor2, width: 0.5)),
              color: Colors.white),
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : Builder(
              builder: (context) {
                if (chatMessages.length < 1) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  return GestureDetector(
                    onTap: () {
                      focusNode.unfocus();
                      setState(() {
                        isShowSticker = false;
                        showBottomSafeArea = true;
                      });
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(index, chatMessages[index]),
                      itemCount: chatMessages.length,
                      reverse: true,
                      controller: listScrollController,
                    ),
                  );
                }
              },
            ),
    );
  }
}

class ChatMessage {
  final int type;
  String content;
  final String idFrom;
  final String idTo;
  final String timeStamp;

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
      this.localImageFile}) {
    if (idFrom.hashCode <= idTo.hashCode) {
      chatId = '$idFrom-$idTo';
    } else {
      chatId = '$idTo-$idFrom';
    }
  }
  Future<String> _uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(localImageFile);

    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    var imageUrl = downloadUrl.toString();

    return imageUrl;
  }

  void syncToServer() async {
    try {
      syncing = true;
      if (type == 1 && localImageFile != null) content = await _uploadFile();
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
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
        syncing = false;
        synced = true;
      });
    } catch (error) {
      syncing = false;
      syncFailed = true;
      return;
    }
    synced = true;
  }
}
