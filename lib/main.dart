import 'dart:core';
import 'package:gpchat/Configs/Dbkeys.dart';
import 'package:gpchat/Configs/Enum.dart';
import 'package:gpchat/Configs/app_constants.dart';
import 'package:gpchat/Screens/splash_screen/splash_screen.dart';
import 'package:gpchat/Services/Providers/BroadcastProvider.dart';
import 'package:gpchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:gpchat/Services/Providers/GroupChatProvider.dart';
import 'package:gpchat/Services/Providers/LazyLoadingChatProvider.dart';
import 'package:gpchat/Services/Providers/Observer.dart';
import 'package:gpchat/Services/Providers/StatusProvider.dart';
import 'package:gpchat/Services/Providers/TimerProvider.dart';
import 'package:gpchat/Services/Providers/currentchat_peer.dart';
import 'package:gpchat/Services/Providers/seen_provider.dart';
import 'package:gpchat/Services/localization/demo_localization.dart';
import 'package:gpchat/Services/localization/language_constants.dart';
import 'package:gpchat/Screens/homepage/homepage.dart';
import 'package:gpchat/Services/Providers/DownloadInfoProvider.dart';
import 'package:gpchat/Services/Providers/call_history_provider.dart';
import 'package:gpchat/Services/Providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  if (DESIGN_TYPE == Themetype.messenger) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor:
            Color(0XFFFFFFFF), //or set color with: Color(0xFF0000FF)
        statusBarIconBrightness: Brightness.dark));
  }

  WidgetsFlutterBinding.ensureInitialized();
  if (IsBannerAdShow == true ||
      IsInterstitialAdShow == true ||
      IsVideoAdShow == true) {
    MobileAds.instance.initialize();
  }

  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();

  binding.renderView.automaticSystemUiAdjustment = false;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(OverlaySupport(child: GPChatWrapper()));
  });
}

class GPChatWrapper extends StatefulWidget {
  const GPChatWrapper({Key? key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _GPChatWrapperState state =
        context.findAncestorStateOfType<_GPChatWrapperState>()!;
    state.setLocale(newLocale);
  }

  @override
  _GPChatWrapperState createState() => _GPChatWrapperState();
}

class _GPChatWrapperState extends State<GPChatWrapper> {
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: gpchatBlack));
    final FirebaseGroupServices firebaseGroupServices = FirebaseGroupServices();
    final FirebaseBroadcastServices firebaseBroadcastServices =
        FirebaseBroadcastServices();
    if (this._locale == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splashscreen(),
      );
    } else {
      return FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Splashscreen(),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder:
                      (context, AsyncSnapshot<SharedPreferences> snapshot) {
                    if (snapshot.hasData) {
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE()),
                          //---
                          ChangeNotifierProvider(
                              create: (_) => StatusProvider()),
                          ChangeNotifierProvider(
                              create: (_) => TimerProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforGROUPCHAT()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforLAZYLOADINGCHAT()),

                          ChangeNotifierProvider(
                              create: (_) => AvailableContactsProvider()),
                          ChangeNotifierProvider(create: (_) => Observer()),
                          Provider(create: (_) => SeenProvider()),
                          ChangeNotifierProvider(
                              create: (_) => DownloadInfoprovider()),
                          ChangeNotifierProvider(create: (_) => UserProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderCALLHISTORY()),
                          ChangeNotifierProvider(
                              create: (_) => CurrentChatPeer()),
                        ],
                        child: StreamProvider<List<BroadcastModel>>(
                          initialData: [],
                          create: (BuildContext context) =>
                              firebaseBroadcastServices.getBroadcastsList(
                                  snapshot.data!.getString(Dbkeys.phone) ?? ''),
                          child: StreamProvider<List<GroupModel>>(
                            initialData: [],
                            create: (BuildContext context) =>
                                firebaseGroupServices.getGroupsList(
                                    snapshot.data!.getString(Dbkeys.phone) ??
                                        ''),
                            child: MaterialApp(
                              builder: (BuildContext? context, Widget? widget) {
                                ErrorWidget.builder =
                                    (FlutterErrorDetails errorDetails) {
                                  return CustomError(
                                      errorDetails: errorDetails);
                                };

                                return widget!;
                              },
                              theme: ThemeData(
                                  fontFamily: FONTFAMILY_NAME,
                                  primaryColor: gpchatgreen,
                                  primaryColorLight: gpchatgreen,
                                  indicatorColor: gpchatLightGreen),
                              title: Appname,
                              debugShowCheckedModeBanner: false,

                              home: Homepage(
                                prefs: snapshot.data!,
                                currentUserNo:
                                    snapshot.data!.getString(Dbkeys.phone),
                                isSecuritySetupDone: snapshot.data!.getString(
                                            Dbkeys.isSecuritySetupDone) ==
                                        null
                                    ? false
                                    : ((snapshot.data!
                                                .getString(Dbkeys.phone) ==
                                            null)
                                        ? false
                                        : (snapshot.data!.getString(Dbkeys
                                                    .isSecuritySetupDone) ==
                                                snapshot.data!
                                                    .getString(Dbkeys.phone))
                                            ? true
                                            : false),
                              ),

                              // ignore: todo
                              //TODO:---- All localizations settings----
                              locale: _locale,
                              supportedLocales: supportedlocale,
                              localizationsDelegates: [
                                DemoLocalization.delegate,
                                GlobalMaterialLocalizations.delegate,
                                GlobalWidgetsLocalizations.delegate,
                                GlobalCupertinoLocalizations.delegate,
                              ],
                              localeResolutionCallback:
                                  (locale, supportedLocales) {
                                for (var supportedLocale in supportedLocales) {
                                  if (supportedLocale.languageCode ==
                                          locale!.languageCode &&
                                      supportedLocale.countryCode ==
                                          locale.countryCode) {
                                    return supportedLocale;
                                  }
                                }
                                return supportedLocales.first;
                              },
                              //--- All localizations settings ended here----
                            ),
                          ),
                        ),
                      );
                    }
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => UserProvider()),
                      ],
                      child: MaterialApp(
                          theme: ThemeData(
                              fontFamily: FONTFAMILY_NAME,
                              primaryColor: gpchatgreen,
                              primaryColorLight: gpchatgreen,
                              indicatorColor: gpchatLightGreen),
                          debugShowCheckedModeBanner: false,
                          home: Splashscreen()),
                    );
                  });
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Splashscreen(),
            );
          });
    }
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0,
      width: 0,
    );
  }
}
