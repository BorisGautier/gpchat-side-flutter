import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Screens/calling_screen/pickup_layout.dart';
import 'package:gpchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl(
      {Key? key,
      required this.url,
      required this.title,
      required this.isregistered})
      : super(key: key);

  final String? url;
  final String title;
  final bool isregistered;

  @override
  Widget build(BuildContext context) {
    return isregistered == false
        ? Scaffold(
            appBar: AppBar(
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
              title: Text(
                title,
                style: TextStyle(
                    color: DESIGN_TYPE == Themetype.whatsapp
                        ? gpchatWhite
                        : gpchatBlack,
                    fontSize: 18),
              ),
              backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                  ? gpchatDeepGreen
                  : gpchatWhite,
            ),
            body: const PDF().cachedFromUrl(
              url!,
              placeholder: (double progress) =>
                  Center(child: Text('$progress %')),
              errorWidget: (dynamic error) =>
                  Center(child: Text(error.toString())),
            ),
          )
        : PickupLayout(
            scaffold: GPChat.getNTPWrappedWidget(Scaffold(
            appBar: AppBar(
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
              title: Text(
                title,
                style: TextStyle(
                    color: DESIGN_TYPE == Themetype.whatsapp
                        ? gpchatWhite
                        : gpchatBlack,
                    fontSize: 18),
              ),
              backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                  ? gpchatDeepGreen
                  : gpchatWhite,
            ),
            body: const PDF().cachedFromUrl(
              url!,
              placeholder: (double progress) =>
                  Center(child: Text('$progress %')),
              errorWidget: (dynamic error) =>
                  Center(child: Text(error.toString())),
            ),
          )));
  }
}
