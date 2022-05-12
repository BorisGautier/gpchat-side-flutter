import 'dart:io';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:gpchat/Services/Providers/Observer.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Utils/open_settings.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SingleImagePicker extends StatefulWidget {
  SingleImagePicker(
      {Key? key,
      required this.title,
      required this.callback,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;

  @override
  _SingleImagePickerState createState() => new _SingleImagePickerState();
}

class _SingleImagePickerState extends State<SingleImagePicker> {
  File? _imageFile;
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  void captureImage(ImageSource captureMode) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
        setState(() {});
        if (_imageFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(_imageFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _imageFile = null;
          });
        } else {
          setState(() {
            _imageFile = File(_imageFile!.path);
          });
        }
      }
    } catch (e) {}
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return new Image.file(_imageFile!);
    } else {
      return new Text(getTranslated(context, 'takeimage'),
          style: new TextStyle(
            fontSize: 18.0,
            color:
                DESIGN_TYPE == Themetype.whatsapp ? gpchatWhite : gpchatBlack,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GPChat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor:
            DESIGN_TYPE == Themetype.whatsapp ? gpchatBlack : gpchatWhite,
        appBar: new AppBar(
            elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? gpchatWhite
                    : gpchatBlack,
              ),
            ),
            title: new Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? gpchatWhite
                    : gpchatBlack,
              ),
            ),
            backgroundColor:
                DESIGN_TYPE == Themetype.whatsapp ? gpchatBlack : gpchatWhite,
            actions: _imageFile != null
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: DESIGN_TYPE == Themetype.whatsapp
                              ? gpchatWhite
                              : gpchatBlack,
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          widget.callback(_imageFile).then((imageUrl) {
                            Navigator.pop(context, imageUrl);
                          });
                        }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            new Expanded(
                child: new Center(
                    child: error != null
                        ? fileSizeErrorWidget(error!)
                        : _buildImage())),
            _buildButtons()
          ]),
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
                        : gpchatWhite.withOpacity(0.8),
                  )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons() {
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(new Key('retake'), Icons.photo_library, () {
                GPChat.checkAndRequestPermission(Permission.photos).then((res) {
                  if (res) {
                    captureImage(ImageSource.gallery);
                  } else {
                    GPChat.showRationale(getTranslated(context, 'pgi'));
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
              _buildActionButton(new Key('upload'), Icons.photo_camera, () {
                GPChat.checkAndRequestPermission(Permission.camera).then((res) {
                  if (res) {
                    captureImage(ImageSource.camera);
                  } else {
                    getTranslated(context, 'pci');
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      // ignore: deprecated_member_use
      child: new RaisedButton(
          key: key,
          child: Icon(icon, size: 30.0),
          shape: new RoundedRectangleBorder(),
          color:
              DESIGN_TYPE == Themetype.whatsapp ? gpchatDeepGreen : gpchatgreen,
          textColor: gpchatWhite,
          onPressed: onPressed as void Function()?),
    );
  }
}
