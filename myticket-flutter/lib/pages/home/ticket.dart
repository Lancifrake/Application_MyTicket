import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'event.dart';
import 'profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketsPage extends StatefulWidget {
  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  late Future<List<Map<String, dynamic>>> ticketsFuture;
  int _selectedIndex = 2;
  int? userId;
  TextEditingController destinataireController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('userId');
    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
        ticketsFuture = fetchTickets();
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchTickets() async {
    final response = await http.get(
        Uri.parse('http://localhost:2000/api/tickets/user/$userId')
    );

    if (response.statusCode == 200) {
      final List<dynamic> decodedData = jsonDecode(response.body);

      return decodedData.map((ticket) => {
        "id": ticket["id"] ?? 0,
        "ticket_name": ticket["ticket_name"] ?? "Nom inconnu",
        "evenementNom": ticket["evenementNom"] ?? "Événement inconnu",
        "lieu": ticket["lieu"] ?? "Lieu non spécifié",
        "date": ticket["date"] ?? "Date non spécifiée",
        "type": ticket["type"] ?? "Type non défini",
        "stockageNFT": ticket["stockageNFT"] ?? "Aucune donnée",
        "imageURL": ticket["imageURL"] ?? "",
      }).toList();
    } else {
      throw Exception('Erreur lors de la récupération des tickets');
    }
  }

  // Gestion de la navigation entre les pages
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeScreen();
        break;
      case 1:
        nextPage = EventPage();
        break;
      case 2:
        nextPage = TicketsPage(); // Page actuelle
        break;
      case 3:
        nextPage = ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  void _showSaleDialog(Map<String, dynamic> ticket) {
    print("Bouton vente cliqué pour le ticket ID: ${ticket["id"]}");

    TextEditingController priceController = TextEditingController();
    bool isLoading = false; // Ajout d'un état de chargement

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Mettre en vente"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Entrez le prix du ticket en XAF :"),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Prix en XAF"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Annuler"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Vendre"),
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Veuillez entrer un prix")),
                      );
                      return;
                    }
                    setState(() => isLoading = true);
                    await _mettreEnVente(ticket, priceController.text, context);
                    setState(() => isLoading = false);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  //new
  void _showTransferDialog(Map<String, dynamic> ticket) {
    print("Bouton transfert cliqué pour le ticket ID: ${ticket["id"]}");

    destinataireController.text = '';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Transférer le ticket"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ticket: ${ticket['ticket_name'] ?? ticket['evenementNom']}", 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  TextField(
                    controller: destinataireController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "ID du destinataire",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Veuillez saisir l'ID du destinataire pour transférer ce ticket.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Annuler"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Transférer"),
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (destinataireController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Veuillez entrer l'ID du destinataire")),
                      );
                      return;
                    }
                    setState(() => isLoading = true);
                    await _transfererTicket(ticket, destinataireController.text, context);
                    setState(() => isLoading = false);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _transfererTicket(Map<String, dynamic> ticket, String destinataireId, BuildContext context) async {
    if (userId == null) {
      print("Erreur: userId est NULL");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilisateur non identifié")));
      return;
    }

    int? parsedDestinataire = int.tryParse(destinataireId);
    if (parsedDestinataire == null) {
      print("Erreur: ID destinataire invalide: $destinataireId");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Veuillez entrer un ID de destinataire valide")));
      return;
    }

    print("Envoi de la requête API pour transfert...");
    print("URL: http://localhost:2000/api/marketplace/transfer");
    print("Données envoyées: { ticketId: ${ticket["id"]}, vendeurId: $userId, acheteurId: $parsedDestinataire }");

    try {
      final response = await http.post(
        Uri.parse('http://localhost:2000/api/marketplace/transfer'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ticketId": ticket["id"],
          "vendeurId": userId,
          "acheteurId": parsedDestinataire
        }),
      );

      print("Réponse de l'API: ${response.statusCode} - ${response.body}");
      
      if (response.statusCode == 200) {
        Navigator.pop(context); // Fermer la boîte de dialogue
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Ticket transféré avec succès !"),
          backgroundColor: Colors.white,
        ));
        setState(() {
          ticketsFuture = fetchTickets(); // Rafraîchir la liste des tickets
        });
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erreur: ${errorData['message'] ?? 'Échec du transfert'}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      print("Erreur de connexion : $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur de connexion : $error"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _mettreEnVente(Map<String, dynamic> ticket, String price, BuildContext context) async {
    if (userId == null) {
      print("Erreur: userId est NULL");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilisateur non identifié")));
      return;
    }

    double? parsedPrice = double.tryParse(price);
    if (parsedPrice == null || parsedPrice <= 0) {
      print("Erreur: Prix invalide: $price");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Veuillez entrer un prix valide.")));
      return;
    }

    print("Envoi de la requête API...");
    print("URL: http://localhost:2000/api/marketplace/list-ticket");
    print("Données envoyées: { ticketId: ${ticket["id"]}, vendeurId: $userId, prix: $parsedPrice }");

    try {
      final response = await http.post(
        Uri.parse('http://localhost:2000/api/marketplace/list-ticket'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ticketId": ticket["id"],
          "vendeurId": userId,
          "prix": parsedPrice
        }),
      );

      print("Réponse de l'API: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ticket mis en vente avec succès !")));
        setState(() {
          ticketsFuture = fetchTickets(); // Rafraîchir la liste des tickets
        });
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${errorData['message'] ?? 'Échec de la mise en vente'}")));
      }
    } catch (error) {
      print("rreur de connexion : $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de connexion : $error")));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tickets'),
        backgroundColor: Color(0xFF0172B2),
        automaticallyImplyLeading: false, // Supprime la flèche de retour
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else {
            print(snapshot.data);
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: ticket["imageURL"] != null && ticket["imageURL"].isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _openImageFullScreen(ticket["imageURL"]);
                      },
                      child: Image.network(
                        ticket["imageURL"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                        },
                      ),
                    )
                        : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    title: Text(ticket['evenementNom'] ?? "Événement inconnu"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📍 Lieu : ${ticket['lieu'] ?? "Lieu non spécifié"}'),
                        Text('📅 Date : ${ticket['date'] ?? "Date non spécifiée"}'),
                        SizedBox(height: 8), // Ajoute un peu d'espace
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: ticket['statut'] == 'en vente' ? null : () => _showSaleDialog(ticket),
                                child: Text(ticket['statut'] == 'en vente' ? "Déjà en vente" : "Mettre en vente"),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showTransferDialog(ticket),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: Text("Transférer"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      _showTicketDetail(ticket);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      // Barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0172B2),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Événements'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  void _openImageFullScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Aperçu du Ticket"),
          ),
          body: Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showTicketDetail(Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket['evenementNom'] ?? "Événement inconnu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              SizedBox(height: 8),
              Text('📍 Lieu : ${ticket['lieu'] ?? "Lieu non spécifié"}'),
              SizedBox(height: 5),
              Text('📅 Date : ${ticket['date'] ?? "Date non spécifiée"}'),
              SizedBox(height: 5),
              Text('🎟️ Type : ${ticket['type'] ?? "Type non défini"}'),
              SizedBox(height: 5),
              Text('🔗 Stockage NFT : ${ticket['stockageNFT'] ?? "Aucune donnée"}'),
              Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Fermer"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
