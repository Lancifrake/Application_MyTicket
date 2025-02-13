import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home.dart';  // Page principale pour les utilisateurs
import 'package:projects/pages/scanner/home_s.dart';  // Page spécifique pour les scanneurs
import 'package:projects/pages/admin/dashboard.dart';  // Page pour les administrateurs
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signin(BuildContext context) async {
    print("Email : ${emailController.text}");
    print("Mot de passe : ${passwordController.text}");
    final url = Uri.parse('http://localhost:2000/api/auth/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "motDePasse": passwordController.text,
      }),
    );

    print("Réponse reçue : ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final role = data['role'];  // Récupère le rôle depuis la réponse

      print("Connexion réussie, rôle : $role");

      // Stockage du token dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Redirige selon le rôle
      if (role == 'scanner') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home_sScreen()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrganizerDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } else {
      print("Erreur lors de la connexion : ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${jsonDecode(response.body)['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Achetez, vendez\net offrez vos\ntickets en toute\nsécurité.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 5.0, color: Colors.black.withOpacity(0.5), offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 100),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(Icons.email, "Email", emailController),
                      SizedBox(height: 15),
                      _buildInputField(Icons.lock, "Mot de passe", passwordController, isPassword: true),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text("Mot de passe oublié ?", style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            signin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text("Se Connecter", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "ou ",
                              style: TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: "S'inscrire ici",
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
