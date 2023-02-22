import 'package:flutter/material.dart';

class WaitingData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        child: Column(
          children: [
            const Text(
              "Searching for bathrooms near you...",
              style: TextStyle(
                  color: Color.fromRGBO(43, 52, 103, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color.fromRGBO(186, 215, 233, 1),
            )
          ],
        ),
      ),
    );
  }
}
