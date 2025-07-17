import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageBusesScreen extends StatefulWidget {
  @override
  _ManageBusesScreenState createState() => _ManageBusesScreenState();
}

class _ManageBusesScreenState extends State<ManageBusesScreen> {
  final TextEditingController _busIdController = TextEditingController();
  final TextEditingController _driverIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addBus() async {
    String busId = _busIdController.text.trim();
    String driverId = _driverIdController.text.trim();

    if (busId.isNotEmpty && driverId.isNotEmpty) {
      await _firestore.collection('buses').doc(busId).set({
        'busId': busId,
        'driverId': driverId,
        'status': 'Active',
        'location': {'lat': 0.0, 'lng': 0.0},
      });
      _busIdController.clear();
      _driverIdController.clear();
    }
  }

  Future<void> _deleteBus(String busId) async {
    await _firestore.collection('buses').doc(busId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Buses"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _busIdController,
              decoration: InputDecoration(labelText: "Bus ID", filled: true, fillColor: Colors.yellow[100]),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _driverIdController,
              decoration: InputDecoration(labelText: "Driver ID", filled: true, fillColor: Colors.yellow[100]),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addBus,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Add Bus",
                style: TextStyle(color: Colors.black)
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('buses').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var buses = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      var bus = buses[index];
                      return Card(
                        color: Colors.yellow[100],
                        child: ListTile(
                          title: Text(bus['busId']),
                          subtitle: Text("Driver: ${bus['driverId']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBus(bus['busId']),
                          ),
                        ),
                      );
                    },
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