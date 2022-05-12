import 'dart:core';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Dbpaths.dart';
import 'package:gpchat/Screens/auth_screens/authentication.dart';
import 'package:gpchat/Models/DataModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gpchat/Configs/Enum.dart';

class ChatController {
  static request(currentUserNo, peerNo, chatid) async {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .set({'$peerNo': ChatStatus.accepted.index}, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(peerNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .set({'$currentUserNo': ChatStatus.accepted.index},
            SetOptions(merge: true));
    var doc = await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc('$peerNo')
        .get();
    FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatid)
        .update(
      {'$peerNo': doc[Dbkeys.lastSeen]},
    );
  }

  static accept(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .update(
      {'$peerNo': ChatStatus.accepted.index},
    );

    //   FirebaseFirestore.instance
    //       .collection(DbPaths.collectionusers)
    //       .doc(peerNo)
    //       .collection(Dbkeys.chatsWith)
    //       .doc(Dbkeys.chatsWith)
    //       .update(
    //     {'$currentUserNo': ChatStatus.accepted.index},
    //   );
  }

  static block(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .set({'$peerNo': ChatStatus.blocked.index}, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(GPChat.getChatId(currentUserNo, peerNo))
        .set({'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
            SetOptions(merge: true));
    // GPChat.toast('Blocked.');
  }

  static Future<ChatStatus> getStatus(currentUserNo, peerNo) async {
    var doc = await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .get();
    return ChatStatus.values[doc[peerNo]];
  }

  static hideChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .set({
      Dbkeys.hidden: FieldValue.arrayUnion([peerNo])
    }, SetOptions(merge: true));
    // GPChat.toast(  'Chat hidden.');
  }

  static unhideChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .set({
      Dbkeys.hidden: FieldValue.arrayRemove([peerNo])
    }, SetOptions(merge: true));
    // GPChat.toast('Chat is visible.');
  }

  static lockChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .set({
      Dbkeys.locked: FieldValue.arrayUnion([peerNo])
    }, SetOptions(merge: true));
    // GPChat.toast('Chat locked.');
  }

  static unlockChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .set({
      Dbkeys.locked: FieldValue.arrayRemove([peerNo])
    }, SetOptions(merge: true));
    // GPChat.toast('Chat unlocked.');
  }

  static void authenticate(DataModel model, String caption,
      {required NavigatorState state,
      AuthenticationType type = AuthenticationType.passcode,
      required SharedPreferences prefs,
      required Function onSuccess,
      required bool shouldPop}) {
    Map<String, dynamic>? user = model.currentUser;
    // ignore: unnecessary_null_comparison
    if (user != null && model != null) {
      state.push(MaterialPageRoute<bool>(
          builder: (context) => Authenticate(
              shouldPop: shouldPop,
              caption: caption,
              type: type,
              model: model,
              state: state,
              answer: user[Dbkeys.answer],
              passcode: user[Dbkeys.passcode],
              question: user[Dbkeys.question],
              phoneNo: user[Dbkeys.phone],
              prefs: prefs,
              onSuccess: onSuccess)));
    }
  }
}
