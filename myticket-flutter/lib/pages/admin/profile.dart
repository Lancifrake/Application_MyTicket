import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'event_management.dart';
import 'ticket_management.dart';

class OrganizerProfilePage extends StatefulWidget {
  @override
  _OrganizerProfilePageState createState() => _OrganizerProfilePageState();
}

class _OrganizerProfilePageState extends State<OrganizerProfilePage> {
  int _selectedIndex = 3;
  bool notificationsEnabled = true;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OrganizerDashboard()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => EventManagementPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TicketManagementPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OrganizerProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil & Paramètres"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),
                  SizedBox(height: 20),
                  Text("Nom de l'organisateur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("organisateur@email.com", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_profile_a');
                    },
                    child: Text("Modifier le profil"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Modifier le mot de passe"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SwitchListTile(
              title: Text("Activer les notifications"),
              value: notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Se déconnecter", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Ajouter ici la logique de déconnexion
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Événements"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
