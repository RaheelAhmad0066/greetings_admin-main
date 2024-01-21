import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greetings_admin/home_screen.dart';
import 'package:greetings_admin/state/quoteState.dart';
import 'package:greetings_admin/state/religionstate.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReligionEventsProvider()),
        ChangeNotifierProvider(create: (context) => QuotesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
        buttonTheme: ButtonThemeData(buttonColor: Colors.blue),
        appBarTheme: AppBarTheme(color: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
