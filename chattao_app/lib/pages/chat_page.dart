import 'dart:async';
import 'dart:io';

import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/elements/avatar_element.dart';
import 'package:chattao_app/elements/image_message_element.dart';
import 'package:chattao_app/elements/sticker_message_element.dart';
import 'package:chattao_app/elements/text_message_element.dart';
import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:chattao_app/views/sticker_gallery_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chattao_app/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ChatPage extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  ChatPage(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          peerName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StoreConnector<AppState, User>(
        converter: (store) {
          return store.state.friends.where((f) => f.uid == peerId).first;
        },
        builder: (context, user) => new InnterChatScreen(
              user,
              key: chatScreenKey,
            ),
      ),
    );
  }
}

class InnterChatScreen extends StatefulWidget {
  final User peer;

  InnterChatScreen(
    this.peer, {
    Key key,
  }) : super(key: key);

  @override
  State createState() =>
      new InnterChatScreenState(peerId: peer.uid, peerAvatar: peer.avataURL);
}

class InnterChatScreenState extends State<InnterChatScreen> {
  InnterChatScreenState(
      {Key key, @required this.peerId, @required this.peerAvatar});

  Store<AppState> reduxStore;

  String peerId;
  String peerAvatar;
  String myAvatar;
  String myId;

  List<ChatMessage> _chatMessages = new List();
  List<ChatMessage> get chatMessages => _chatMessages;

  List<DocumentSnapshot> listMessage;
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
  StreamSubscription<QuerySnapshot> subscription;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(() {
      if ((focusNode.hasFocus || isShowSticker) &&
          listScrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        focusNode.unfocus();
        setState(() {
          showBottomSafeArea = true;
          isShowSticker = false;
        });
      }
    });

    listScrollController.addListener(() {
      if (listScrollController.position.pixels >
              (listScrollController.position.maxScrollExtent + 10.0) &&
          !isLoading)
      // if (listScrollController.position.outOfRange && !isLoading)
      {
        _loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reduxStore = StoreProvider.of<AppState>(context);
      setState(() {
        initialized = true;
      });
    });

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal().then((onValue) {
      subscription = Firestore.instance
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

  _loadMore() async {
    isLoading = true;
    await Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .startAfter([listMessage.last.data['timestamp']])
        .limit(20)
        .getDocuments()
        .then((queryResult) {
          isLoading = false;
          listMessage = queryResult.documents;
          _updateLocalMessageList(queryResult, isAppend: true);
        }, onError: () {
          isLoading = false;
        })
        .catchError((error) {
          isLoading = false;
        });
  }

  _clearUnreadCount() {
    var chatListReference =
        Firestore.instance.collection('messages').document(groupChatId);

    chatListReference.get().then((message) {
      if (message.data == null) {
        return;
      } else if (message.data.length > 0) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            chatListReference,
            {
              'unread-$myId': 0,
              // 'lastUpdated': DateTime.now().millisecondsSinceEpoch.toString(),
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

  void _updateLocalMessageList(QuerySnapshot snapShot,
      {bool isAppend = false}) {
    if (_chatMessages == null || _chatMessages.length == 0 || isAppend) {
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

    File compressedFile = await FlutterNativeImage.compressImage(
      image.path,
      quality: 50,
      percentage: 30,
    );

    // final tempDir = await getTemporaryDirectory();
    // final path = tempDir.path;
    // int rand = new Random().nextInt(10000);

    // Im.Image fullsizeImg = Im.decodeImage(image.readAsBytesSync());
    // Im.Image smallerImage = Im.copyResize(fullsizeImg,
    //     400); // choose the size here, it will maintain aspect ratio

    // var compressedImage = new File('$path/img_$rand.jpg')
    //   ..writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 60));
    if (image != null) {
      var chatMsg = new ChatMessage(
          localImageFile: compressedFile,
          content: "",
          idFrom: myId,
          idTo: peerId,
          timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 1);
      _chatMessages.insert(0, chatMsg);
      reduxStore.dispatch(SendNewMessageAction(null, widget.peer, chatMsg));

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

      _chatMessages.insert(0, chatmsg);
      reduxStore.dispatch(SendNewMessageAction(null, widget.peer, chatmsg));
      setState(() {
        // _chatMessages = _chatMessages;
      });
      if (_chatMessages.length > 1)
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, ChatMessage message) {
    var isSelf = message.idFrom == myId;
    var avartar = isSelf ? myAvatar : peerAvatar;

    return Container(
      child: Column(
        children: <Widget>[
          shouldShowTimeSplitter(index) ? TimeSplitter(message) : Container(),
          MessageItemView(
            message,
            avartar,
            index,
            isLastMessageRight,
            isSelf: isSelf,
          ),
          // Time
        ],
      ),
      margin: EdgeInsets.only(bottom: 10.0),
    );
  }

  bool isTimeDiffBig(String timeStampMsgPre, String timeStampMsgNow) {
    // Milliseconds format
    var stampPre = int.parse(timeStampMsgPre);
    var stampNow = int.parse(timeStampMsgNow);

    var timeDiff = stampNow - stampPre;

    return timeDiff > 2 * 1000 * 60;
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
              buildLoading(),
              // List of messages
              buildListMessage(),
              // Sticker
              (isShowSticker
                  ? StickerGalleryView(onStickerSelected: onSendMessage)
                  : Container()),
              // Input content
              buildInput(),
            ],
          ),

          // Loading
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return isLoading
        ? Container(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
            ),
            // color: Colors.white.withOpacity(0.8),
          )
        : Container();
  }

  Widget buildInput() {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: showBottomSafeArea,
        child: Container(
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.end,
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
                  constraints: BoxConstraints(maxHeight: 50.0),
                  child: Container(
                    color: Color(0xFFEFEFEF),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextField(
                        // maxLines: null,
                        // keyboardType: TextInputType.multiline,
                        scrollPadding: EdgeInsets.all(4.0),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15.0,
                        ),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type here...',
                          hintStyle: TextStyle(
                            color: greyColor,
                          ),
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
                    child: Scrollbar(
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(index, _chatMessages[index]),
                        itemCount: _chatMessages.length,
                        reverse: true,
                        controller: listScrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}

class MessageItemView extends StatelessWidget {
  final ChatMessage message;
  final String avatarUrl;
  final int index;
  final Function(int) isLastMessageRight;
  final bool isSelf;

  MessageItemView(
      this.message, this.avatarUrl, this.index, this.isLastMessageRight,
      {this.isSelf = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        isSelf
            ? Container()
            : AvatarElement(
                avatarUrl: avatarUrl,
              ),
        TextMessageElement(
            message: message,
            isLastMessageRight: isLastMessageRight(index),
            highlight: isSelf),
        ImageMessageElement(
          isLastMessageRight: isLastMessageRight(index),
          message: message,
        ),
        StickerMessageElement(
          message: message,
          isLastMessageRight: isLastMessageRight(index),
        ),
        isSelf
            ? AvatarElement(
                avatarUrl: avatarUrl,
              )
            : Container(),
      ],
    );
  }
}

class TimeSplitter extends StatelessWidget {
  final ChatMessage message;
  TimeSplitter(this.message);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        //  alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.grey.shade300),
        child: Text(
          DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(message.timeStamp))),
          style: TextStyle(
            color: Colors.black.withAlpha(200),
            fontSize: 10.0,
          ),
        ),
        margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 12.0),
      ),
    );
  }
}
