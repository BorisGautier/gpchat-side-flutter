import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Dbpaths.dart';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Configs/optional_constants.dart';
import 'package:gpchat/Screens/Groups/GroupChatPage.dart';
import 'package:gpchat/Screens/call_history/callhistory.dart';
import 'package:gpchat/Screens/calling_screen/pickup_layout.dart';
import 'package:gpchat/Screens/chat_screen/chat.dart';
import 'package:gpchat/Screens/chat_screen/lazyLoadingChat.dart';
import 'package:gpchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:gpchat/Services/Providers/GroupChatProvider.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Models/DataModel.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectContactToShare extends StatefulWidget {
  const SelectContactToShare({
    required this.currentUserNo,
    required this.model,
    required this.prefs,
    required this.sharedFiles,
    this.sharedText,
  });
  final String? currentUserNo;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile> sharedFiles;
  final String? sharedText;

  @override
  _SelectContactToShareState createState() => new _SelectContactToShareState();
}

class _SelectContactToShareState extends State<SelectContactToShare>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  bool isGroupsloading = true;
  var joinedGroupsList = [];
  @override
  bool get wantKeepAlive => true;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedGroups();
  }

  fetchJoinedGroups() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: widget.currentUserNo)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .get()
        .then((groupsList) {
      if (groupsList.docs.length > 0) {
        groupsList.docs.forEach((group) {
          joinedGroupsList.add(group);
          if (groupsList.docs.last[Dbkeys.groupID] == group[Dbkeys.groupID]) {
            isGroupsloading = false;
          }
          setState(() {});
        });
      } else {
        isGroupsloading = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(gpchatBlue),
        )),
      )
    ]);
  }

  int currentUploadingIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        scaffold: GPChat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, contactsProvider, _child) => Consumer<
                          List<GroupModel>>(
                      builder: (context, groupList, _child) => Scaffold(
                          key: _scaffold,
                          backgroundColor: gpchatWhite,
                          appBar: AppBar(
                            elevation:
                                DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
                            titleSpacing: -5,
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? gpchatWhite
                                    : gpchatBlack,
                              ),
                            ),
                            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                                ? gpchatDeepGreen
                                : gpchatWhite,
                            centerTitle: false,
                            // leadingWidth: 40,
                            title: Text(
                              getTranslated(
                                  this.context, 'selectcontacttoshare'),
                              style: TextStyle(
                                fontSize: 18,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? gpchatWhite
                                    : gpchatBlack,
                              ),
                            ),
                          ),
                          body: RefreshIndicator(
                            onRefresh: () {
                              return contactsProvider.fetchContacts(context,
                                  model, widget.currentUserNo!, widget.prefs);
                            },
                            child: contactsProvider
                                            .searchingcontactsindatabase ==
                                        true ||
                                    isGroupsloading == true
                                ? loading()
                                : contactsProvider
                                            .joinedUserPhoneStringAsInServer
                                            .length ==
                                        0
                                    ? ListView(shrinkWrap: true, children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.5),
                                            child: Center(
                                              child: Text(
                                                  getTranslated(context,
                                                      'nosearchresult'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: gpchatGrey)),
                                            ))
                                      ])
                                    : ListView(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: joinedGroupsList.length,
                                            itemBuilder: (context, i) {
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    leading: customCircleAvatarGroup(
                                                        url: joinedGroupsList
                                                                .contains(Dbkeys
                                                                    .groupPHOTOURL)
                                                            ? joinedGroupsList[
                                                                    i][
                                                                Dbkeys
                                                                    .groupPHOTOURL]
                                                            : '',
                                                        radius: 22),
                                                    title: Text(
                                                      joinedGroupsList[i]
                                                          [Dbkeys.groupNAME],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: gpchatBlack,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      '${joinedGroupsList[i][Dbkeys.groupMEMBERSLIST].length} ${getTranslated(context, 'participants')}',
                                                      style: TextStyle(
                                                        color: gpchatGrey,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      // for group
                                                      Navigator.pushReplacement(
                                                          context,
                                                          new MaterialPageRoute(
                                                              builder: (context) => new GroupChatPage(
                                                                  sharedText: widget
                                                                      .sharedText,
                                                                  sharedFiles:
                                                                      widget
                                                                          .sharedFiles,
                                                                  isSharingIntentForwarded:
                                                                      true,
                                                                  model: widget
                                                                      .model,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  joinedTime:
                                                                      joinedGroupsList[
                                                                              i]
                                                                          [
                                                                          '${widget.currentUserNo}-joinedOn'],
                                                                  currentUserno:
                                                                      widget
                                                                          .currentUserNo!,
                                                                  groupID:
                                                                      joinedGroupsList[
                                                                              i]
                                                                          [
                                                                          Dbkeys
                                                                              .groupID])));
                                                    },
                                                  ),
                                                  Divider(
                                                    height: 2,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: contactsProvider
                                                .joinedUserPhoneStringAsInServer
                                                .length,
                                            itemBuilder: (context, idx) {
                                              String phone = contactsProvider
                                                  .joinedUserPhoneStringAsInServer[
                                                      idx]
                                                  .phone;
                                              Widget? alreadyAddedUser;

                                              return alreadyAddedUser ??
                                                  FutureBuilder(
                                                      future: contactsProvider
                                                          .getUserDoc(phone),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  DocumentSnapshot>
                                                              snapshot) {
                                                        if (snapshot.hasData &&
                                                            snapshot
                                                                .data!.exists) {
                                                          DocumentSnapshot
                                                              user =
                                                              snapshot.data!;
                                                          return Column(
                                                            children: [
                                                              ListTile(
                                                                leading:
                                                                    customCircleAvatar(
                                                                  url: user[Dbkeys
                                                                      .photoUrl],
                                                                  radius: 22.5,
                                                                ),
                                                                title: Text(
                                                                    user[Dbkeys
                                                                            .nickname] ??
                                                                        '',
                                                                    style: TextStyle(
                                                                        color:
                                                                            gpchatBlack)),
                                                                subtitle: Text(
                                                                    phone,
                                                                    style: TextStyle(
                                                                        color:
                                                                            gpchatGrey)),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            0.0),
                                                                onTap: () {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => IsLazyLoadingChat == false
                                                                              ? ChatScreen(sharedText: widget.sharedText, sharedFiles: widget.sharedFiles, isSharingIntentForwarded: true, prefs: widget.prefs, unread: 0, model: widget.model, currentUserNo: widget.currentUserNo, peerNo: user[Dbkeys.phone] as String?)
                                                                              : LazyLoadingChat(sharedText: widget.sharedText, sharedFiles: widget.sharedFiles, isSharingIntentForwarded: true, prefs: widget.prefs, unread: 0, model: widget.model, currentUserNo: widget.currentUserNo, peerNo: user[Dbkeys.phone] as String?)));
                                                                },
                                                              ),
                                                              Divider(
                                                                height: 2,
                                                              )
                                                            ],
                                                          );
                                                        }
                                                        return SizedBox();
                                                      });
                                            },
                                          ),
                                        ],
                                      ),
                          ))));
            }))));
  }
}
