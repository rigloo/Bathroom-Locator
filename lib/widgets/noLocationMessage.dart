import 'package:flutter/material.dart';

import '../palette.dart';

class NoLocationMessage extends StatelessWidget {
  const NoLocationMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Text(
        "Sorry, could not get your location. Make sure to allow Location Services for this app and restart.",
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Palette.DarkBlueColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
