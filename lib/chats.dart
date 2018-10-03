import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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

    readLocal().then( (onValue) {
      Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .listen((documents) {
        print(documents.documents[1].data);
      });
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
      setState(() {
        imageFile = image;
        isLoading = true;
      });
      uploadFile();
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

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': myId,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget _buildChatAvatar(String avatarUrl) {
    return Container(
      height: 32.0,
      width: 32.0,
      color: themeColor,
      child: CachedNetworkImage(
        placeholder: Container(
          child: CircularProgressIndicator(
            strokeWidth: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          ),
          width: 35.0,
          height: 35.0,
          padding: EdgeInsets.all(10.0),
        ),
        imageUrl: avatarUrl ?? "http://nothing.com/gag",
        width: 35.0,
        height: 35.0,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTextIfYes(DocumentSnapshot document, int index, bool highlight) {
    if (document['type'] != 0) return Container();
    return Container(
      constraints: BoxConstraints(maxWidth: 200.0),
      child: Text(
        document['content'],
        style: TextStyle(color: highlight ? Colors.white : primaryColor),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      decoration: BoxDecoration(
          color: highlight ? themeColor : greyColor2,
          borderRadius: BorderRadius.circular(4.0)),
      margin: EdgeInsets.only(
          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
          right: 8.0,
          left: 8.0),
    );
  }

  Widget _buildImageIfYes(DocumentSnapshot document, int index) {
    if (document['type'] != 1) return Container();
    return Container(
      child: Material(
        child: CachedNetworkImage(
          placeholder: Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
            width: 200.0,
            height: 200.0,
            padding: EdgeInsets.all(70.0),
            decoration: BoxDecoration(
              color: greyColor2,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          errorWidget: Material(
            child: Image.asset(
              'images/img_not_available.jpeg',
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          imageUrl: document['content'],
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      margin: EdgeInsets.only(
          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
          right: 8.0,
          left: 8.0),
    );
  }

  Widget _buildStickerIfYes(DocumentSnapshot document, int index) {
    if (document['type'] != 2) return Container();
    return Container(
      child: new Image.asset(
        'images/${document['content']}.gif',
        width: 100.0,
        height: 100.0,
        fit: BoxFit.cover,
      ),
      margin: EdgeInsets.only(
          bottom: isLastMessageRight(index) ? 20.0 : 8.0, right: 8.0),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == myId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          _buildTextIfYes(document, index, true),
          _buildImageIfYes(document, index),
          _buildStickerIfYes(document, index),
          _buildChatAvatar(myAvatar)
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
                _buildChatAvatar(peerAvatar),
                _buildTextIfYes(document, index, false),
                _buildImageIfYes(document, index),
                _buildStickerIfYes(document, index),
              ],
            ),

            // Time
            shouldShowTimeSplitter(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
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
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != myId) ||
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
              (isShowSticker ? buildStickerGallery() : Container()),
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

  Widget buildStickerGallery() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
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
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.documents;
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
                          buildItem(index, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
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
  final MessageType type;
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
      this.localImageFile})
      : timeStamp = DateTime.now().millisecondsSinceEpoch.toString() {
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

  void SyncToServer() async {
    try {
      syncing = true;
      if (type == MessageType.Image && localImageFile != null)
        content = await _uploadFile();
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
            'type': MessageType.values.indexOf(type).toString()
          },
        );
      });
    } catch (error) {
      syncing = false;
      syncFailed = true;
      return;
    }
    synced = true;
  }
}
