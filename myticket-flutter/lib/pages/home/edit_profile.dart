import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Charge les données au démarrage de la page
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse('http://localhost:2000/api/users/profile');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _usernameController.text = data['username'];
        _emailController.text = data['email'];
        _phoneController.text = data['numDeTelephone'];
      });
    } else {
      print("Erreur lors de la récupération du profil : ${response.body}");
    }
  }

  Future<void> updateUserProfile() async {
    final url = Uri.parse('http://localhost:2000/api/users/update');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "username": _usernameController.text,
        "email": _emailController.text,
        "numDeTelephone": _phoneController.text,
        "motDePasse": _passwordController.text.isNotEmpty ? _passwordController.text : null,
      }),
    );

    if (response.statusCode == 200) {
      print("Profil mis à jour avec succès !");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil mis à jour !')));
      Navigator.pop(context);  // Retourne à la page précédente
    } else {
      print("Erreur lors de la mise à jour du profil : ${response.body}");
    }
  }

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
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 140,
                  color: Colors.blueGrey,
                ),
                Positioned(
                  bottom: -45,
                  child: CircleAvatar(
                    radius: 62,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 75),
            TextButton(
              onPressed: () {},
              child: Text("Change Picture", style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
            SizedBox(height: 20),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        updateUserProfile();
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
