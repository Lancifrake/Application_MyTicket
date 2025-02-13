import 'package:flutter/material.dart';

class EditProfileAPage extends StatefulWidget {
  @override
  _EditProfileAPageState createState() => _EditProfileAPageState();
}

class _EditProfileAPageState extends State<EditProfileAPage> {
  TextEditingController _usernameController = TextEditingController(text: "organisateur");
  TextEditingController _emailController = TextEditingController(text: "organisateur@gmail.com");
  TextEditingController _phoneController = TextEditingController(text: "+237694541010");
  TextEditingController _passwordController = TextEditingController(text: "7A3E9F2DDB%");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Retour arrière
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Logique pour partager le profil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Conteneur supérieur bleu
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 140,
                  color: Colors.blueGrey,
                ),
                Positioned(
                  bottom: -45, // Permet de centrer l'image sur les deux sections
                  child: CircleAvatar(
                    radius: 62,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 60, // Taille de l'image agrandie
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 75), // Ajout d'espace pour éviter que le formulaire remonte trop

            // Bouton "Change Picture"
            TextButton(
              onPressed: () {
                // Logique pour changer la photo
              },
              child: Text("Change Picture", style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),

            SizedBox(height: 20),

            // Formulaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField("Username", _usernameController),
                  SizedBox(height: 20),
                  _buildTextField("Email", _emailController),
                  SizedBox(height: 20),
                  _buildTextField("Phone Number", _phoneController),
                  SizedBox(height: 20),
                  _buildTextField("Password", _passwordController, isPassword: true),
                  SizedBox(height: 35),

                  // Bouton Update
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logique pour sauvegarder
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Update", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour générer un champ de texte
  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }
}
