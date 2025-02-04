import 'package:flutter/material.dart';
import 'package:projects/pages/home/buy/buy1.dart';
import 'package:projects/pages/home/splash_screen.dart';
import 'package:projects/pages/home/signup_screen.dart';
import 'package:projects/pages/home/signin_screen.dart';
import 'package:projects/pages/home/home.dart';
import 'package:projects/pages/home/ticket.dart';
import 'package:projects/pages/home/event.dart';
import 'package:projects/pages/home/profile.dart';
import 'package:projects/pages/home/edit_profile.dart';
import 'package:projects/pages/scanner/scan.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TheTicket',
      initialRoute: '/',  // Écran de démarrage
      routes: {
        '/': (context) => SplashScreen(),
        '/signup_screen': (context) => SignUpScreen(),
        '/signin_screen': (context) => SignInScreen(),
        '/home': (context) => HomeScreen(),
        '/event': (context) => EventPage(),
        '/profile': (context) => ProfilePage(),
        //'/explore': (context) => ProfilePage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/tickets': (context) => TicketsPage(),
        '/buy1': (context) => BuyTicket_1Page(),
        '/scan': (context) => ScanPage(),

      },
    );
  }
}
