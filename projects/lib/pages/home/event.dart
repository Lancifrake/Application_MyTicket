import 'package:flutter/material.dart';
import 'home.dart';
import 'ticket.dart';
import 'profile.dart';
import 'buy/buy1.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _selectedIndex = 1; // Index de la page actuelle (1 pour Event)

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
        nextPage = TicketsPage();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.blue),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un concert...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              EventCard(
                imageUrl: 'assets/images/concert_1.jpg',
                title: 'Concert summer 2025',
                location: 'Palais des congrès',
                date: '16 September 2023',
              ),
              EventCard(
                imageUrl: 'assets/images/concert_2.jpg',
                title: 'Lalala Fest',
                location: 'Jakarta',
                date: '23 August 2025',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // Active l'icône sélectionnée
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acceuil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String date;

  EventCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(location, style: TextStyle(color: Colors.grey)),
                    Spacer(),
                    Icon(Icons.event, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(date, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // 🚀 Redirection vers BuyTicket_1Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BuyTicket_1Page()),
                        );
                      },
                      child: Text('Buy Ticket now', style: TextStyle(color: Colors.green)),
                    ),
                    TextButton(
                      onPressed: () {
                        _showTicketDetails(context);
                      },
                      child: Text('En savoir plus...', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showTicketDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 300, // Hauteur de la fenêtre
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description du ticket",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              SizedBox(height: 8),
              Text(
                "🎶 Profitez d'une expérience musicale inoubliable avec ${title}.\n\n"
                    "📍 Lieu: $location\n"
                    "📅 Date: $date\n\n"
                    "✅ Votre ticket vous donne accès à toutes les performances live et aux zones exclusives.",
                style: TextStyle(fontSize: 14),
              ),
              Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la fenêtre
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
