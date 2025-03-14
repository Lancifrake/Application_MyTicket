import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home.dart';
import 'package:projects/pages/scanner/home_s.dart';
import 'package:projects/pages/admin/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signin(BuildContext context) async {
    // Afficher indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    
    try {
      final url = Uri.parse('http://localhost:2000/api/auth/login');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "motDePasse": passwordController.text,
        }),
      );
  
      // Fermer le dialogue de chargement
      Navigator.pop(context);
  
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'];
        final userId = data['id'];
  
        // Stockage du token dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('userId', userId);
  
        // Redirige selon le rôle
        if (role == 'scanner') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home_sScreen()));
        } else if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrganizerDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${jsonDecode(response.body)['message']}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion. Vérifiez votre connexion internet.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image d'arrière-plan
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/crows.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                // Texte de bienvenue amélioré
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Achetez, vendez\net offrez vos\ntickets en toute\nsécurité.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      shadows: [
                        Shadow(blurRadius: 8.0, color: Colors.black.withOpacity(0.6), offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 100),
                // Container blanc avec ombre
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(Icons.email, "Email", emailController),
                      SizedBox(height: 20),
                      _buildInputField(Icons.lock, "Mot de passe", passwordController, isPassword: true),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Action pour mot de passe oublié
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF0172B2),
                          ),
                          child: Text(
                            "Mot de passe oublié ?", 
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Bouton de connexion amélioré
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            signin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0172B2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            "Se Connecter", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Lien d'inscription amélioré
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => SignUpScreen())
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "ou ",
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                              children: [
                                TextSpan(
                                  text: "S'inscrire ici",
                                  style: TextStyle(
                                    color: Color(0xFF0172B2), 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildInputField(IconData icon, String hintText, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF0172B2)),
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF0172B2), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(vertical: 15),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        if (hintText == "Email" && !value.contains('@')) {
          return 'Email invalide';
        }
        if (hintText == "Mot de passe" && value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
    );
  }
}