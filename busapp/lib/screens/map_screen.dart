import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final String busId;

  MapScreen({required this.busId});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _userPosition = LatLng(0, 0);
  LatLng _busPosition = LatLng(0, 0);
  double _distance = 0.0;
  double _estimatedTime = 0.0;
  final MapController _mapController = MapController();
  double _busSpeed = 40.0; // Default speed in km/h

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToBusLocations();
    _fetchBusSpeed();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_userPosition, 15);
    });

    _updateDistanceAndTime();
  }

  void _listenToBusLocations() {
    FirebaseFirestore.instance
        .collection('bus_locations')
        .doc(widget.busId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        double lat = snapshot['latitude'];
        double lng = snapshot['longitude'];

        setState(() {
          _busPosition = LatLng(lat, lng);
          _updateDistanceAndTime();
        });
      }
    });
  }

  void _fetchBusSpeed() {
    FirebaseFirestore.instance
        .collection('bus_speeds')
        .doc(widget.busId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _busSpeed = snapshot['speed'].toDouble();
        });
      }
    });
  }

  void _updateDistanceAndTime() {
    if (_userPosition.latitude != 0 && _busPosition.latitude != 0) {
      double distance = Geolocator.distanceBetween(
        _userPosition.latitude, _userPosition.longitude,
        _busPosition.latitude, _busPosition.longitude,
      ) / 1000; // Convert to km

      setState(() {
        _distance = distance;
        _estimatedTime = (_busSpeed > 0) ? (distance / _busSpeed) * 60 : 0; // Convert hours to minutes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Tracking - ${widget.busId.toUpperCase()}')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _userPosition, initialZoom: 15),
            children: [
              TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
              MarkerLayer(markers: [
                Marker(
                  point: _userPosition,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.person_pin_circle, size: 35, color: Colors.green),
                ),
                Marker(
                  point: _busPosition,
                  width: 50,
                  height: 50,
                  child: Icon(Icons.directions_bus, size: 40, color: Colors.red),
                ),
              ]),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(245, 9, 9, 9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "⏳ Estimated Time: ${_estimatedTime.toStringAsFixed(0)} min",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "📍 Distance: ${_distance.toStringAsFixed(1)} km",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
