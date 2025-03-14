import 'package:flutter/material.dart';
import 'home.dart';
import 'ticket.dart';
import 'profile.dart';
import 'buy/buy1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _selectedIndex = 1;
  late Future<List<Map<String, dynamic>>> eventsFuture;
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    eventsFuture = fetchEvents();
    _searchController.addListener(_filterEvents);
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await http.get(Uri.parse('http://localhost:2000/api/events/forEvent'));
    if (response.statusCode == 200) {
      final events = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {
        allEvents = events;
        filteredEvents = events;
      });
      return events;
    } else {
      throw Exception('Erreur lors de la récupération des événements');
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredEvents = allEvents.where((event) {
        final name = event['nom'].toString().toLowerCase();
        final location = event['lieu'].toString().toLowerCase();
        final date = event['date'].toString().toLowerCase();
        return name.contains(query) || location.contains(query) || date.contains(query);
      }).toList();
    });
    print('Filtered events: $filteredEvents');
  }

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
            icon: Icon(Icons.shopping_cart, color: Color(0xFF0172B2), size: 28),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
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
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(
                        eventId: event['idEvenement'],
                        imageUrl: event['imagePath'] ?? 'assets/images/eminem.jpg',
                        title: event['nom'],
                        location: event['lieu'],
                        date: event['date'].split('T')[0],
                        description: event['description'],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0172B2),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final int eventId;
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final String description;

  EventCard({
    required this.eventId,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyTicket_1Page(
                              eventId: eventId,
                              eventName: title,
                              eventDate: date,
                              eventLocation: location,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Text('Buy Ticket now', style: TextStyle(color: Colors.green)),
                    ),
                    TextButton(
                      onPressed: () {
                        _showEventDetails(context);
                      },
                      child: Text('En savoir plus...', style: TextStyle(color: Color(0xFF0172B2))),
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

  void _showEventDetails(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(24),
        // Utilisez MediaQuery pour rendre la hauteur plus adaptative
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de poignée pour indiquer que le modal peut être fermé
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Divider(thickness: 1),
            SizedBox(height: 16),
            // Utilisation de ListView pour permettre le défilement si le contenu est trop long
            Expanded(
              child: ListView(
                children: [
                  _buildInfoRow(Icons.location_on, "Lieu", location),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today, "Date", date),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.description, "Description", description),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text("Annuler", style: TextStyle(color: Colors.grey[700])),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Action supplémentaire si nécessaire
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0172B2),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Fermer", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  }  

  // Fonction auxiliaire pour créer des lignes d'information avec icônes
Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Color(0xFF0172B2)),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}
