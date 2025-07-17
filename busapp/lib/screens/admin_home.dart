import 'package:flutter/material.dart';
import 'manage_buses.dart';
import 'manage_routes.dart';
import 'manage_drivers.dart';
import 'login_screen.dart'; // Import the login page


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Go Campus"),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.admin_panel_settings, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text("Admin Menu", style: TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Welcome Admin",
              style: TextStyle(
                fontSize: 24, // Adjust font size
                fontWeight: FontWeight.bold, // Make it bold
                color: Color.fromARGB(255, 249, 118, 2), // Set text color
              ),
            ),
            const SizedBox(height: 10), // Add spacing between text and image
            Center(
              child: Image.asset('assets/bus_image.png', height: 150),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSquareButton(context, "Manage Buses", Icons.directions_bus, ManageBusesScreen()),
                  const SizedBox(height: 20),
                  _buildSquareButton(context, "Manage Routes", Icons.map, ManageRoutesScreen()),
                  const SizedBox(height: 20),
                  _buildSquareButton(context, "Manage Drivers", Icons.person, ManageDriversScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create larger square buttons with an icon
  Widget _buildSquareButton(BuildContext context, String text, IconData icon, Widget screen) {
    return SizedBox(
      width: 300,
      height: 120,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 248, 248, 246),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12) , side: BorderSide(color: const Color.fromARGB(255, 244, 152, 3), width: 2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color.fromARGB(255, 255, 136, 0)),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 136, 0)),
            ),
          ],
        ),
      ),
    );
  }
}

	
