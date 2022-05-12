import 'dart:io';
import 'package:gpchat/Configs/app_constants.dart';

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return Admob_BannerAdUnitID_Ios;
  } else if (Platform.isAndroid) {
    return Admob_BannerAdUnitID_Android;
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return Admob_InterstitialAdUnitID_Ios;
  } else if (Platform.isAndroid) {
    return Admob_InterstitialAdUnitID_Android;
  }
  return null;
}

String? getRewardBasedVideoAdUnitId() {
  if (Platform.isIOS) {
    return Admob_RewardedAdUnitID_Ios;
  } else if (Platform.isAndroid) {
    return Admob_RewardedAdUnitID_Android;
  }
  return null;
}
