import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../scanner/home_s.dart';
import '../scanner/profile_s.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  int _selectedIndex = 1; // Index par défaut sur Scan
  MobileScannerController cameraController = MobileScannerController();

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home_sScreen()));
        break;
      case 1:
      // Reste sur la page de scan
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Profile_sPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner QR Code"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture barcode) {
                if (barcode.barcodes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Échec du scan ! Aucun code détecté.')),
                  );
                } else {
                  final String code = barcode.barcodes.first.rawValue ?? "Code non valide";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('QR Code détecté : $code')),
                  );
                  // Ajoutez ici la logique de redirection ou de validation
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Positionnez le QR Code dans le cadre pour scanner.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // Détermine quel onglet est actif
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
