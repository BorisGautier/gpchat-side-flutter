import 'package:gpchat/Configs/Enum.dart';
import 'package:flutter/material.dart';

//*--App Colors : Replace with your own colours---
//-**********---------- WHATSAPP Color Theme: -------------------------
// final gpchatBlack = new Color(0xFF1E1E1E);
// final gpchatBlue = new Color(0xFF02ac88);
// final gpchatDeepGreen = new Color(0xFF01826b);
// final gpchatLightGreen = new Color(0xFF02ac88);
// final gpchatgreen = new Color(0xFF098b74);
// final gpchatteagreen = new Color(0xFFe9fedf);
// final gpchatWhite = Colors.white;
// final gpchatGrey = Color(0xff85959f);
// final gpchatChatbackground = new Color(0xffe8ded5);
// const DESIGN_TYPE = Themetype.whatsapp;
// const IsSplashOnlySolidColor = false;
// const SplashBackgroundSolidColor = Color(
//     0xFF086c5b); //applies this colors if "IsSplashOnlySolidColor" is set to true. Color Code: 0xFF005f56 for Whatsapp theme & 0xFFFFFFFF for messenger theme.

//-*********---------- MESSENGER Color Theme: ---------------// Remove below comments for Messenger theme //------------
final gpchatBlack = new Color(0xFF061D29);
final gpchatBlue = new Color(0xFF023f5f);
final gpchatDeepGreen = new Color(0xFF023f5f);
final gpchatLightGreen = new Color(0xFFFFC022);
final gpchatgreen = new Color(0xFF023f5f);
final gpchatteagreen = Color(0xFFeefcf8);
final gpchatWhite = Colors.white;
final gpchatGrey = Colors.grey;
final gpchatChatbackground = new Color(0xffdde6ea);
const DESIGN_TYPE = Themetype.messenger;
const IsSplashOnlySolidColor = false;
const SplashBackgroundSolidColor = Color(
    0xFFFFFFFF); //applies this colors if "IsSplashOnlySolidColor" is set to true. Color Code: 0xFF005f56 for Whatsapp theme & 0xFFFFFFFF for messenger theme.

//*--Admob Configurations- (By default Test Ad Units pasted)----------
const IsBannerAdShow =
    false; // Set this to 'true' if you want to show Banner ads throughout the app
const Admob_BannerAdUnitID_Android =
    'ca-app-pub-3940256099942544/6300978111'; // Test Id: 'ca-app-pub-3940256099942544/6300978111'
const Admob_BannerAdUnitID_Ios =
    'ca-app-pub-3940256099942544/2934735716'; // Test Id: 'ca-app-pub-3940256099942544/2934735716'
const IsInterstitialAdShow =
    false; // Set this to 'true' if you want to show Interstitial ads throughout the app
const Admob_InterstitialAdUnitID_Android =
    'ca-app-pub-3940256099942544/1033173712'; // Test Id:  'ca-app-pub-3940256099942544/1033173712'
const Admob_InterstitialAdUnitID_Ios =
    'ca-app-pub-3940256099942544/4411468910'; // Test Id: 'ca-app-pub-3940256099942544/4411468910'
const IsVideoAdShow =
    false; // Set this to 'true' if you want to show Video ads throughout the app
const Admob_RewardedAdUnitID_Android =
    'ca-app-pub-3940256099942544/5224354917'; // Test Id: 'ca-app-pub-3940256099942544/5224354917'
const Admob_RewardedAdUnitID_Ios =
    'ca-app-pub-3940256099942544/1712485313'; // Test Id: 'ca-app-pub-3940256099942544/1712485313'
//Also don't forget to Change the Admob App Id in "gpchat/android/app/src/main/AndroidManifest.xml" & "gpchat/ios/Runner/Info.plist"

//*--Agora Configurations---
const Agora_APP_IDD =
    'be6224b82dd248d8974977ea1906fcb9'; // Grab it from: https://www.agora.io/en/
const dynamic Agora_TOKEN =
    null; // not required until you have planned to setup high level of authentication of users in Agora.

//*--Giphy Configurations---
const GiphyAPIKey =
    'vCQZXx5ztwmxr3228sCAyGulxaB551Ov'; // Grab it from: https://developers.giphy.com/

//*--App Configurations---
const Appname = 'GPChat'; //app name shown evrywhere with the app where required
const DEFAULT_COUNTTRYCODE_ISO =
    'CM'; //default country ISO 2 letter for login screen
const DEFAULT_COUNTTRYCODE_NUMBER =
    '+237'; //default country code number for login screen
const FONTFAMILY_NAME =
    null; // make sure you have registered the font in pubspec.yaml

//--WARNING----- PLEASE DONT EDIT THE BELOW LINES UNLESS YOU ARE A DEVELOPER -------
const SplashPath = 'assets/images/splash.jpeg';
const AppLogoPath = 'assets/images/logo.png';
