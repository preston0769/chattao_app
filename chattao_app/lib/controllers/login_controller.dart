import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/pages/chat_list_page.dart';
import 'package:chattao_app/routes/slide_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = new GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
    signInOption: SignInOption.standard);

enum LoginStatusEnum {
  Init,
  ObtainPermission,
  TokenReceived,
  StartLogin,
  StatusReceived,
  PostLogin,
  Done
}

class LoginController with ChangeNotifier {
  LoginStatusEnum status = LoginStatusEnum.Init;
  List<String> errors = [];
  String _verificationId;



  Future<String> signInWithPhoneNum(BuildContext context, String smsCode) async {
    final FirebaseUser user = await firebaseAuth.signInWithPhoneNumber(
      verificationId: _verificationId,
      smsCode: smsCode,
    );

    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    assert(user.uid == firebaseUser.uid);

    if (firebaseUser != null) {
      var prefs = await SharedPreferences.getInstance();

      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      var name = (firebaseUser.displayName == null ||
              firebaseUser.displayName.isEmpty)
          ? "TaoChat_" + firebaseUser.uid.substring(firebaseUser.uid.length - 5)
          : firebaseUser.displayName;
      var photoURL = (firebaseUser.photoUrl == null ||
              firebaseUser.photoUrl.isEmpty)
          ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUiD5eyL5b_4gPQ0bG9eYWJ3OAQPBk2IoIIjSTeK1uMCqrA39MYg"
          : firebaseUser.photoUrl;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'isOnline': true,
          'name': name,
          'photoUrl': photoURL,
          'id': firebaseUser.uid
        });
      }

      User me = new User(firebaseUser.uid);
      me.avataURL = photoURL;
      me.name = name;
      me.nickName = name;

      var reduxStore = StoreProvider.of<AppState>(context);
      reduxStore.dispatch(UserLoginedAction(me));

      await prefs.setString('id', firebaseUser.uid);
      await prefs.setString('name', name);
      await prefs.setString('photoUrl', photoURL);

      await _addDeviceTokenIfNotExists(firebaseUser, context);

      return Future.value("");
    }
  }

  handleSmsCodeReceive( BuildContext context,String phoneNumber, VoidCallback codeReceived) async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
          print(user);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
          print(authException);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this._verificationId = verificationId;
      codeReceived();
      // _smsCodeController.text = testSmsCode;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this._verificationId = verificationId;
      // _smsCodeController.text = testSmsCode;
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  handleGoogleLogin(BuildContext context) async {
    googleSignIn.scopes
        .addAll(['email', 'https://www.googleapis.com/auth/contacts.readonly']);
    GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser == null) return;

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    if (googleAuth == null) {
      return;
    }
    status = LoginStatusEnum.StartLogin;
    notifyListeners();
    FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    if (firebaseUser != null) {
      var prefs = await SharedPreferences.getInstance();

      await _addUserToDBIfNotExists(firebaseUser);

      await _addDeviceTokenIfNotExists(firebaseUser, context);

      User me = new User(firebaseUser.uid);
      me.avataURL = firebaseUser.photoUrl;
      me.name = firebaseUser.displayName;
      me.nickName = firebaseUser.displayName;

      var reduxStore = StoreProvider.of<AppState>(context);
      reduxStore.dispatch(UserLoginedAction(me));

      await prefs.setString('id', me.uid);
      await prefs.setString('name', me.name);
      await prefs.setString('photoUrl', me.avataURL);
      status = LoginStatusEnum.Done;
      notifyListeners();
      Navigator.push(context, SlideRoute(widget: new ChatListPage()));
    } else {}
  }

  Future _addDeviceTokenIfNotExists(
      FirebaseUser firebaseUser, BuildContext context) async {
    var reduxStore = StoreProvider.of<AppState>(context);
    var token = reduxStore.state.pushNotificationToken;

    if (token == null) return;

    final QuerySnapshot result = await Firestore.instance
        .collection('devicetokens')
        .where('userId', isEqualTo: firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      Firestore.instance
          .collection('devicetokens')
          .document(firebaseUser.uid)
          .setData({
        'token': token,
        'createdTime': DateTime.now().millisecondsSinceEpoch.toString(),
        'deleted': false,
        'uid': firebaseUser.uid
      });
    } else {
      Firestore.instance
          .collection('devicetokens')
          .document(firebaseUser.uid)
          .updateData({
        'token': token,
      });
    }
  }

  Future _addUserToDBIfNotExists(FirebaseUser firebaseUser) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({
        'isOnline': true,
        'name': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoUrl,
        'id': firebaseUser.uid
      });
    }
  }
}
