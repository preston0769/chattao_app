import 'package:chattao_app/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future updateUserNameHandler(User user, String newUsername) async {
  await Firestore.instance.collection('users').document(user.uid).updateData({
    'name': newUsername,
  });

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('name', newUsername);

  return Future.value(null);
}
