import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Couleurs thématiques (bleu)
  final Color primaryColor = Color(0xFF0172B2);
  final Color accentColor = Color(0xFF001645);
  final Color backgroundColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final url = Uri.parse('http://localhost:2000/api/users/profile');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Vous devez être connecté pour modifier votre profil';
        });
        return;
      }

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
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['numDeTelephone'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur lors de la récupération du profil : ${response.statusCode}';
        });
        print("Erreur lors de la récupération du profil : ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion: $e';
      });
      print("Exception: $e");
    }
  }

  Future<void> updateUserProfile() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le nom d\'utilisateur et l\'email sont obligatoires'))
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      // Note: URL changed from localhost to 10.0.2.2 for Android emulator
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

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          )
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la mise à jour : ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la mise à jour du profil'),
            backgroundColor: Colors.red,
          )
        );
        print("Erreur lors de la mise à jour du profil : ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Erreur de connexion: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion au serveur'),
          backgroundColor: Colors.red,
        )
      );
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Modifier le profil", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec dégradé et photo de profil
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor, accentColor],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      child: Container(
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
                          backgroundColor: Colors.grey[200],
                          backgroundImage: AssetImage("assets/images/profile.png"),
                          onBackgroundImageError: (e, s) {
                            print('Erreur de chargement image: $e');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 60),
                
                // Bouton de changement de photo
                TextButton.icon(
                  onPressed: () {
                    // Ajouter la fonctionnalité de changement d'image ici
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fonctionnalité en cours de développement'))
                    );
                  },
                  icon: Icon(Icons.camera_alt, color: primaryColor),
                  label: Text(
                    "Changer la photo",
                    style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w500)
                  ),
                ),
                
                // Message d'erreur
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ),
                
                SizedBox(height: 20),
                
                // Formulaire
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        "Nom d'utilisateur", 
                        _usernameController, 
                        Icons.person,
                        required: true
                      ),
                      SizedBox(height: 20),
                      _buildInputField(
                        "Email", 
                        _emailController, 
                        Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        required: true
                      ),
                      SizedBox(height: 20),
                      _buildInputField(
                        "Numéro de téléphone", 
                        _phoneController, 
                        Icons.phone,
                        keyboardType: TextInputType.phone
                      ),
                      SizedBox(height: 20),
                      _buildInputField(
                        "Mot de passe", 
                        _passwordController, 
                        Icons.lock,
                        isPassword: true,
                        hint: "Laissez vide pour ne pas changer"
                      ),
                      SizedBox(height: 35),
                      
                      // Bouton de mise à jour
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : updateUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isSubmitting
                            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            : Text(
                                "Mettre à jour",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    bool isPassword = false,
    bool required = false,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label${required ? ' *' : ''}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}