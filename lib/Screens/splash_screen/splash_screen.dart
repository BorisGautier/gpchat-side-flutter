import 'package:gpchat/Configs/app_constants.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IsSplashOnlySolidColor == true
        ? Scaffold(
            backgroundColor: SplashBackgroundSolidColor,
            body: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(gpchatLightGreen)),
            ))
        : Scaffold(
            backgroundColor: SplashBackgroundSolidColor,
            body: Center(
                child: Image.asset(
              '$AppLogoPath',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            )),
          );
  }
}
