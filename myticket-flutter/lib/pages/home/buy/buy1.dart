import 'package:flutter/material.dart';
import 'package:projects/pages/home/buy/ticket_purchase.dart';
import 'package:projects/pages/home/buy/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/pages/home/buy/success_screen.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyTicket_1Page extends StatelessWidget {
  final int eventId;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String imageUrl;

  BuyTicket_1Page({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Logique pour partager l'événement
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du concert
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl, // Utilisation de l'URL de l'image de l'événement
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 15),

              // Titre du concert et date
              Text(
                eventName, // Utilisation du nom de l'événement
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 5),

              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(eventDate, style: TextStyle(color: Colors.grey)),
                  // Date dynamique
                ],
              ),

              SizedBox(height: 5),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(eventLocation, style: TextStyle(color: Colors.grey)),
                  // Lieu dynamique
                ],
              ),

              SizedBox(height: 15),

              // Section Description
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description :",
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "• Le numéro de siège sera attribué automatiquement.\n"
                          "• Il ne pourra pas être modifié après l'achat.\n"
                          "• Aucun échange ou remboursement possible.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/eminemm.jpg",
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 20),

              // Liste des tickets disponibles
              Text(
                "Type de ticket",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // On passe les détails de l'événement à chaque ticket
              _buildTicketOption(context, "STANDARD", "CFA 20.000"),
              _buildTicketOption(context, "VIP", "CFA 50.000"),
              _buildTicketOption(context, "VIP+", "CFA 100.000"),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour une option de ticket
  Widget _buildTicketOption(BuildContext context, String ticketType, String priceString) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticketType,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  priceString,
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Logique pour afficher les détails
            },
            child: Text("Détail", style: TextStyle(color: Colors.blue)),
          ),
          SizedBox(width: 5),
          ElevatedButton(
            onPressed: () async {
              int price = _extractPrice(priceString);
              await _buyTicket(context, eventId, ticketType, price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Acheter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  int _extractPrice(String priceString) {
    return int.parse(priceString.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  Future<String?> _fetchPhoneNumber(int userId) async {
    try {
      print("Récupération du numéro de téléphone pour l'utilisateur $userId...");
      final response = await http.get(Uri.parse('http://localhost:2000/api/users/$userId'));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (userData.containsKey('phoneNumber')) {
          return userData['phoneNumber'];
        }
      } else {
        print("Erreur lors de la récupération du numéro : ${response.body}");
      }
    } catch (error) {
      print("Erreur réseau lors de la récupération du numéro : $error");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchUserData(int userId) async {
    try {
      print("Récupération des informations utilisateur...");
      final response = await http.get(Uri.parse('http://localhost:2000/api/users/$userId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        print("🔍 Données utilisateur récupérées : $userData");
        return userData;
      } else {
        print("Erreur lors de la récupération de l'utilisateur : ${response.body}");
        return null;
      }
    } catch (error) {
      print("Erreur réseau : $error");
      return null;
    }
  }
  Future<String?> _fetchCandyMachineId(int eventId) async {
    try {
      print("Récupération du Candy Machine ID pour l'événement $eventId...");
      final response = await http.get(Uri.parse('http://localhost:2000/api/events/$eventId'));

      if (response.statusCode == 200) {
        final eventData = jsonDecode(response.body);
        return eventData['candyMachineId'];
      } else {
        print("Erreur lors de la récupération du Candy Machine ID : ${response.body}");
        return null;
      }
    } catch (error) {
      print("Erreur réseau : $error");
      return null;
    }
  }

  Future<void> _buyTicket(BuildContext context, int eventId, String ticketType, int price) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vous devez être connecté pour acheter un ticket.")),
        );
        return;
      }
      
      // Vérifiez d'abord si l'utilisateur a un wallet
      Map<String, dynamic>? userData = await _fetchUserData(userId);
      if (userData == null || userData["walletAddress"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vous devez avoir un wallet pour acheter un ticket."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      String walletAddress = userData["walletAddress"];
      
      // Maintenant qu'on sait que l'utilisateur a un wallet, on peut afficher l'écran de chargement
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen(message: "Achat du ticket en cours...")),
      );
      
      // Récupération du numéro de téléphone
      String? phoneNumber = prefs.getString('phoneNumber');
      if (phoneNumber == null) {
        phoneNumber = await _fetchPhoneNumber(userId);
        if (phoneNumber == null) {
          Navigator.pop(context); // Fermer l'écran de chargement
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Impossible de récupérer votre numéro de téléphone.")),
          );
          return;
        }
        prefs.setString('phoneNumber', phoneNumber);
      }

      String? candyMachineId = await _fetchCandyMachineId(eventId);
      if (candyMachineId == null) {
        Navigator.pop(context); // Fermer l'écran de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible de récupérer les informations de l'événement.")),
        );
        return;
      }

      print("Envoi des données d'achat:");
      print(" userId: $userId, amount: $price, phoneNumber: $phoneNumber, evenementId: $eventId, ticketType: $ticketType");

      final initResponse = await http.post(
        Uri.parse('http://localhost:2000/api/payments/init'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "amount": price,
          "phoneNumber": phoneNumber,
          "evenementId": eventId,
          "ticketType": ticketType
        }),
      );

      if (initResponse.statusCode != 200) {
        Navigator.pop(context); // Fermer l'écran de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'achat du ticket.")),
        );
        return;
      }

      final responseData = jsonDecode(initResponse.body);
      String transactionId = responseData['transactionId'];
      
      // Étape 2 : Mint du NFT directement après la transaction
      await _mintNFT(context, transactionId, userId, walletAddress, candyMachineId);
      
    } catch (error) {
      // Fermer l'écran de chargement en cas d'erreur
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Une erreur est survenue: $error")),
      );
    }
  }

// Correction : Passer `context` comme argument à `_mintNFT`
  Future<void> _mintNFT(BuildContext context, String transactionId, int userId, String walletAddress, String candyMachineId) async {
    try {
      print("Envoi du mint NFT...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen(message: "Achat du ticket en cours...")),
      );
      final mintResponse = await http.post(
        Uri.parse('http://172.18.129.5:3001/mint'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "walletAddress": walletAddress,
          "candyMachineId": candyMachineId,
          "transactionId": transactionId
        }),
      );
      if (mintResponse.statusCode != 200) {
        print("Erreur lors du mint : ${mintResponse.body}");
        return;
      }
      final mintData = jsonDecode(mintResponse.body);
      String mintId = mintData['mintId'];
      String nftImageUrl = mintData['nftImageUrl'];

      print("NFT minté : $mintId, Image : $nftImageUrl");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen(message: "Mise à jour de votre ticket...")),
      );
      await Future.delayed(Duration(seconds: 15));
    
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );

    } catch (error) {
      print("Erreur lors du minting : $error");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Une erreur est survenue lors de l'achat du ticket: $error")),
      );
    }
  }
  bool _isProcessingNFT = false;

}
