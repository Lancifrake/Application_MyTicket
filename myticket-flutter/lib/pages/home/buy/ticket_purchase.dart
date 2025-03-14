import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketPurchasePage extends StatefulWidget {
  final int eventId;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String imageUrl;

  TicketPurchasePage({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.imageUrl,
  });

  @override
  _TicketPurchasePageState createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  bool isLoading = false;
  String selectedTicketType = "STANDARD";
  double selectedPrice = 20000;

  Future<void> purchaseTicket() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://localhost:2000/api/payments/init'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": 13, // 🔹 Remplace par l'ID de l'utilisateur actuel
        "eventId": widget.eventId,
        "ticketType": selectedTicketType,
        "price": selectedPrice
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("✅ Paiement initialisé : ${responseData["message"]}");

      // Simuler le mint après paiement validé
      await Future.delayed(Duration(seconds: 3));
      mintNFTAfterPayment(responseData["walletAddress"]);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ticket acheté avec succès ! 🎟️"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'achat du ticket."),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> mintNFTAfterPayment(String walletAddress) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3001/mint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"walletAddress": walletAddress}),
      );

      if (response.statusCode == 200) {
        print("✅ NFT Minté avec succès !");
      } else {
        print("❌ Erreur lors du mint du NFT.");
      }
    } catch (e) {
      print("❌ Erreur de connexion au microservice de mint.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Achat de Ticket")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.imageUrl, height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(widget.eventName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("${widget.eventDate} • ${widget.eventLocation}", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Text("Sélectionnez votre type de ticket :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text("VIP (50.000 FCFA)"),
              leading: Radio(
                value: "VIP",
                groupValue: selectedTicketType,
                onChanged: (value) {
                  setState(() {
                    selectedTicketType = value!;
                    selectedPrice = 50000;
                  });
                },
              ),
            ),
            ListTile(
              title: Text("STANDARD (20.000 FCFA)"),
              leading: Radio(
                value: "STANDARD",
                groupValue: selectedTicketType,
                onChanged: (value) {
                  setState(() {
                    selectedTicketType = value!;
                    selectedPrice = 20000;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: purchaseTicket,
              child: Text("Acheter maintenant"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
