import 'package:flutter/material.dart';

class BuyTicket_1Page extends StatelessWidget {
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
                child: Image.asset(
                  "assets/images/eminem.jpg", // Image statique temporaire
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 15),

              // Titre du concert et date (Valeurs temporaires)
              Text(
                "Concert Summer 2025",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 5),

              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text("23 Août 2024", style: TextStyle(color: Colors.grey)),
                ],
              ),

              SizedBox(height: 5),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text("Palais des Congrès", style: TextStyle(color: Colors.grey)),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
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
                  "assets/images/eminemm.jpg", // Image insérée avant "Type de ticket"
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

              _buildTicketOption("VIP", "CFA 50.000"),
              _buildTicketOption("STANDARD", "CFA 20.000"),
              _buildTicketOption("VIP+", "CFA 100.000"),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour une option de ticket
  Widget _buildTicketOption(String type, String price) {
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
                  type,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  price,
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
            onPressed: () {
              // Logique pour acheter le ticket
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
}
