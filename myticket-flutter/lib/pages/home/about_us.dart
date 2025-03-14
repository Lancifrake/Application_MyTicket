import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('À propos de nous'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo et nom de l'application
            Center(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF0172B2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'TicketApp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Notre mission
            _buildSectionTitle('Notre mission'),
            _buildSectionContent(
              'TicketApp a été créée pour simplifier la gestion des billets d\'événements. Notre mission est de fournir une plateforme sécurisée et transparente pour l\'achat, la vente et la gestion de billets pour tous types d\'événements.'
            ),
            
            SizedBox(height: 24),
            
            // Fonctionnalités clés
            _buildSectionTitle('Fonctionnalités clés'),
            _buildFeatureItem('Achat de billets sécurisé via blockchain'),
            _buildFeatureItem('Billets NFT uniques et non falsifiables'),
            _buildFeatureItem('Transfert de billets simplifié'),
            _buildFeatureItem('Historique des transactions transparent'),
            _buildFeatureItem('Détection des fraudes et billets contrefaits'),
            
            SizedBox(height: 24),
            
            // Notre équipe
            _buildSectionTitle('Notre équipe'),
            _buildSectionContent(
              'Nous sommes une équipe passionnée de développeurs, designers et experts en blockchain déterminés à révolutionner le monde des billets d\'événements. Notre expertise combinée nous permet de créer une application qui répond aux besoins des organisateurs d\'événements et des participants.'
            ),
            
            SizedBox(height: 24),
            
            // Contact
            _buildSectionTitle('Contactez-nous'),
            _buildContactInfo('Email', 'support@ticketapp.com', Icons.email),
            _buildContactInfo('Téléphone', '+237 6 94 54 20 20', Icons.phone),
            _buildContactInfo('Adresse', 'Yaounde Rue 5.327, Cameroun', Icons.location_on),
            
            SizedBox(height: 24),
            
            // Réseaux sociaux
            _buildSectionTitle('Suivez-nous'),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue.shade800),
                    SizedBox(width: 16),
                    _buildSocialIcon(FontAwesomeIcons.twitter, Colors.blue.shade400),
                    SizedBox(width: 16),
                    _buildSocialIcon(FontAwesomeIcons.instagram, Colors.purple.shade400),
                    SizedBox(width: 16),
                    _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blue.shade900),
                ],
            ),

            
            SizedBox(height: 32),
            
            // Conditions d'utilisation et confidentialité
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigation vers la page des conditions d'utilisation
                    },
                    child: Text('Conditions d\'utilisation'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigation vers la page de politique de confidentialité
                    },
                    child: Text('Politique de confidentialité'),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Copyright
            Center(
              child: Text(
                '© 2025 TicketApp. Tous droits réservés.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0172B2),
        ),
      ),
    );
  }
  
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }
  
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Color(0xFF0172B2),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}