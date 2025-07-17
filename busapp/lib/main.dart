import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/signup.dart';
import 'screens/map_screen.dart';
import 'screens/bus_schedule_screen.dart';
import 'screens/bus_route_screen.dart';
import 'firebase_options.dart';
import 'screens/notification_screen.dart';
import 'package:busapp/screens/bus_route_screen.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // ✅ Use correct Firebase config
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College Bus App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/driver_home': (context) => DriverHomeScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/bus_schedule': (context) => BusScheduleScreen(),
        '/select_bus_tracking': (context) => SelectBusTrackingScreen(),
        '/select_bus_routes': (context) => SelectBusRoutesScreen(),
        '/delay_notifications': (context) => DelayNotificationsScreen(), 
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/map') {
          final busId = settings.arguments as String?;
          if (busId != null) {
            return MaterialPageRoute(
                builder: (context) => MapScreen(busId: busId));
          }
        }
        if (settings.name == '/bus_routes') {
          final busId = settings.arguments as String?;
          if (busId != null) {
            return MaterialPageRoute(
                builder: (context) => BusRouteScreen(busId: busId));
          }
        }
        return null;
      },
    );
  }
}

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied. Open settings to enable them.');
      return;
    }

    // If permissions are granted, get the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('Location: ${position.latitude}, ${position.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome",
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.yellow.shade700,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.yellow.shade700),
              child: const Text("Menu",
                  style: TextStyle(fontSize: 24, color: Colors.black)),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Welcome!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/bus_image.png', height: 150),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuButton(
                      context, "Live Track", '/select_bus_tracking', Icons.location_on),
                  _buildMenuButton(
                      context, "Bus Routes", '/select_bus_routes', Icons.route),
                  _buildMenuButton(
                      context, "Bus Schedule", '/bus_schedule', Icons.schedule),
                  _buildMenuButton(
                      context, "Notifications", '/delay_notifications', Icons.notifications),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, String text, String route, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.yellow.shade700),
            const SizedBox(height: 10),
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}



class SelectBusTrackingScreen extends StatefulWidget {
  @override
  _SelectBusTrackingScreenState createState() => _SelectBusTrackingScreenState();
}

class _SelectBusTrackingScreenState extends State<SelectBusTrackingScreen> {
  List<String> busIds = [
    "bus1", "bus2", "bus3", "bus4", "bus5", 
    "bus6", "bus7", "bus12", "bus13", "bus14"
  ]; // ✅ Updated bus list

  List<String> filteredBusIds = [];

  @override
  void initState() {
    super.initState();
    filteredBusIds = List.from(busIds);
  }

  void filterBuses(String query) {
    setState(() {
      filteredBusIds = busIds
          .where((bus) => bus.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bus for Live Tracking"),
        backgroundColor: Colors.yellow[700], // ✅ Yellow Theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // ✅ Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: TextField(
                onChanged: filterBuses,
                decoration: const InputDecoration(
                  hintText: "Search Bus Number...",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 15), // ✅ Spacing

            // ✅ List of buses
            Expanded(
              child: ListView.builder(
                itemCount: filteredBusIds.length,
                itemBuilder: (context, index) {
                  String busId = filteredBusIds[index];

                  return Card(
                     color: const Color.fromARGB(255, 240, 219, 150), // ✅ Yellow Box
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.directions_bus, color: const Color.fromARGB(255, 11, 11, 11)), // ✅ Bus Icon
                      title: Text(
                        "Live Tracking - ${busId.toUpperCase()}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 14, 14, 14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: const Color.fromARGB(179, 11, 11, 11)), // ✅ Arrow for better UI
                      onTap: () {
                        Navigator.pushNamed(context, '/map', arguments: busId);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SelectBusRoutesScreen extends StatelessWidget {
  final List<Map<String, String>> busRoutes = [
    {"id": "Bus 1", "from": "Valanjambalam", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 2", "from": "Kothamangalam", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 3", "from": "Muvattupuzha", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 4", "from": "Thuravoor", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 5", "from": "Edakochi", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 6", "from": "vazahppilly", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 7", "from": "Kodungalloor", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 12", "from": "vazhikulangara", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 13", "from": "Piravam", "to": "ASIET", "icon": "🚍"},
    {"id": "Bus 14", "from": "Edayar", "to": "ASIET", "icon": "🚍"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Buses"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Bus...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: busRoutes.length,
              itemBuilder: (context, index) {
                var bus = busRoutes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.directions_bus, color: Colors.white),
                    ),
                    title: bus["id"] != null 
                   ? Text(bus["id"]!, style: const TextStyle(fontWeight: FontWeight.bold)) 
                   : const Text("Unknown"),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.red, size: 10),
                            const SizedBox(width: 5),
                            Text("From ${bus["from"]}"),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 10),
                            const SizedBox(width: 5),
                            Text("To ${bus["to"]}"),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                  Navigator.push(
                 context,
    MaterialPageRoute(
      builder: (context) => BusRouteScreen(busId: bus["id"]!),
    ),
  );
}

                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class DriverHomeScreen extends StatefulWidget {
  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isSharingLocation = false;

  Future<void> _startSharingLocation() async {
    setState(() {
      _isSharingLocation = true;
    });
  }

  Future<void> _stopSharingLocation() async {
    setState(() {
      _isSharingLocation = false;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Live Location Sharing: ${_isSharingLocation ? "ON" : "OFF"}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSharingLocation
                  ? _stopSharingLocation
                  : _startSharingLocation,
              child: Text(_isSharingLocation
                  ? "Stop Sharing Location"
                  : "Start Sharing Location"),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${user?.email ?? 'Admin'}!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Manage Bus Routes"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Manage Users & Drivers"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Manage App Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
