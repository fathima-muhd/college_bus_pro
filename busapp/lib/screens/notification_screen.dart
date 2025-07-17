import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DelayNotificationsScreen extends StatefulWidget {
  @override
  _DelayNotificationsScreenState createState() => _DelayNotificationsScreenState();
}

class _DelayNotificationsScreenState extends State<DelayNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow[800],
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 8, 1, 1)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bus_delays').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No notifications available."));
          }

          var delayDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: delayDocs.length,
            itemBuilder: (context, index) {
              var data = delayDocs[index].data() as Map<String, dynamic>;

              String busId = data.containsKey('bus_id') ? data['bus_id'] : "Unknown";
              String busNumber = RegExp(r'\d+').hasMatch(busId)
                  ? RegExp(r'\d+').firstMatch(busId)!.group(0)!
                  : "Unknown";
              String delayReason = data.containsKey('reason') ? data['reason'] : "No reason provided";
              Timestamp timestamp = data.containsKey('timestamp') ? data['timestamp'] : Timestamp.now();
              String formattedTime = DateFormat('hh:mm a EEE, MMM d, yyyy').format(timestamp.toDate().toLocal());

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 226, 154),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.directions_bus, color: Colors.black, size: 40),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bus Number: $busNumber",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 4),
                          Text(
                            delayReason,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          SizedBox(height: 6),
                          Text(
                            formattedTime,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
