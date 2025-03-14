import 'package:flutter/material.dart';
import 'package:projects/pages/home/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile_sPage extends StatelessWidget {
  // Définition des couleurs thématiques (tons de bleu)
  final Color primaryColor = Color(0xFF0172B2);    // Bleu primaire
  final Color accentColor = Color(0xFF001645);     // Bleu clair accent
  final Color backgroundColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pushNamed(context, '/scan');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications en cours de développement')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // En-tête avec dégradé de bleus
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, accentColor],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                      onBackgroundImageError: (e, s) {
                        print('Erreur de chargement image: $e');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Bouton Modifier le profil
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text(
                    "Modifier le profil",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Titre de section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Options du profil",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Sections du profil avec animations
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildProfileOption(context, "Aujourd'hui", Icons.calendar_today, () {
                  Navigator.pushNamed(context, '/today');
                }),
                _buildProfileOption(context, "Obtenir de l'aide", Icons.help_outline, () {
                  Navigator.pushNamed(context, '/help');
                }),
                _buildProfileOption(context, "À propos", Icons.info, () {
                  Navigator.pushNamed(context, '/about');
                }),
                Divider(height: 1),
                // Bouton Déconnexion
                _buildProfileOption(
                  context, 
                  "Se déconnecter", 
                  Icons.logout, 
                  () => logout(context),
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget amélioré pour chaque option du profil
  Widget _buildProfileOption(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLogout ? Colors.red.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red : textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isLogout ? Colors.red.withOpacity(0.7) : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}