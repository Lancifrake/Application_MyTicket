import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');  // Supprime le token

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),  // Redirige vers la page de connexion
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false); // 🔙 Retourne à la Home si aucun historique
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Ajouter une action pour les notifications
            },
          )
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 120,
                color: Colors.blueGrey,
              ),
              Positioned(
                top: 40,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/images/profile.png"), // Image de profil
                ),
              ),
            ],
          ),

          SizedBox(height: 70),

          // Bouton Edit Profile
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/edit_profile'); // Redirection vers la page d'édition du profil
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Sections du profil
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(context, "Today", Icons.calendar_today),
                Divider(),
                _buildProfileOption(context, "Panier", Icons.shopping_cart),
                _buildProfileOption(context, "Tes tickets", Icons.confirmation_number),
                _buildProfileOption(context, "Obtenir de l'aide", Icons.help_outline),
                _buildProfileOption(context, "À propos", Icons.info),
                Divider(),
                // Bouton Déconnexion
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Se déconnecter", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    logout(context);  // Appelle la fonction de déconnexion
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour chaque option du profil
  Widget _buildProfileOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Ajoute ici les redirections selon la page souhaitée
      },
    );
  }
}
