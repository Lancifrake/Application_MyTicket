import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  bool isLoading = false;
  List<dynamic> ticketsEnVente = [];
  List<dynamic> userTickets = [];
  int? selectedTicketId;
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTicketsEnVente();
    print("Chargement des tickets en vente...");
    _fetchUserTickets();
  }

  Future<void> _fetchTicketsEnVente() async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Envoi de la requête pour récupérer les tickets en vente...");
      final response = await http.get(Uri.parse('http://localhost:2000/api/marketplace/tickets-en-vente'));

      print("Réponse brute de l'API : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Format JSON décodé : $data");

        setState(() {
          ticketsEnVente = data['tickets']; // Vérifie que 'tickets' est bien dans la réponse
          isLoading = false;
        });
      } else {
        print("Erreur API (${response.statusCode}): ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur dans Flutter : $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _fetchUserTickets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId == null) return;

    final response = await http.get(Uri.parse('http://localhost:2000/api/users/$userId/tickets'));
    if (response.statusCode == 200) {
      setState(() {
        userTickets = jsonDecode(response.body)['tickets'];
      });
    } else {
      print("Erreur lors de la récupération des tickets utilisateur");
    }
  }

  Future<void> _listTicketForSale() async {
    if (selectedTicketId == null || priceController.text.isEmpty) {
      print(" Erreur : ID du ticket ou prix manquant");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId == null) {
      print("Erreur : UserID introuvable");
      return;
    }

    print("Envoi de la requête pour mettre en vente le ticket...");
    print("Données envoyées : ticketId: $selectedTicketId, vendeurId: $userId, prix: ${priceController.text}");

    final response = await http.post(
      Uri.parse('http://localhost:2000/api/marketplace/list-ticket'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ticketId": selectedTicketId,
        "vendeurId": userId,
        "prix": int.parse(priceController.text),
      }),
    );
    print("Réponse de l'API : ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      print("Ticket mis en vente avec succès");
      _fetchTicketsEnVente();
      _fetchUserTickets();
      Navigator.pop(context);
    } else {
      print("Erreur lors de la mise en vente du ticket");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketplace"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 🔙 Icône de retour
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/event'); // 🔥 Redirige vers la page des événements
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ticketsEnVente.isEmpty
          ? Center(child: Text("Aucun ticket en vente actuellement."))
          : ListView.builder(
              itemCount: ticketsEnVente.length,
              itemBuilder: (context, index) {
                final ticket = ticketsEnVente[index];
                print("Affichage du ticket : $ticket");
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: ticket['imageURL'] != null && ticket['imageURL'].isNotEmpty
                        ? Image.network(ticket['imageURL'], width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.event),
                    title: Text(ticket['ticket_name'] ?? "Nom inconnu"),
                    subtitle: Text("Prix : ${ticket['prix']} XAF"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _acheterTicket(ticket['annonceId']);
                      },
                      child: Text("Acheter"),
                    ),
                  ),
                );
              },
          ),
    );
  }

  void _showSellDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Mettre un ticket en vente"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedTicketId,
                hint: Text("Sélectionner un ticket"),
                items: userTickets.map<DropdownMenuItem<int>>((ticket) {
                  return DropdownMenuItem<int>(
                    value: ticket['id'],
                    child: Text(ticket['ticket_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTicketId = value;
                  });
                },
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Prix"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: _listTicketForSale,
              child: Text("Mettre en vente"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _acheterTicket(int annonceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? phoneNumber = prefs.getString('phoneNumber');
    if (userId == null || phoneNumber == null) return;

    final response = await http.post(
      Uri.parse('http://localhost:2000/api/marketplace/acheter-revente'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "annonceId": annonceId,
        "acheteurId": userId,
        "phoneNumber": phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      print("Achat en attente de validation");
    } else {
      print("Erreur lors de l'achat");
    }
  }
}
