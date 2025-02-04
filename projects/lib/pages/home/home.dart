import 'package:flutter/material.dart';
import 'package:projects/pages/home/event.dart'; // Vérifie si cette ligne est présente
import 'package:projects/pages/home/profile.dart'; // Vérifie si cette ligne est présente
import 'package:projects/pages/home/ticket.dart'; // Vérifie si cette ligne est présente


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _selectedCategory = 0; // 0 = Populaire, 1 = Best, 2 = 50% Off
  int _selectedIndex = 0; // Pour gérer l'icône active

  // Méthode de navigation
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
            // Barre de recherche + Panier
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
                      Navigator.pushNamed(context, '/cart'); // Redirection vers le panier
                    },
                  ),
                ],
              ),
            ),

            // Carrousel des concerts en vedette
            Container(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildFeaturedConcert("assets/images/concert_${index + 1}.jpg");
                },
              ),
            ),

            SizedBox(height: 15),

            // Onglets de sélection des catégories (Populaire, Best, 50% Off)
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

            // Liste des concerts défilables
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildEventCard(
                        "Concert Summer 2025",
                        "assets/images/violon.png",
                        "Palais des Congrès",
                        "15 June 2025",
                      ),
                      _buildEventCard(
                        "Jazz Night Festival",
                        "assets/images/2pac coachella.jpg",
                        "Théâtre National",
                        "20 July 2025",
                      ),
                      _buildEventCard(
                        "Rock & Roll Live",
                        "assets/images/pray.png",
                        "Stade Omnisports",
                        "5 August 2025",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Barre de navigation en bas avec gestion de l'icône active
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // Active l'icône sélectionnée
        onTap: _onItemTapped, // Gère la navigation

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Event"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // Widget pour un concert en vedette
  Widget _buildFeaturedConcert(String imagePath) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[300],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            print("Erreur de chargement de l'image : $imagePath");
          },
        ),
      ),
    );
  }

  // Widget pour un événement
  Widget _buildEventCard(String title, String imagePath, String location, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_detail'); // Redirection vers les détails de l'événement
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

  // Widget pour les onglets "Populaire", "Best", "50% off"
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
