import 'package:flutter/material.dart';

Widget myElevatedButton({Color? color, Widget? child, Function? onPressed}) {
  return ElevatedButton(
    child: child,
    onPressed: () {
      onPressed!();
    },
    style: ButtonStyle(
      elevation: MaterialStateProperty.all(0.5),
      backgroundColor: MaterialStateProperty.all(color),
      padding: MaterialStateProperty.all(EdgeInsets.all(2)),
      // textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black))
    ),
  );
}
