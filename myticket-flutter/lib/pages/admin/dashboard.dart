import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'event_management.dart';
import 'ticket_management.dart';
import 'analytics.dart';

class OrganizerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tableau de Bord"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard("Événements actifs", "5", Icons.event, Colors.orange),
            _buildStatCard("Tickets vendus", "150", Icons.confirmation_number, Colors.green),
            _buildStatCard("Revenu total", "CFA 3,500,000", Icons.attach_money, Colors.blueGrey),
            SizedBox(height: 20),
            Text("Performance des ventes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(child: _buildSalesChart()),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsPage()));
              },
              child: Text("Exporter le rapport"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Événements"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EventManagementPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TicketManagementPage()));
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 18, color: color)),
      ),
    );
  }

  Widget _buildSalesChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 1000),
              FlSpot(2, 2000),
              FlSpot(3, 1500),
              FlSpot(4, 2800),
              FlSpot(5, 3500),
            ],
            isCurved: true,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
