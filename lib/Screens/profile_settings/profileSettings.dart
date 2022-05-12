import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Dbpaths.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Configs/optional_constants.dart';
import 'package:gpchat/Services/Admob/admob.dart';
import 'package:gpchat/Services/Providers/Observer.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Screens/calling_screen/pickup_layout.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:gpchat/widgets/ImagePicker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gpchat/Configs/Enum.dart';

class ProfileSetting extends StatefulWidget {
  final bool? biometricEnabled;
  final AuthenticationType? type;
  final SharedPreferences prefs;
  ProfileSetting({this.biometricEnabled, this.type, required this.prefs});
  @override
  State createState() => new ProfileSettingState();
}

class ProfileSettingState extends State<ProfileSetting> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;
  TextEditingController? controllerMobilenumber;

  String phone = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  File? avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();
  AuthenticationType? _type;
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  @override
  void initState() {
    super.initState();
    GPChat.internetLookUp();
    readLocal();
    _type = widget.type;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  void readLocal() async {
    phone = widget.prefs.getString(Dbkeys.phone) ?? '';
    nickname = widget.prefs.getString(Dbkeys.nickname) ?? '';
    aboutMe = widget.prefs.getString(Dbkeys.aboutMe) ?? '';
    photoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);
    controllerMobilenumber = new TextEditingController(text: phone);
    // Force refresh input
    setState(() {});
  }

  Future getImage(File image) async {
    setState(() {
      avatarImageFile = image;
    });

    return uploadFile();
  }

  Future uploadFile() async {
    String fileName = phone;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);

    File? compressedImage;

    final targetPath = avatarImageFile!.absolute.path
            .replaceAll(basename(avatarImageFile!.absolute.path), "") +
        "temp.jpg";

    compressedImage = await FlutterImageCompress.compressAndGetFile(
      avatarImageFile!.absolute.path,
      targetPath,
      quality: DpImageQualityCompress,
      rotate: 0,
    );

    TaskSnapshot uploading = await reference.putFile(compressedImage!);

    return uploading.ref.getDownloadURL();
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });
    nickname =
        controllerNickname!.text.isEmpty ? nickname : controllerNickname!.text;
    aboutMe =
        controllerAboutMe!.text.isEmpty ? aboutMe : controllerAboutMe!.text;
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(phone)
        .update({
      Dbkeys.nickname: nickname,
      Dbkeys.aboutMe: aboutMe,
      Dbkeys.authenticationType: _type!.index,
      Dbkeys.searchKey: nickname.trim().substring(0, 1).toUpperCase(),
    }).then((data) {
      widget.prefs.setString(Dbkeys.nickname, nickname);
      widget.prefs.setString(Dbkeys.aboutMe, aboutMe);
      setState(() {
        isLoading = false;
      });
      GPChat.toast(getTranslated(this.context, 'saved'));
      Navigator.of(this.context).pop();
      Navigator.of(this.context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      GPChat.toast(err.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);
    return PickupLayout(
        scaffold: GPChat.getNTPWrappedWidget(Scaffold(
            backgroundColor: gpchatWhite,
            appBar: new AppBar(
              elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
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
              titleSpacing: 0,
              backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                  ? gpchatDeepGreen
                  : gpchatWhite,
              title: new Text(
                getTranslated(this.context, 'editprofile'),
                style: TextStyle(
                  fontSize: 20.0,
                  color: DESIGN_TYPE == Themetype.whatsapp
                      ? gpchatWhite
                      : gpchatBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    getTranslated(this.context, 'save'),
                    style: TextStyle(
                      fontSize: 16,
                      color: DESIGN_TYPE == Themetype.whatsapp
                          ? gpchatWhite
                          : gpchatgreen,
                    ),
                  ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // Avatar
                      Container(
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != ''
                                      ? Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                                    child: Padding(
                                                        padding: EdgeInsets.all(
                                                            50.0),
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  gpchatLightGreen),
                                                        )),
                                                    width: 150.0,
                                                    height: 150.0),
                                            imageUrl: photoUrl,
                                            width: 150.0,
                                            height: 150.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(75.0)),
                                          clipBehavior: Clip.hardEdge,
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          size: 150.0,
                                          color: Colors.grey,
                                        ))
                                  : Material(
                                      child: Image.file(
                                        avatarImageFile!,
                                        width: 150.0,
                                        height: 150.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(75.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: FloatingActionButton(
                                      heroTag: "112233e8t4yt834",
                                      backgroundColor: gpchatLightGreen,
                                      child: Icon(Icons.camera_alt,
                                          color: gpchatWhite),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SingleImagePicker(
                                                        title: getTranslated(
                                                            this.context,
                                                            'pickimage'),
                                                        callback: getImage,
                                                        profile: true))).then(
                                            (url) {
                                          if (url != null) {
                                            photoUrl = url.toString();
                                            FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectionusers)
                                                .doc(phone)
                                                .update({
                                              Dbkeys.photoUrl: photoUrl
                                            }).then((data) async {
                                              await widget.prefs.setString(
                                                  Dbkeys.photoUrl, photoUrl);
                                              setState(() {
                                                isLoading = false;
                                              });
                                              // GPChat.toast(
                                              //     "Profile Picture Changed!");
                                            }).catchError((err) {
                                              setState(() {
                                                isLoading = false;
                                              });

                                              GPChat.toast(err.toString());
                                            });
                                          }
                                        });
                                      })),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                      ),
                      ListTile(
                          title: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.always,
                        controller: controllerNickname,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(25),
                        ],
                        validator: (v) {
                          return v!.isEmpty
                              ? getTranslated(this.context, 'validdetails')
                              : null;
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(6),
                            labelStyle: TextStyle(height: 0.8),
                            labelText:
                                getTranslated(this.context, 'enter_fullname')),
                      )),
                      SizedBox(
                        height: 15,
                      ),
                      ListTile(
                          title: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: controllerAboutMe,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(6),
                            labelStyle: TextStyle(height: 0.8),
                            labelText: getTranslated(this.context, 'status')),
                      )),
                      SizedBox(
                        height: 15,
                      ),
                      ListTile(
                          title: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        readOnly: true,
                        controller: controllerMobilenumber,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(6),
                            labelStyle: TextStyle(height: 0.8),
                            labelText: getTranslated(
                                this.context, 'enter_mobilenumber')),
                      )),
                      IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null
                          ? Container(
                              height: MediaQuery.of(context).size.width - 20,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(
                                bottom: 5.0,
                                top: 2,
                              ),
                              child: adWidget!)
                          : SizedBox(
                              height: 0,
                            ),
                    ],
                  ),
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                ),
                // Loading
                Positioned(
                  child: isLoading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(gpchatBlue)),
                          ),
                          color: DESIGN_TYPE == Themetype.whatsapp
                              ? gpchatBlack.withOpacity(0.8)
                              : gpchatWhite.withOpacity(0.8))
                      : Container(),
                ),
              ],
            ))));
  }
}
