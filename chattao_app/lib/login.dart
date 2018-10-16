
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/friends.dart';
import 'package:chattao_app/smsLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = new GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
     signInOption:  SignInOption.standard);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var initialized = false;

  @override
  initState() {
    super.initState();
    readLocal();
  }

  readLocal() async {
    // _showLoader(context);
    var prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('id');
    if (uid != null && uid.isNotEmpty) {
      // _dismissLoader(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return new FriendsPage();
      }));
    } else {
      // _dismissLoader(context);
      setState(() {
        initialized = true;
      });
    }
  }

  _showLoader(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Center(
                heightFactor: 0.3,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
            ));
  }

  _dismissLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  _handleGoogleLogin(BuildContext context) async {
    googleSignIn.scopes
        .addAll(['email', 'https://www.googleapis.com/auth/contacts.readonly']);
    GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser == null) return;

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    if (googleAuth == null) {
      return;
    }
    _showLoader(context);
    FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    if (firebaseUser != null) {
      var prefs = await SharedPreferences.getInstance();

      // Check is already sign up
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
      await prefs.setString('id', firebaseUser.uid);
      await prefs.setString('name', firebaseUser.displayName);
      await prefs.setString('photoUrl', firebaseUser.photoUrl);
      _dismissLoader(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return new FriendsPage();
      }));
    } else {
      _dismissLoader(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: new Text(
        "Login",
        style: TextStyle(color: Colors.white),
      )),
      backgroundColor: Color(0xFFBFBFBF),
      body: !initialized
          ? Container()
          : Center(
              child: IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6.0,
                            offset: Offset(0.0, 3.0))
                      ]),
                      width: double.infinity,
                      child: FlatButton(
                        padding: EdgeInsets.all(16.0),
                        color: themeColor,
                        onPressed: () async {
                          await _handleGoogleLogin(context);
                        },
                        child: Text(
                          "Sign in with Google",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      decoration: BoxDecoration(boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6.0,
                            offset: Offset(0.0, 3.0))
                      ]),
                      width: double.infinity,
                      child: FlatButton(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.amber,
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SMSLoginPage()));
                        },
                        child: Text(
                          "Sign in with SMS",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
