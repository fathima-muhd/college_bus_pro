import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusScheduleScreen extends StatefulWidget {
  BusScheduleScreen({super.key});

  @override
  _BusScheduleScreenState createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  String searchQuery = "";
  final Map<String, String> driverPhoneNumbers = {
    '1': '+917559886264', '2': '+917510210481', '3': '+918089866264',
    '4': '+919745634661', '5': '+919946332526', '6': '+917306212373',
    '7': '+918606417493', '12': '+919567017978', '13': '+917025907560', '14': '+918590527903',
  };

  final Map<String, String> driverNames = {
    '1': 'Jobby', '2': 'Eldo ', '3': 'Saju', '4': 'Shiburaj', '5': 'Biju', '6': 'Davis',
    '7': 'Sajeev', '12': 'Santhosh', '13': 'Prakash', '14': 'Mujeeb',
  };

  void _callDriver(String busNumber) {
    String formattedBusNumber = busNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (driverPhoneNumbers.containsKey(formattedBusNumber)) {
      final Uri phoneUri = Uri.parse("tel:${driverPhoneNumbers[formattedBusNumber]}");
      launchUrl(phoneUri);
    } else {
      print("❌ Phone number not found for bus $busNumber.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('Bus Schedules', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search Bus...",
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bus_schedules').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bus schedules available."));
          }

          var filteredDocs = snapshot.data!.docs.where((doc) {
  String busNumber = doc.id.replaceAll(RegExp(r'[^0-9]'), ''); // Extract numbers
  return busNumber.toLowerCase().contains(searchQuery.toLowerCase());
}).toList();

return ListView(
  children: filteredDocs.map((doc) { // ✅ Now using filteredDocs

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String busNumber = doc.id.replaceAll(RegExp(r'[^0-9]'), ''); // Extract only numbers
    String routeName = data['route_name'] ?? "Unknown Route";
    List<dynamic> stops = (data['stops'] is List) ? data['stops'] : [];
    String driverName = driverNames[busNumber] ?? "Unknown"; // ✅ FIXED

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255,248,248,246),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bus No: $busNumber",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 136, 0)),
                ),
                Column(
                  children: [
                    Text("Driver: $driverName", style: TextStyle(color: const Color.fromARGB(255, 255, 136, 0), fontWeight: FontWeight.w500)),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () => _callDriver(busNumber),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route: $routeName', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                ...stops.isNotEmpty
                    ? stops.map((stop) {
                        if (stop is Map<String, dynamic>) {
                          String stopName = stop.entries.firstWhere(
                            (entry) => entry.key != 'time',
                            orElse: () => const MapEntry('Unknown Stop', ''),
                          ).value;
                          String time = stop['time'] ?? "Unknown Time";
                          return Row(
                            children: [
                              Icon(Icons.directions_bus, color: const Color.fromARGB(255, 255, 136, 0)),
                              SizedBox(width: 5),
                              Text('$stopName - $time'),
                            ],
                          );
                        }
                        return const Text("Invalid stop data.");
                      }).toList()
                    : [const Text("No stops available.")],
              ],
            ),
          ),
        ],
      ),
    );
  }).toList(),
);

        },
      ),
    );
  }
}
