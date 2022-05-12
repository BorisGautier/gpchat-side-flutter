import 'package:contacts_service/contacts_service.dart';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Screens/calling_screen/pickup_layout.dart';
import 'package:gpchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Screens/chat_screen/chat.dart';
import 'package:gpchat/Screens/chat_screen/pre_chat.dart';
import 'package:gpchat/Screens/contact_screens/AddunsavedContact.dart';
import 'package:gpchat/Models/DataModel.dart';
import 'package:gpchat/Utils/chat_controller.dart';
import 'package:gpchat/Utils/open_settings.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contacts extends StatefulWidget {
  const Contacts({
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
  });
  final String? currentUserNo;
  final DataModel? model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  @override
  _ContactsState createState() => new _ContactsState();
}

class _ContactsState extends State<Contacts>
    with AutomaticKeepAliveClientMixin {
  Map<String?, String?>? contacts;
  Map<String?, String?>? _filtered = new Map<String, String>();

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();

  late String _query;

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  _ContactsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _query = "";
          this._filtered = this.contacts;
        });
      } else {
        setState(() {
          _query = _filter.text;
          this._filtered =
              Map.fromEntries(this.contacts!.entries.where((MapEntry contact) {
            return contact.value
                .toLowerCase()
                .trim()
                .contains(new RegExp(r'' + _query.toLowerCase().trim() + ''));
          }));
        });
      }
    });
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

  @override
  initState() {
    super.initState();
    getContacts();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _appBarTitle = new Text(
        getTranslated(context, 'searchcontact'),
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
        ),
      );
      _searchPressed();
    });
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo) {
    Map<String, dynamic> _currentUser = widget.model!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  Future<Map<String?, String?>> getContacts({bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        new Completer<Map<String?, String?>>();

    LocalStorage storage = LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key));
      if (mounted) {
        setState(() {
          this.contacts = this._filtered = c;
        });
      }
    });

    GPChat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(new RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              contacts.where((c) => c.phones!.isNotEmpty).forEach((Contact p) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  numbers.forEach((number) {
                    _cachedContacts[number] = p.displayName;
                    setState(() {});
                  });
                  setState(() {});
                }
              });

              // await storage.setItem(Dbkeys.cachedContacts, _cachedContacts);
              completer.complete(_cachedContacts);
            });
          }
          // }
        });
      } else {
        GPChat.showRationale(getTranslated(context, 'perm_contact'));
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      }
    }).catchError((onError) {
      GPChat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  Icon _searchIcon = new Icon(
    Icons.search,
    color: DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
  );
  Widget _appBarTitle = Text('');

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(
          Icons.close,
          color: DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
        );
        this._appBarTitle = new TextField(
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          style: TextStyle(
            color:
                DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
            fontSize: 18.5,
            fontWeight: FontWeight.w600,
          ),
          controller: _filter,
          decoration: new InputDecoration(
              labelStyle: TextStyle(
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? gpchatWhite
                    : gpchatBlack,
              ),
              hintText: getTranslated(context, 'search'),
              hintStyle: TextStyle(
                fontSize: 18.5,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? gpchatWhite.withOpacity(0.7)
                    : gpchatGrey,
              )),
        );
      } else {
        this._searchIcon = new Icon(
          Icons.search,
          color: DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
        );
        this._appBarTitle = new Text(
          getTranslated(context, 'searchcontact'),
          style: TextStyle(
            fontSize: 18.5,
            color:
                DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
          ),
        );

        _filter.clear();
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        scaffold: GPChat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, contactsProvider, _child) => Scaffold(
                      backgroundColor: gpchatWhite,
                      appBar: AppBar(
                        elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
                        titleSpacing: 5,
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
                        title: _appBarTitle,
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.add_call,
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? gpchatWhite
                                  : gpchatBlack,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  new MaterialPageRoute(builder: (context) {
                                return new AddunsavedNumber(
                                    prefs: widget.prefs,
                                    model: widget.model,
                                    currentUserNo: widget.currentUserNo);
                              }));
                            },
                          ),
                          IconButton(
                            icon: _searchIcon,
                            onPressed: _searchPressed,
                          )
                        ],
                      ),
                      body: contacts == null
                          ? loading()
                          : RefreshIndicator(
                              onRefresh: () {
                                return getContacts(refresh: true);
                              },
                              child: _filtered!.isEmpty
                                  ? ListView(children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.5),
                                          child: Center(
                                            child: Text(
                                                getTranslated(
                                                    context, 'nosearchresult'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: gpchatBlack,
                                                )),
                                          ))
                                    ])
                                  : Consumer<AvailableContactsProvider>(
                                      builder:
                                          (context, contactsProvider, _child) =>
                                              ListView.builder(
                                                padding: EdgeInsets.all(10),
                                                itemCount: _filtered!.length,
                                                itemBuilder: (context, idx) {
                                                  MapEntry user = _filtered!
                                                      .entries
                                                      .elementAt(idx);
                                                  String phone = user.key;
                                                  return FutureBuilder(
                                                      future: contactsProvider
                                                          .getUserDoc(phone),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                        if (snapshot.hasData) {
                                                          var userDoc = snapshot
                                                              .data!
                                                              .data();
                                                          return ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                                    backgroundColor:
                                                                        gpchatgreen,
                                                                    radius:
                                                                        22.5,
                                                                    child: Text(
                                                                      GPChat.getInitials(
                                                                          userDoc[
                                                                              Dbkeys.nickname]),
                                                                      style: TextStyle(
                                                                          color:
                                                                              gpchatWhite),
                                                                    )),
                                                            title: Text(
                                                                userDoc[Dbkeys
                                                                    .nickname],
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
                                                              hidekeyboard(
                                                                  context);
                                                              dynamic wUser =
                                                                  model.userData[
                                                                      phone];
                                                              if (wUser !=
                                                                      null &&
                                                                  wUser[Dbkeys
                                                                          .chatStatus] !=
                                                                      null) {
                                                                if (model.currentUser![Dbkeys
                                                                            .locked] !=
                                                                        null &&
                                                                    model
                                                                        .currentUser![Dbkeys
                                                                            .locked]
                                                                        .contains(
                                                                            phone)) {
                                                                  ChatController.authenticate(
                                                                      model,
                                                                      getTranslated(
                                                                          context,
                                                                          'auth_neededchat'),
                                                                      prefs: widget
                                                                          .prefs,
                                                                      shouldPop:
                                                                          false,
                                                                      state: Navigator.of(
                                                                          context),
                                                                      type: GPChat.getAuthenticationType(
                                                                          widget
                                                                              .biometricEnabled,
                                                                          model),
                                                                      onSuccess:
                                                                          () {
                                                                    Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        new MaterialPageRoute(
                                                                            builder: (context) => new ChatScreen(
                                                                                isSharingIntentForwarded: false,
                                                                                prefs: widget.prefs,
                                                                                model: model,
                                                                                currentUserNo: widget.currentUserNo,
                                                                                peerNo: phone,
                                                                                unread: 0)),
                                                                        (Route r) => r.isFirst);
                                                                  });
                                                                } else {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)));
                                                                }
                                                              } else {
                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return PreChat(
                                                                      prefs: widget
                                                                          .prefs,
                                                                      model: widget
                                                                          .model,
                                                                      name: user
                                                                          .value,
                                                                      phone:
                                                                          phone,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo);
                                                                }));
                                                              }
                                                            },
                                                          );
                                                        }
                                                        return ListTile(
                                                          leading: CircleAvatar(
                                                              backgroundColor:
                                                                  gpchatgreen,
                                                              radius: 22.5,
                                                              child: Text(
                                                                GPChat.getInitials(
                                                                    user.value),
                                                                style: TextStyle(
                                                                    color:
                                                                        gpchatWhite),
                                                              )),
                                                          title: Text(
                                                              user.value,
                                                              style: TextStyle(
                                                                  color:
                                                                      gpchatBlack)),
                                                          subtitle: Text(phone,
                                                              style: TextStyle(
                                                                  color:
                                                                      gpchatGrey)),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          0.0),
                                                          onTap: () {
                                                            hidekeyboard(
                                                                context);
                                                            dynamic wUser =
                                                                model.userData[
                                                                    phone];
                                                            if (wUser != null &&
                                                                wUser[Dbkeys
                                                                        .chatStatus] !=
                                                                    null) {
                                                              if (model.currentUser![
                                                                          Dbkeys
                                                                              .locked] !=
                                                                      null &&
                                                                  model
                                                                      .currentUser![
                                                                          Dbkeys
                                                                              .locked]
                                                                      .contains(
                                                                          phone)) {
                                                                ChatController.authenticate(
                                                                    model,
                                                                    getTranslated(
                                                                        context,
                                                                        'auth_neededchat'),
                                                                    prefs: widget
                                                                        .prefs,
                                                                    shouldPop:
                                                                        false,
                                                                    state: Navigator.of(
                                                                        context),
                                                                    type: GPChat.getAuthenticationType(
                                                                        widget
                                                                            .biometricEnabled,
                                                                        model),
                                                                    onSuccess:
                                                                        () {
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)),
                                                                      (Route r) => r.isFirst);
                                                                });
                                                              } else {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder: (context) => new ChatScreen(
                                                                            isSharingIntentForwarded:
                                                                                false,
                                                                            prefs: widget
                                                                                .prefs,
                                                                            model:
                                                                                model,
                                                                            currentUserNo: widget
                                                                                .currentUserNo,
                                                                            peerNo:
                                                                                phone,
                                                                            unread:
                                                                                0)));
                                                              }
                                                            } else {
                                                              Navigator.push(
                                                                  context,
                                                                  new MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return new PreChat(
                                                                    prefs: widget
                                                                        .prefs,
                                                                    model: widget
                                                                        .model,
                                                                    name: user
                                                                        .value,
                                                                    phone:
                                                                        phone,
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo);
                                                              }));
                                                            }
                                                          },
                                                        );
                                                      });
                                                },
                                              )))));
            }))));
  }
}
