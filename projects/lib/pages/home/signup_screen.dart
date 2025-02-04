import 'package:flutter/material.dart';
import 'signin_screen.dart'; // Assurez-vous d'importer le bon fichier

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45, // Hauteur ajustée
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/crows.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Contenu principal
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                // Texte d'introduction repositionné
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Achetez, vendez et\noffrez vos tickets\nen toute sécurité.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 70),

                // Conteneur blanc pour le formulaire
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(Icons.person, "Nom"),
                      SizedBox(height: 15),
                      _buildInputField(Icons.email, "Email"),
                      SizedBox(height: 15),
                      _buildInputField(Icons.lock, "Mot de passe", isPassword: true),
                      SizedBox(height: 15),
                      _buildInputField(Icons.lock, "Confirmer le Mot de Passe", isPassword: true),

                      SizedBox(height: 40),

                      // Bouton S'inscrire
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Logique d'inscription ici
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            "S'inscrire",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Lien pour se connecter
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Redirige vers Sign In
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignInScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Déjà un compte ? ",
                              style: TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: "Se connecter",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),

                      // Connexion avec Google
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Se connecter avec",
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/icons/google.png",
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Google"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour un champ de texte réutilisable
  Widget _buildInputField(IconData icon, String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
