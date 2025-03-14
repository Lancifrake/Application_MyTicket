import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMarketplaceTickets();
  }

  Future<void> fetchMarketplaceTickets() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:2000/api/marketplace/tickets'));

    if (response.statusCode == 200) {
      final List<dynamic> decodedData = jsonDecode(response.body);
      setState(() {
        tickets = List<Map<String, dynamic>>.from(decodedData);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Erreur lors de la récupération des tickets en vente');
    }
  }

  Future<void> buyTicket(int ticketId, double price) async {
    final response = await http.post(
      Uri.parse('http://localhost/api/marketplace/buy'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ticketId": ticketId, "price": price}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ticket acheté avec succès ! 🎟️"),
        backgroundColor: Colors.green,
      ));
      fetchMarketplaceTickets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'achat du ticket"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketplace"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? Center(child: Text("Aucun ticket en vente actuellement."))
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            margin: EdgeInsets.all(12),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    ticket["imageURL"],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket["ticket_name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Événement : ${ticket["evenementNom"]}"),
                      Text("Lieu : ${ticket["lieu"]}"),
                      Text("Date : ${ticket["date"]}"),
                      SizedBox(height: 5),
                      Text("Prix : ${ticket["price"]} FCFA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => buyTicket(ticket["id"], ticket["price"]),
                        child: Text("Acheter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
