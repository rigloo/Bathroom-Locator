import 'package:bathroom_locator/providers/bathrooms.dart';
import 'package:bathroom_locator/screens/bathroomDetail.dart';
import 'package:bathroom_locator/screens/tabCont.dart';
import 'package:flutter/material.dart';
import 'palette.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

/*

Main file. All it does is define the routes and the homepage, which is the Tab Controller screen.

*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  runApp(MyApp());
}


//
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => (Bathrooms())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bathroom Locator',
        theme: ThemeData(
          primarySwatch: Palette.kToDark,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: Color.fromARGB(255, 252, 255, 231)),
        ),
        home: TabCont(),
        routes: {
          BathroomDetail.routeName: (context) => BathroomDetail(),
        },
      ),
    );
  }
}
