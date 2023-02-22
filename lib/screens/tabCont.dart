import 'package:bathroom_locator/models/location.dart';
import 'package:bathroom_locator/screens/discoverScreen.dart';
import 'package:bathroom_locator/screens/homeScreen.dart';
import 'package:bathroom_locator/screens/mapsScreen.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class TabCont extends StatelessWidget {
  const TabCont({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        bottomNavigationBar: ConvexAppBar(
          activeColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).primaryColor,
          items: [
            TabItem(
                icon: Image.asset('assets/icons8-bathroom-64.png',
                    fit: BoxFit.contain),
                title: 'Home'),
            TabItem(icon: Icons.map, title: 'Discovery'),
          ],
          onTap: (int i) => print('click index=$i'),
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          actions: [],
          title: Text(
            "Bathroom Locator",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        body: TabBarView(
            children: [HomeScreen(), MapsScreen(isSelecting: true)],
            physics: NeverScrollableScrollPhysics()),
      ),
    );
  }
}
