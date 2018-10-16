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
      .collection("users").doc(message.idTo).get();

    return Promise.all([tokenRefPromise, userRefPromise])
      .then(results => {

        var tokenRef = results[0];
        var userRef = results[1];
        console.log(tokenRef.data());
        console.log(userRef.data());

        var targetToken = tokenRef.data().token;
        var user = userRef.data();

        const payload = {
          notification: {
            title: user.name,
            body: message.content
          },
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
