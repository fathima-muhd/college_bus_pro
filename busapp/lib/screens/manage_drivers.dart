import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDriversScreen extends StatefulWidget {
  @override
  _ManageDriversScreenState createState() => _ManageDriversScreenState();
}

class _ManageDriversScreenState extends State<ManageDriversScreen> {
  final TextEditingController _driverIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _busIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addDriver() async {
    String driverId = _driverIdController.text.trim();
    String name = _nameController.text.trim();
    String busId = _busIdController.text.trim();

    if (driverId.isNotEmpty && name.isNotEmpty) {
      await _firestore.collection('drivers').doc(driverId).set({
        'driverId': driverId,
        'name': name,
        'assignedBus': busId.isNotEmpty ? busId : 'None',
      });

      if (busId.isNotEmpty) {
        await _firestore.collection('buses').doc(busId).update({'driverId': driverId});
      }

      _driverIdController.clear();
      _nameController.clear();
      _busIdController.clear();
    }
  }

  Future<void> _deleteDriver(String driverId) async {
    await _firestore.collection('drivers').doc(driverId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Drivers"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _driverIdController,
              decoration: InputDecoration(labelText: "Driver ID", filled: true, fillColor: Colors.yellow[100]),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Driver Name", filled: true, fillColor: Colors.yellow[100]),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _busIdController,
              decoration: InputDecoration(labelText: "Bus ID (Optional)", filled: true, fillColor: Colors.yellow[100]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addDriver,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Add Driver",
                style: TextStyle(color: Colors.black)
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('drivers').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var drivers = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      var driver = drivers[index];
                      return Card(
                        color: Colors.yellow[100],
                        child: ListTile(
                          title: Text(driver['name']),
                          subtitle: Text("ID: ${driver['driverId']} | Bus: ${driver['assignedBus'] ?? 'None'}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDriver(driver['driverId']),
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

	
