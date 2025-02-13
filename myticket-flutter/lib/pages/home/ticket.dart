import 'package:flutter/material.dart';

class TicketsPage extends StatefulWidget {
  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Tickets"),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            _buildTicketItem(
              context,
              "Concert de Drake",
              "Valide",
              "assets/images/concert_1.jpg",
            ),
            _buildTicketItem(
              context,
              "Festival EDM",
              "Expiré",
              "assets/images/concert_2.jpg",
            ),
            _buildTicketItem(
              context,
              "Gala VIP",
              "Valide",
              "assets/images/pray.png",
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Active l'icône correspondante
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/event');
              break;
            case 2:
              Navigator.pushNamed(context, '/tickets');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Event"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildTicketItem(BuildContext context, String title, String status, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            _showImageDialog(context, imagePath);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Statut: $status"),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Supprimer') {
              _deleteTicket(title);
            }
          },
          itemBuilder: (BuildContext context) {
            return ['Supprimer'].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Fermer",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteTicket(String title) {
    setState(() {
      // Implémenter la suppression réelle ici
    });
  }
}
