import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRoutesScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _routeController = TextEditingController();

  Future<void> _addRoute() async {
    String routeName = _routeController.text.trim();
    if (routeName.isNotEmpty) {
      await _firestore.collection('routes').doc(routeName).set({
        'routeId': routeName,
        'stops': ["Stop 1", "Stop 2"],
      });
      _routeController.clear();
    }
  }

  Future<void> _deleteRoute(String routeId) async {
    await _firestore.collection('routes').doc(routeId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Routes"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _routeController,
              decoration: InputDecoration(labelText: "Route ID", filled: true, fillColor: Colors.yellow[100]),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addRoute,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Add Route",
                style: TextStyle(color: Colors.black)
                ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('routes').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var routes = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      var route = routes[index];
                      return Card(
                        color: Colors.yellow[100],
                        child: ListTile(
                          title: Text(route['routeId']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRoute(route['routeId']),
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