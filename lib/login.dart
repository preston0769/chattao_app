import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  Function(String userID) onBtnClick;

  LoginPage({this.onBtnClick}) {
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    if (googleSignIn.currentUser != null) {
      googleSignIn.signOut();
    }
  }

  _showLoader(BuildContext context) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Center(
                heightFactor: 0.3,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
            ));
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
      Navigator.of(context, rootNavigator: true).pop();
      onBtnClick(firebaseUser.uid);
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
         barrierDismissible: true,
          builder: (context) => Container(
                child: Text("Something goes wrong, please try again later"),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             IntrinsicWidth(
                          child: FlatButton(
                padding: EdgeInsets.all(16.0),
                color: Colors.blueAccent,
                onPressed: () async {
                  await _showLoader(context);
                },
                child: Text(
                  "Sign in with Google",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                 
                padding: EdgeInsets.all(16.0),
                color: Colors.grey,
                onPressed: () async {
                  // await _showLoader(context);
                },
                child: Text(
                  "Sign in with SMS(Coming)",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
