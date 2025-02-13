import 'package:flutter/material.dart';
import 'package:projects/pages/home/event.dart';
import 'package:projects/pages/home/profile.dart';
import 'package:projects/pages/home/ticket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _selectedCategory = 0;
  int _selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = fetchEvents();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await http.get(Uri.parse('http://localhost:2000/api/events/home'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des événements');
    }
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher un concert...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.blue, size: 28),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else {
                    final events = snapshot.data!;
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildFeaturedConcert(event['imagePath'] ?? 'assets/images/eminem.jpg');
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildCategoryTab("Populaire", 0),
                  _buildCategoryTab("Best", 1),
                  _buildCategoryTab("50% off", 2),
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else {
                    final events = snapshot.data!;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventCard(
                          event['nom'],
                          event['imagePath'] ?? 'assets/images/eminem.jpg',
                          event['lieu'],
                          event['date'].split('T')[0],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Event"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildFeaturedConcert(String imagePath) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[300],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String imagePath, String location, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_detail');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(location, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(date, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: _selectedCategory == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedCategory == index ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
