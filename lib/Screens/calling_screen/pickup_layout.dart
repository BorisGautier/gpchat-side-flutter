import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpchat/Screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gpchat/Models/call.dart';
import 'package:gpchat/Services/Providers/user_provider.dart';
import 'package:gpchat/Models/call_methods.dart';
import 'package:gpchat/Screens/calling_screen/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    // ignore: unnecessary_null_comparison
    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(phone: userProvider.getUser!.phone),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                Call call = Call.fromMap(
                    snapshot.data!.data() as Map<dynamic, dynamic>);

                if (!call.hasDialled!) {
                  return PickupScreen(
                    call: call,
                    currentuseruid: userProvider.getUser!.phone,
                  );
                }
              }
              return scaffold;
            },
          )
        : Splashscreen();
  }
}
