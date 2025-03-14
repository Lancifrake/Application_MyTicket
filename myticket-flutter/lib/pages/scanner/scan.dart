import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../scanner/home_s.dart';
import '../scanner/profile_s.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanning = false;
  Map<String, dynamic>? ticketDetails;
  int? scannerId;
  int _selectedIndex = 1;
  TextEditingController imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadScannerId(); // Récupérer l'ID du scanner au démarrage
  }

  Future<void> _loadScannerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      scannerId = prefs.getInt('userId'); //Stocké après connexion
    });

    print("Scanner ID récupéré : $scannerId");
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home_sScreen()));
        break;
      case 1:
      // Reste sur la page Scan
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Profile_sPage()));
        break;
    }
  }

  // Fonction pour scanner un ticket
  Future<void> _scanTicket() async {
    if (isScanning || scannerId == null || imageUrlController.text.isEmpty) {
      print("Scan bloqué : scannerId=$scannerId, imageURL=${imageUrlController.text}");
      return;
    }

    setState(() {
      isScanning = true;
      ticketDetails = null;
    });

    final url = Uri.parse("http://localhost:2000/api/tickets/scan");
    print("Envoi de la requête POST à $url avec scannerId=$scannerId et imageURL=${imageUrlController.text}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "imageURL": imageUrlController.text,
          "scannerId": scannerId,
        }),
      );

      print("Réponse HTTP reçue : ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("Réponse API Scan : $data");
        setState(() {
          ticketDetails = data;
          isScanning = false;
        });
        print("Ticket validé pour ${data['event']['eventName']}");
        _showDialog("Succès", "Ticket validé pour ${data['event']['eventName']}");
      } else {
        print("Erreur API : ${data['message']}");

        setState(() {
          ticketDetails = {
            "message": data['message'],
            "ticket": data.containsKey('ticket') ? data['ticket'] : null
          };
          isScanning = false;
        });

        print("Contenu de ticketDetails après erreur : $ticketDetails");
        _showDialog("Erreur", data['message']);
      }
    } catch (e) {
      print("Erreur de connexion : $e");
      setState(() {
        ticketDetails = {"message": "Erreur de connexion au serveur."};
        isScanning = false;
      });
      _showDialog("Erreur", "Échec du scan !");
    }
  }


  Future<void> _reportFraud() async {
    if (scannerId == null || ticketDetails == null) {
      print("Impossible de signaler une fraude : scannerId ou ticketDetails manquant !");
      return;
    }

    String? ticketId;
    if (ticketDetails!.containsKey('ticket') && ticketDetails!['ticket'] != null && ticketDetails!['ticket'].containsKey('id')) {
      ticketId = ticketDetails!['ticket']['id'].toString();
    }

    if (ticketId == null) {
      print("Ticket ID toujours introuvable !");
      return;
    }

    print("Signalement de fraude pour le ticket ID : $ticketId");

    String apiUrl = "http://localhost:2000/api/scanners/report-fraud";

    Map<String, dynamic> body = {
      "scannerId": scannerId,
      "ticketId": ticketId,
      "reason": "Ticket suspect (déjà utilisé ou invalide)"
    };

    print("Envoi de la requête de fraude : $body");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Réponse de l'API : ${response.statusCode}");
      print("Contenu : ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ticket signalé comme frauduleux !")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${jsonDecode(response.body)['message']}")),
        );
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de signaler la fraude.")),
      );
    }
  }


  // Fonction pour afficher les détails du ticket scanné
  Widget _buildTicketDetails() {
    if (ticketDetails == null) return SizedBox();

    // 🔎 Vérification si le ticket est invalide ou déjà scanné
    bool isFraudulent = (ticketDetails != null && ticketDetails!.containsKey('message')) ||
        (ticketDetails != null && ticketDetails?['ticket']?['scanned'] == true);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 350, // 🔹 Définition d’une largeur max
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (ticketDetails!.containsKey('message'))
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          ticketDetails!['message'],
                          style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],
                ),

              if (isFraudulent)
                ElevatedButton.icon(
                  icon: Icon(Icons.report, color: Colors.white),
                  label: Text("Signaler une fraude"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    if (ticketDetails?['ticket']?['id'] != null) {
                      String ticketId = ticketDetails!['ticket']['id'].toString();
                      print("Bouton 'Signaler une fraude' pressé pour le ticket ID : $ticketId");
                      _reportFraud();
                    } else {
                      print("Impossible de signaler la fraude, ticket ID introuvable !");
                    }
                  },

                ),

              SizedBox(height: 20),

              ElevatedButton.icon(
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text("Scanner un autre ticket"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  setState(() {
                    ticketDetails = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour afficher un message
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner un Ticket"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          if (scannerId == null)
            Padding(
              padding: EdgeInsets.all(20),
              child: Text("🔴 Erreur : Scanner ID non disponible ! Veuillez vous reconnecter."),
            ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: "Entrer l'URL du ticket"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _scanTicket,
                  child: Text("Vérifier Ticket"),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTicketDetails(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
