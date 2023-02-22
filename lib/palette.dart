//palette.dart
import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor kToDark = const MaterialColor(
    0xffeb455f, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xffD43E56), //10%
      100: const Color(0xffBC374C), //20%
      200: const Color(0xffA53043), //30%
      300: const Color(0xff8D2939), //40%
      400: const Color(0xff762330), //50%
      500: const Color(0xff5e1c26), //60%
      600: const Color(0xff46151c), //70%
      700: const Color(0xff2f0e13), //80%
      800: const Color(0xff170709), //90%
      900: const Color(0xff000000), //100%
    },
  );

  static Color DarkBlueColor = Color.fromRGBO(43, 52, 103, 1);
    static Color BlueTextColor = Color.fromRGBO(186, 215, 233, 1);

} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.
