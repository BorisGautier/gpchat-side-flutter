import 'dart:io';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Screens/chat_screen/utils/downloadMedia.dart';
import 'package:gpchat/Utils/open_settings.dart';
import 'package:gpchat/Utils/save.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoViewWrapper extends StatelessWidget {
  PhotoViewWrapper(
      {this.imageProvider,
      this.message,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      required this.tag});

  final String tag;
  final String? message;

  final ImageProvider? imageProvider;
  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  final GlobalKey<ScaffoldState> _scaffoldd = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoaderr =
      new GlobalKey<State>(debugLabel: 'qqgfggqesqeqsseaadqeqe');
  @override
  Widget build(BuildContext context) {
    return GPChat.getNTPWrappedWidget(Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldd,
        appBar: AppBar(
          elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: gpchatWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "dfs32231t834",
          backgroundColor: gpchatLightGreen,
          onPressed: Platform.isIOS || Platform.isAndroid
              ? () {
                  launch(message!);
                }
              : () async {
                  GPChat.checkAndRequestPermission(Permission.storage)
                      .then((res) async {
                    if (res) {
                      Save.saveToDisk(imageProvider, tag);
                      await downloadFile(
                        context: _scaffoldd.currentContext!,
                        fileName:
                            '${DateTime.now().millisecondsSinceEpoch}.png',
                        isonlyview: false,
                        keyloader: _keyLoaderr,
                        uri: message,
                      );
                    } else {
                      GPChat.showRationale(getTranslated(context, 'pms'));
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => OpenSettings()));
                    }
                  });
                },
          child: Icon(
            Icons.file_download,
          ),
        ),
        body: Container(
            color: Colors.black,
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              loadingBuilder: (BuildContext context, var image) {
                return loadingChild ??
                    Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(gpchatBlue),
                        ),
                      ),
                    );
              },
              imageProvider: imageProvider,
              backgroundDecoration: backgroundDecoration as BoxDecoration?,
              minScale: minScale,
              maxScale: maxScale,
            ))));
  }
}
