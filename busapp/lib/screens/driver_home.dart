import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomeScreen extends StatefulWidget {
  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isSharingLocation = false;
  String? _driverId;
  String? _busId;
  double? _latitude;
  double? _longitude;
  TextEditingController _delayReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }

  Future<void> _fetchDriverDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _driverId = user.uid);

    DocumentSnapshot driverDoc = await FirebaseFirestore.instance.collection('drivers').doc(_driverId).get();
    if (driverDoc.exists) {
      setState(() => _busId = driverDoc['busId']);
    }
  }

  Future<void> _startSharingLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
    setState(() => _isSharingLocation = true);

    Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10))
        .listen((Position position) async {
      if (_busId != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        await FirebaseFirestore.instance.collection('bus_locations').doc(_busId).set({
          'latitude': _latitude,
          'longitude': _longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'driver_id': _driverId,
          
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> _stopSharingLocation() async {
    setState(() {
      _isSharingLocation = false;
      _latitude = null;
      _longitude = null;
    });
    if (_busId != null) {
      await FirebaseFirestore.instance.collection('bus_locations').doc(_busId).delete();
    }
  }
  Future<void> _sendDelayReason() async {
  if (_driverId != null && _delayReasonController.text.isNotEmpty) {
    // Retrieve the busId from the driver's document
    String? busId = await _getBusIdFromDriver(_driverId!);

    if (busId != null) {
      // Extract only the bus number (e.g., "bus6" → "6")
      String busNumber = busId.replaceAll(RegExp(r'[^0-9]'), ''); 

      // Send the delay reason with the extracted bus number
      await FirebaseFirestore.instance.collection('bus_delays').doc(busId).set({
        'bus_id': busId,            // ✅ Store the original busId
        'bus_number': busNumber,    // ✅ Dynamically extracted number
        'reason': _delayReasonController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'driver_id': _driverId,
      });

      _delayReasonController.clear();
      print("✅ Delay reason sent for $busId (Bus Number: $busNumber)");
    } else {
      print("❌ No bus assigned to this driver.");
    }
  }
}

// Fetch the busId from the drivers collection
Future<String?> _getBusIdFromDriver(String driverId) async {
  DocumentSnapshot driverDoc = await FirebaseFirestore.instance
      .collection('drivers')
      .doc(driverId)
      .get();

  if (driverDoc.exists && driverDoc.data() != null) {
    var data = driverDoc.data() as Map<String, dynamic>;
    return data['busId']; // ✅ Make sure 'busId' exists in Firestore
  }
  return null;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("GO CAMPUS", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.yellow),
              child: Center(
                child: Text(
                  "Driver Menu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             const SizedBox(height: 20),
            const Text(
              "Welcome!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Image.asset('assets/bus_image.png', height: 200), // Bus Image at the Top
            SizedBox(height: 10),
            Text("Assigned Bus: ${_busId ?? "Loading..."}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.yellow, width: 3), // Yellow Border
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                      onPressed: _isSharingLocation ? _stopSharingLocation : _startSharingLocation,
                      child: Text(_isSharingLocation ? "Stop Sharing Location" : "Start Sharing Location", style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isSharingLocation ? Icons.location_on : Icons.location_off, color: _isSharingLocation ? Colors.green : Colors.red),
                        SizedBox(width: 10),
                        Text("Live Location Sharing: ${_isSharingLocation ? "ON" : "OFF"}", style: TextStyle(fontSize: 16, color: Colors.grey[700]))
                      ],
                    ),
                    if (_latitude != null && _longitude != null) ...[
                      SizedBox(height: 10),
                      Text("Latitude: $_latitude", style: TextStyle(fontSize: 16)),
                      Text("Longitude: $_longitude", style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.yellow, width: 3), // Yellow Border
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _delayReasonController,
                      decoration: InputDecoration(labelText: "Enter Message", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message, color: const Color.fromARGB(255, 253, 118, 0)), // Message icon
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                          onPressed: _sendDelayReason, // Functionality to send delay message
                          child: Text(
                            "Send Message",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ]
                    ),
                 ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}