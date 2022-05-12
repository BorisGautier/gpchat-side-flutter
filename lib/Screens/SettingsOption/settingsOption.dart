import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Dbpaths.dart';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Configs/optional_constants.dart';
import 'package:gpchat/Screens/call_history/callhistory.dart';
import 'package:gpchat/Screens/calling_screen/pickup_layout.dart';
import 'package:gpchat/Screens/notifications/AllNotifications.dart';
import 'package:gpchat/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:gpchat/Services/Providers/Observer.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:gpchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsOption extends StatefulWidget {
  final bool biometricEnabled;
  final AuthenticationType type;
  final String currentUserNo;
  final Function onTapEditProfile;
  final Function onTapLogout;
  const SettingsOption(
      {Key? key,
      required this.biometricEnabled,
      required this.currentUserNo,
      required this.onTapEditProfile,
      required this.onTapLogout,
      required this.type})
      : super(key: key);

  @override
  _SettingsOptionState createState() => _SettingsOptionState();
}

class _SettingsOptionState extends State<SettingsOption> {
  late Stream myDocStream;
  @override
  void initState() {
    super.initState();
    myDocStream = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserNo)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(context, listen: false);
    return PickupLayout(
        scaffold: GPChat.getNTPWrappedWidget(Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 24,
            color:
                DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor:
            DESIGN_TYPE == Themetype.whatsapp ? gpchatDeepGreen : gpchatWhite,
        title: Text(
          getTranslated(context, 'settingsoption'),
          style: TextStyle(
              color:
                  DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
              fontSize: 18.5),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 19, 0, 10),
            height: 100,
            width: w,
            child: StreamBuilder(
                stream: myDocStream,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.exists) {
                    var myDoc = snapshot.data;
                    return ListTile(
                        leading: customCircleAvatar(
                            radius: 40, url: myDoc[Dbkeys.photoUrl]),
                        title: Text(
                          myDoc[Dbkeys.nickname] ?? widget.currentUserNo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: gpchatBlack),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            myDoc[Dbkeys.aboutMe] == null ||
                                    myDoc[Dbkeys.aboutMe] == ''
                                ? myDoc[Dbkeys.phone]
                                : myDoc[Dbkeys.aboutMe],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                color: gpchatBlack.withOpacity(0.56)),
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              widget.onTapEditProfile();
                            },
                            icon: Icon(
                              Icons.edit,
                              color: gpchatgreen,
                            )));
                  }
                  return ListTile(
                      leading: customCircleAvatar(radius: 40),
                      title: Text(
                        widget.currentUserNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: gpchatBlack),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          getTranslated(context, 'myprofile'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              color: gpchatBlack.withOpacity(0.56)),
                        ),
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            widget.onTapEditProfile();
                          },
                          icon: Icon(
                            Icons.edit,
                            color: gpchatgreen,
                          )));
                }),
          ),
          Divider(),
          ListTile(
            onTap: () {
              widget.onTapEditProfile();
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Icon(
                Icons.account_circle_rounded,
                color: gpchatgreen.withOpacity(0.75),
                size: 26,
              ),
            ),
            title: Text(
              getTranslated(context, 'editprofile'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'changednp'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              launch('mailto:${observer.feedbackEmail}');
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Icon(
                Icons.rate_review_outlined,
                color: gpchatgreen.withOpacity(0.75),
                size: 26,
              ),
            ),
            title: Text(
              getTranslated(context, 'feedback'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'givesuggestions'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              onTapRateApp();
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                Icons.star_outline_rounded,
                color: gpchatgreen.withOpacity(0.75),
                size: 29,
              ),
            ),
            title: Text(
              getTranslated(context, 'rate'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'leavereview'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      height: 220,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: Colors.green[400], size: 45),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              getTranslated(context, 'backupdesc'),
                              textAlign: TextAlign.center,
                              style: TextStyle(height: 1.3, color: gpchatGrey),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: gpchatgreen.withOpacity(0.75),
                size: 25,
              ),
            ),
            title: Text(
              getTranslated(context, 'backup'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'backupshort'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => AllNotifications()));
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                Icons.notifications_none,
                color: gpchatgreen.withOpacity(0.75),
                size: 29,
              ),
            ),
            title: Text(
              getTranslated(context, 'allnotifications'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'pmtevents'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              if (ConnectWithAdminApp == false) {
                launch(TERMS_CONDITION_URL);
              } else {
                final observer = Provider.of<Observer>(context, listen: false);
                if (observer.tncType == 'url') {
                  if (observer.tnc == null) {
                    launch(TERMS_CONDITION_URL);
                  } else {
                    launch(observer.tnc!);
                  }
                } else if (observer.tncType == 'file') {
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => PDFViewerCachedFromUrl(
                        title: getTranslated(context, 'tnc'),
                        url: observer.tnc,
                        isregistered: true,
                      ),
                    ),
                  );
                }
              }
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Icon(
                Icons.help_outline,
                color: gpchatgreen.withOpacity(0.75),
                size: 26,
              ),
            ),
            title: Text(
              getTranslated(context, 'tnc'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'abiderules'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              final observer = Provider.of<Observer>(context, listen: false);
              if (ConnectWithAdminApp == false) {
                launch(PRIVACY_POLICY_URL);
              } else {
                if (observer.privacypolicyType == 'url') {
                  if (observer.privacypolicy == null) {
                    launch(PRIVACY_POLICY_URL);
                  } else {
                    launch(observer.privacypolicy!);
                  }
                } else if (observer.privacypolicyType == 'file') {
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => PDFViewerCachedFromUrl(
                        title: getTranslated(context, 'pp'),
                        url: observer.privacypolicy,
                        isregistered: true,
                      ),
                    ),
                  );
                }
              }
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Icon(
                Icons.lock_outline_rounded,
                color: gpchatgreen.withOpacity(0.75),
                size: 26,
              ),
            ),
            title: Text(
              getTranslated(context, 'pp'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                getTranslated(context, 'processdata'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: gpchatBlack.withOpacity(0.56)),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              GPChat.invite(context);
            },
            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
            leading: Icon(
              Icons.people_rounded,
              color: gpchatgreen.withOpacity(0.75),
              size: 26,
            ),
            title: Text(
              getTranslated(context, 'share'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: gpchatBlack),
            ),
          ),
          observer.isLogoutButtonShowInSettingsPage == true
              ? Divider()
              : SizedBox(),
          observer.isLogoutButtonShowInSettingsPage == true
              ? ListTile(
                  onTap: () async {
                    widget.onTapLogout();
                  },
                  contentPadding: EdgeInsets.fromLTRB(30, 0, 10, 6),
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 26,
                  ),
                  title: Text(
                    getTranslated(context, 'logout'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        color: gpchatBlack,
                        fontWeight: FontWeight.w600),
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    )));
  }

  onTapRateApp() {
    final observer = Provider.of<Observer>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              ListTile(
                  contentPadding: EdgeInsets.only(top: 20),
                  subtitle: Padding(padding: EdgeInsets.only(top: 10.0)),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 40,
                          color: gpchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: gpchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: gpchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: gpchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: gpchatBlack.withOpacity(0.56),
                        ),
                      ]),
                  onTap: () {
                    Navigator.of(context).pop();
                    Platform.isAndroid
                        ? launch(ConnectWithAdminApp == true
                            ? observer
                                .userAppSettingsDoc[Dbkeys.newapplinkandroid]
                            : RateAppUrlAndroid)
                        : launch(ConnectWithAdminApp == true
                            ? observer.userAppSettingsDoc[Dbkeys.newapplinkios]
                            : RateAppUrlIOS);
                  }),
              Divider(),
              Padding(
                  child: Text(
                    getTranslated(context, 'loved'),
                    style: TextStyle(fontSize: 14, color: gpchatBlack),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              Center(
                  child: myElevatedButton(
                      color: gpchatgreen,
                      child: Text(
                        getTranslated(context, 'rate'),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Platform.isAndroid
                            ? launch(ConnectWithAdminApp == true
                                ? observer.userAppSettingsDoc[
                                    Dbkeys.newapplinkandroid]
                                : RateAppUrlAndroid)
                            : launch(ConnectWithAdminApp == true
                                ? observer
                                    .userAppSettingsDoc[Dbkeys.newapplinkios]
                                : RateAppUrlIOS);
                      }))
            ],
          );
        });
  }
}
