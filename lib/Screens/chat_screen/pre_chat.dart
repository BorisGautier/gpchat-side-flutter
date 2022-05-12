import 'dart:core';
import 'package:gpchat/Configs/optional_constants.dart';
import 'package:gpchat/Screens/chat_screen/lazyLoadingChat.dart';
import 'package:gpchat/widgets/CountryPicker/CountryCode.dart';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Dbpaths.dart';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Screens/chat_screen/chat.dart';
import 'package:gpchat/Models/DataModel.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:gpchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreChat extends StatefulWidget {
  final String? name, phone, currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const PreChat(
      {required this.name,
      required this.prefs,
      required this.phone,
      required this.currentUserNo,
      required this.model});

  @override
  _PreChatState createState() => _PreChatState();
}

class _PreChatState extends State<PreChat> {
  bool? isLoading, isUser = false;
  bool issearching = true;
  String? peerphone;
  bool issearchraw = false;
  String? formattedphone;

  @override
  initState() {
    super.initState();

    isLoading = true;
    String? peer = widget.phone;
    // String peer = '+213-0791809113';
    setState(() {
      peerphone = peer!.replaceAll(new RegExp(r'-'), '');
      peerphone!.trim();
    });

    formattedphone = peerphone;

    if (!peerphone!.startsWith('+')) {
      if ((peerphone!.length > 11)) {
        CountryCodes.forEach((code) {
          if (peerphone!.startsWith(code) && issearching == true) {
            setState(() {
              formattedphone =
                  peerphone!.substring(code.length, peerphone!.length);
              issearchraw = true;
              issearching = false;
            });
          }
        });
      } else {
        setState(() {
          setState(() {
            issearchraw = true;
            formattedphone = peerphone;
          });
        });
      }
    } else {
      setState(() {
        issearchraw = false;
        formattedphone = peerphone;
      });
    }

    getUser();
  }

  getUser() {
    Query<Map<String, dynamic>> query = issearchraw == true
        ? FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.phoneRaw, isEqualTo: formattedphone ?? peerphone)
            .limit(1)
        : FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.phone, isEqualTo: formattedphone ?? peerphone)
            .limit(1);

    query.get().then((user) {
      setState(() {
        isUser = user.docs.length == 0 ? false : true;
      });
      if (isUser!) {
        Map<String, dynamic> peer = user.docs[0].data();
        widget.model!.addUser(user.docs[0]);
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => IsLazyLoadingChat == false
                    ? ChatScreen(
                        isSharingIntentForwarded: false,
                        prefs: widget.prefs,
                        unread: 0,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model!,
                        peerNo: peer[Dbkeys.phone])
                    : LazyLoadingChat(
                        isSharingIntentForwarded: false,
                        prefs: widget.prefs,
                        unread: 0,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model!,
                        peerNo: peer[Dbkeys.phone])));
      } else {
        Query<Map<String, dynamic>> queryretrywithoutzero = issearchraw == true
            ? FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phoneRaw,
                    isEqualTo: formattedphone == null
                        ? peerphone!.substring(1, peerphone!.length)
                        : formattedphone!.substring(1, formattedphone!.length))
                .limit(1)
            : FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phoneRaw,
                    isEqualTo: formattedphone == null
                        ? peerphone!.substring(1, peerphone!.length)
                        : formattedphone!.substring(1, formattedphone!.length))
                .limit(1);
        queryretrywithoutzero.get().then((user) {
          setState(() {
            isLoading = false;
            isUser = user.docs.length == 0 ? false : true;
          });
          if (isUser!) {
            Map<String, dynamic> peer = user.docs[0].data();
            widget.model!.addUser(user.docs[0]);
            Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => IsLazyLoadingChat == false
                        ? ChatScreen(
                            isSharingIntentForwarded: false,
                            prefs: widget.prefs,
                            unread: 0,
                            currentUserNo: widget.currentUserNo,
                            model: widget.model!,
                            peerNo: peer[Dbkeys.phone])
                        : LazyLoadingChat(
                            isSharingIntentForwarded: false,
                            prefs: widget.prefs,
                            unread: 0,
                            currentUserNo: widget.currentUserNo,
                            model: widget.model!,
                            peerNo: peer[Dbkeys.phone])));
          }
        });
      }
    });
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading!
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(gpchatBlue)),
              ),
              color: gpchatBlack.withOpacity(0.8),
            )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GPChat.getNTPWrappedWidget(Scaffold(
      appBar: AppBar(
          elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 30,
              color:
                  DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
            ),
          ),
          backgroundColor:
              DESIGN_TYPE == Themetype.whatsapp ? gpchatDeepGreen : gpchatWhite,
          title: Text(
            widget.name!,
            style: TextStyle(
              color:
                  DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
            ),
          )),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(gpchatBlue),
            ))
          : Stack(children: <Widget>[
              Container(
                  child: Center(
                child: !isUser!
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Text(
                                  widget.name! +
                                      ' ' +
                                      getTranslated(context, 'notexist') +
                                      "$Appname",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: gpchatBlack,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0)),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            myElevatedButton(
                              color: gpchatBlue,
                              child: Text(
                                getTranslated(context, 'invite') +
                                    ' ${widget.name}',
                                style: TextStyle(color: gpchatWhite),
                              ),
                              onPressed: () {
                                GPChat.invite(context);
                              },
                            )
                          ])
                    : Container(),
              )),
              // Loading
              buildLoading()
            ]),
      backgroundColor: gpchatWhite,
    ));
  }
}
