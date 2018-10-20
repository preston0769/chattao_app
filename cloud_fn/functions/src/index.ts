import * as functions from "firebase-functions";

import * as admin from "firebase-admin";

admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

export const triggerMessage = functions.firestore
  .document("messages/{messageId}/{messageCollectionId}/{documentId}")
  .onCreate((snap, context) => {
    const message = snap.data();
    console.log(message);

    var tokenRefPromise = admin
      .firestore()
      .collection("devicetokens").doc(message.idTo).get();
    var userRefPromise = admin
      .firestore()
      .collection("users").doc(message.idFrom).get();

    return Promise.all([tokenRefPromise, userRefPromise])
      .then(results => {

        var tokenRef = results[0];
        var userRef = results[1];
        console.log(tokenRef.data());
        console.log(userRef.data());

        var targetToken = tokenRef.data().token;
        var user = userRef.data();

        const content = message.type === 1?"[Image]":message.type===2?"[Sticker]":(message.content as String).substring(0,27);
        const payload = {
          notification: {
            title: user.name,
            body:content,
          },
          data:{
            idFrom: message.idFrom,
            click_action:"FLUTTER_NOTIFICATION_CLICK",
          }
        };
        admin
          .messaging()
          .sendToDevice(targetToken, payload)
          .then(response => {
            console.log("Successfully sent message:", response);
          })
          .catch(error => {
            console.error("Send messag error", error);
          });
      })
      .catch(error => console.error(error));
  });
