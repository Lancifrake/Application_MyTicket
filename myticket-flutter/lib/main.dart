import 'package:flutter/material.dart';
import 'package:projects/pages/home/buy/buy1.dart';
import 'package:projects/pages/home/buy/loading_screen.dart';
import 'package:projects/pages/home/splash_screen.dart';
import 'package:projects/pages/home/signup_screen.dart';
import 'package:projects/pages/home/signin_screen.dart';
import 'package:projects/pages/home/home.dart';
import 'package:projects/pages/home/ticket.dart';
import 'package:projects/pages/home/event.dart';
import 'package:projects/pages/home/about_us.dart';
import 'package:projects/pages/home/profile.dart';
import 'package:projects/pages/home/marketplace/marketplace.dart';
import 'package:projects/pages/home/edit_profile.dart';
import 'package:projects/pages/admin/edit_profile_a.dart';
import 'package:projects/pages/admin/dashboard.dart';
import 'package:projects/pages/admin/profile.dart';
import 'package:projects/pages/scanner/scan.dart';
import 'package:projects/pages/scanner/profile_s.dart';
import 'package:projects/pages/scanner/home_s.dart';
import 'package:projects/pages/scanner/edit_profile_s.dart';

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
        '/home_s': (context) => Home_sScreen(),
        '/event': (context) => EventPage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/edit_profile_a': (context) => EditProfileAPage(),
        '/edit_profile_s': (context) => EditProfile_sPage(),
        '/tickets': (context) => TicketsPage(),
        '/cart':(context) => MarketplacePage(),
        '/loading':(context) => LoadingScreen(),
        //'/ticket_d': (context) => TicketDetailPage(),
        '/buy1': (context) => BuyTicket_1Page(
          eventId: 0, // Valeur temporaire
          eventName: "Événement Test",
          eventDate: "2025-01-01",
          eventLocation: "Lieu Inconnu",
          imageUrl: "https://via.placeholder.com/200", // Image par défaut
        ),
        '/scan': (context) => ScanPage(),
        '/dashboard': (context) => OrganizerDashboard(),
        '/profile_a': (context) => OrganizerProfilePage(),
        '/profile_s': (context) => Profile_sPage(),
        '/profile': (context) => ProfilePage(),
        '/about': (context) => AboutUsPage(),
      },
    );
  }
}
