import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'User Names',
      home: const MyHomePage(title: 'Use list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Widget activeScreen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activeScreen = LoginPage(onBtnClick: () {
      setState(() {
        activeScreen = FireStorePage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(widget.title)), body: activeScreen);
  }
}

class FireStorePage extends StatelessWidget {
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      key: new ValueKey(document.documentID),
      title: new Container(
        decoration: new BoxDecoration(
          border: new Border.all(color: const Color(0x80000000)),
          borderRadius: new BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(10.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(document['name']),
            ),
            new Text(
              document['isOnline'].toString(),
            ),
          ],
        ),
      ),
      onTap: () => Firestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshSnap =
                await transaction.get(document.reference);
            await transaction.update(
                freshSnap.reference, {'isOnline': !freshSnap['isOnline']});
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          return new ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
              // itemExtent: 25.0,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];
                return _buildListItem(context, ds);
              });
        });
  }
}

class LoginPage extends StatelessWidget {
  VoidCallback onBtnClick;

  LoginPage({this.onBtnClick}){
    final GoogleSignIn googleSignIn = new GoogleSignIn();
      if(googleSignIn.currentUser !=null){
        googleSignIn.signOut();
      }
  }

  @override
  Widget build(BuildContext context){
    return Center(
      child: InkWell(
        highlightColor: Colors.grey,
        splashColor: Colors.red,
        onTap: () async {
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
          GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          if (firebaseUser != null) {
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
          }
          Navigator.of(context, rootNavigator: true).pop();
          onBtnClick();
        },
        child: Text("Sign in with Google"),
      ),
    );
  }
}
