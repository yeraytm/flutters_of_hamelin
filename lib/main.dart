import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutters_of_hamelin/screens/screens.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Euterpe());
}

class Euterpe extends StatelessWidget {
  const Euterpe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: GoogleFonts.notoSans().fontFamily),
      home: LoginScreen(),
    );
  }
}
