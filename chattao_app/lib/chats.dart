import 'dart:async';
import 'dart:io';

import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/messages.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:chattao_app/sticker_gallery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chattao_app/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatView extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  ChatView(
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
        key: chatScreenKey,
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

  List<ChatMessage> _chatMessages = new List();
  List<ChatMessage> get chatMessages => _chatMessages;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  bool showBottomSafeArea = true;

  bool initialized = false;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();
  StreamSubscription<QuerySnapshot> subscription = null;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal().then((onValue) {
     subscription =  Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .listen((snapShot) {
        listMessage = snapShot.documents;
        _updateLocalMessageList(snapShot);
        _clearUnreadCount();
        // print(snapShot.documents[1].data);
      });
    });
  }

  _clearUnreadCount() {
    var chatListReference =
        Firestore.instance.collection('messages').document(groupChatId);

    chatListReference.get().then((message) {
      if (message.data.length > 0) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            chatListReference,
            {
              'unread-$myId': 0,
              'lastUpdated': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          );
        });
      } else {
        chatListReference.setData({
          'uids': [peerId, myId],
          'lastUpdated': DateTime.now().millisecondsSinceEpoch.toString(),
          'unread-$peerId': 0,
          'unread-$myId': 0,
          'lastmsg': "",
        });
      }
    });
  }

  @override
  dispose() {
    focusNode.removeListener(onFocusChange);
    _chatMessages.clear();
    subscription.cancel();
    super.dispose();
  }

  void onMessageDelele() {
    setState(() {});
  }

  void _updateLocalMessageList(QuerySnapshot snapShot) {
    if (_chatMessages == null || _chatMessages.length == 0) {
      snapShot.documents.forEach((document) {
        _chatMessages.add(new ChatMessage(
            content: document['content'],
            idFrom: document['idFrom'],
            idTo: document['idTo'],
            type: document['type'],
            localImageFile: null,
            documentId: document.documentID,
            timeStamp: document['timestamp']));
      });
    } else {
      //Update message
      snapShot.documents.forEach((document) {
        if (document['idFrom'] == peerId) {
          _chatMessages.firstWhere(
              (message) => message.documentId == document.documentID,
              orElse: () {
            _chatMessages.add(new ChatMessage(
                content: document['content'],
                idFrom: document['idFrom'],
                idTo: document['idTo'],
                type: document['type'],
                localImageFile: null,
                documentId: document.documentID,
                timeStamp: document['timestamp']));
          });
        } else {
          var chatMsg = _chatMessages.firstWhere(
              (message) => message.timeStamp == document['timestamp'],
              orElse: () {});
          if (chatMsg != null) chatMsg.documentId = document.documentID;
        }
      });
    }

    _chatMessages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    if (mounted) {
      setState(() {
        _chatMessages = chatMessages;
      });
    }
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
      _chatMessages.insert(0, chatMsg);
      setState(() {
        _chatMessages = _chatMessages;
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
      _chatMessages.insert(0, chatmsg);
      setState(() {
        // _chatMessages = _chatMessages;
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

  bool isTimeDiffBig(String timeStampMsgPre, String timeStampMsgNow) {
    // Milliseconds format
    var stampPre = int.parse(timeStampMsgPre);
    var stampNow = int.parse(timeStampMsgNow);

    var timeDiff = stampNow - stampPre;

    return timeDiff > 1 * 1000 * 60;
  }

  bool shouldShowTimeSplitter(int index) {
    if ((index > 1 &&
            _chatMessages != null &&
            isTimeDiffBig(_chatMessages[index].timeStamp,
                _chatMessages[index - 1].timeStamp)) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _chatMessages != null &&
            _chatMessages[index - 1].idFrom != myId) ||
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
                      FocusScope.of(context).requestFocus(focusNode);
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
                if (_chatMessages.length < 1) {
                  return initialized
                      ? Center(
                          child: Text("No messages"),
                        )
                      : Center(
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
                          buildItem(index, _chatMessages[index]),
                      itemCount: _chatMessages.length,
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
