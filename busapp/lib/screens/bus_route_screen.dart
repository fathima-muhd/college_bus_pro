import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusRouteScreen extends StatefulWidget {
  final String busId;
  const BusRouteScreen({required this.busId, Key? key}) : super(key: key);

  @override
  _BusRouteScreenState createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
  late final MapController _mapController;
  List<Marker> _busStops = [];
  List<LatLng> _routePath = [];
  final String orsApiKey = "5b3ce3597851110001cf6248dce1d2c429b144cbaa73882093287f21"; // Replace with your ORS key

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setBusRoutes();
    });
  }

  void _setBusRoutes() async {
   String busKey = widget.busId; // Use the exact bus ID format



    Map<String, List<Map<String, dynamic>>> busRoutes = {
      
 "Bus 1": [
        {"name": "Valanjambalam", "lat": 9.965441122056932, "lng": 76.28667371140652},
        {"name": "Manorama,Panampilly", "lat": 9.965578742194355, "lng": 76.29454584241404},
        {"name": "Janatha", "lat": 9.967909730391705, "lng": 76.31276035901058},
        {"name": "Thammanam", "lat": 9.98621152852096, "lng": 76.3109959891865},
        {"name": "Palarivattom", "lat": 9.991797082393614, "lng": 76.30916309269784},
        {"name": "HMT", "lat": 10.054892066396741, "lng": 76.32376663102224},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],

      "Bus 2": [
        {"name": "Kothamangalam", "lat": 10.068109898855504, "lng": 76.61457516519668},
        {"name": "Nellikuzhy", "lat": 10.075479152500161, "lng": 76.59438031934526},
        {"name": "Erumalapady", "lat": 10.080625011217485, "lng": 76.57565279840482},
        {"name": "Odakkaly", "lat": 10.094405245868513, "lng": 76.55802373442909},
        {"name": "Cherukunnam", "lat": 10.10164136239732, "lng": 76.54163509201153},
        {"name": "Kuruppampady", "lat": 10.112688061576836, "lng": 76.51594207160358},
        {"name": "Pattal", "lat": 10.116209813325009, "lng": 76.49561873347464},
        {"name": "Perumbavoor", "lat": 10.114897266723231, "lng": 76.47753783615006},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],


"Bus 3": [
        {"name": "Muvattupuzha", "lat": 9.989586551458634, "lng": 76.57887938475844},
        {"name": "Pezhakkapilly", "lat": 10.019025547127272, "lng": 76.56286836638874},
        {"name": "Trikkalathoor", "lat": 10.034727427944906, "lng": 76.54602405665973},
        {"name": "Mannoor", "lat": 10.045314101840336, "lng": 76.53361167852616},
        {"name": "Keezhillam", "lat": 10.058552453528927, "lng": 76.52754180873248},
        {"name": "Pulluvazhy", "lat": 10.085052659584496, "lng": 76.50221125900612},
        {"name": "Perumbavoor", "lat": 10.114965004304661, "lng": 76.477524512582},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],


 "Bus 4": [
        {"name": "Thuravoor", "lat": 9.773283209266868, "lng": 76.30743982483894},
        {"name": "Aroor", "lat": 9.877899023686311, "lng": 76.30372507642912},
        {"name": "Madavana,Kundannoor", "lat": 9.911794164247077, "lng": 76.31691357098673},
        {"name": "Vyttila", "lat": 9.968198289949113, "lng": 76.31813930562838},
        {"name": "Vennala,Chakkarapparambu", "lat": 9.990821614332004, "lng": 76.31914339991299},
        {"name": "CUSAT", "lat": 10.046724595841178, "lng": 76.31820986447781},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],  

  "Bus 5": [
        {"name": "Edakochi", "lat": 9.913098316637148, "lng": 76.28770947223961},
        {"name": "Palluruthy", "lat": 9.921565605151581, "lng": 76.27348027016733},
        {"name": "Thevara", "lat": 9.932755199469932, "lng": 76.2998913569504},
        {"name": "Maharajas Ground", "lat": 9.973183709579668, "lng": 76.28498350601058},
        {"name": "Ernakulam Town Hall", "lat": 9.988361346102195, "lng": 76.28623356933778},
        {"name": "Palarivattom", "lat": 10.004186956591273, "lng": 76.3097042100806},
        {"name": "Pathadipalam", "lat": 10.039953786266453, "lng": 76.31620889012652},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ], 


  "Bus 6": [
        {"name": "Vazhappilly", "lat": 10.0026291569432, "lng": 76.57122060331282},
        {"name": "Cheruvattoor", "lat": 10.053633127019637, "lng": 76.57954916745801},
        {"name": "Methala", "lat": 10.079905338328453, "lng": 76.54526079563891},
        {"name": "Kuruppampady", "lat": 10.112774783198203, "lng": 76.51137551189655},
        {"name": "Kuruchilakkode,Koovappady", "lat": 10.161940507787913, "lng": 76.48648895675211},
        {"name": "Neeleshwaram, Kottamam", "lat": 10.180636853210686, "lng": 76.46338422090037},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],   



  "Bus 7": [
        {"name": "Kodungalloor", "lat": 10.222868123510866, "lng": 76.19609464629804},
        {"name": "Moothukunnam", "lat": 10.190155488087278, "lng": 76.20156084099641},
        {"name": "Thuruthippuram", "lat": 10.196913441920474, "lng": 76.2205104099827},
        {"name": "Paravoor Municipal Jn.", "lat": 10.148283273391915, "lng": 76.22462516921627},
        {"name": "Manjali", "lat": 10.150674436869323, "lng": 76.26934017544139},
        {"name": "Aduvassery", "lat": 10.154015476647036, "lng": 76.3197535258698},
        {"name": "Munickal, Chengamanad", "lat": 10.154532091383226, "lng": 76.3373253525324},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],   

     "Bus 12": [
        {"name": "Vazhikulangara,Poosaripady", "lat": 10.136204912625505, "lng": 76.23899114704744},
        {"name": "Koonamavu", "lat": 10.114337132633246, "lng": 76.2598691592994},
        {"name": "Kallupalam,Neericode", "lat": 10.117833548173026, "lng": 76.28363067840701},
        {"name": "Kottapuram", "lat": 10.679609135308686, "lng": 76.19225377630606},
        {"name": "Desom/Parambayanam", "lat": 10.135900541924663, "lng": 76.35338841489309},
        {"name": "Airport", "lat": 10.159046469090493, "lng": 76.38323861238348},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],   

  "Bus 13": [
        {"name": "Piravam", "lat": 9.873163939151054, "lng": 76.49212147480885},
        {"name": "Pazhoor Temple,Mamala Kavala", "lat": 9.884166540286605, "lng": 76.4731076108318},
        {"name": "Ezhakkaranad, Slappilly", "lat": 9.931657794432644, "lng": 76.45621538940934},
        {"name": "Puthencruiz-Choondi", "lat": 10.084947241947138, "lng": 76.37164197258295},
        {"name": "Pattimattom", "lat": 10.02582399142221, "lng": 76.44852166621446},
        {"name": "Perumbavoor", "lat": 10.114965004304661, "lng": 76.477524512582},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],   

"Bus 14": [
        {"name": "Kunnumpuram Signal,Puthiya Road", "lat": 9.992935807126146, "lng": 76.31516098673173},
        {"name": "Manjummal Palli", "lat": 10.059865793580032, "lng": 76.30197064194897},
        {"name": "Eloor-Companypady", "lat": 10.073799895678313, "lng": 76.29470230857315},
        {"name": "Pathalam", "lat": 10.071169685285264, "lng": 76.31847483399393},
        {"name": "Edayar,Idukki Jn.", "lat": 10.084176101686234, "lng": 76.31425638398692},
        {"name": "Muppathadam", "lat": 10.091772175448472, "lng": 76.31806190964667},
        {"name": "ASIET", "lat": 10.178406847555175, "lng": 76.43050088536532},
      ],   




    };

    if (!busRoutes.containsKey(busKey)) {
      debugPrint("No route found for busKey: $busKey");
      return;
    }

    List<Marker> stopMarkers = [];
    List<LatLng> waypoints = [];

    for (var stop in busRoutes[busKey]!) {
      double lat = stop["lat"];
      double lng = stop["lng"];

      stopMarkers.add(
        Marker(
  point: LatLng(lat, lng),
  width: 60,
  height: 60,
  child: const Icon(Icons.location_on, color: Colors.red, size: 60),
),

      );

      waypoints.add(LatLng(lat, lng));
    }

    // Fetch real route path from OpenRouteService
    List<LatLng> routePath = await _fetchRouteFromORS(waypoints);

    if (mounted) {
      setState(() {
        _busStops = stopMarkers;
        _routePath = routePath;
      });

      // Move map to first stop
      if (_busStops.isNotEmpty) {
        _mapController.move(_busStops.first.point, 12);
      }
    }
  }

  Future<List<LatLng>> _fetchRouteFromORS(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return [];

    final String url = "https://api.openrouteservice.org/v2/directions/driving-car/geojson";
    List<List<double>> coordinates = waypoints.map((point) => [point.longitude, point.latitude]).toList();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": orsApiKey,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "coordinates": coordinates,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<LatLng> routePath = (data["features"][0]["geometry"]["coordinates"] as List)
          .map((coord) => LatLng(coord[1], coord[0])) // Reverse lat/lng order
          .toList();
      return routePath;
    } else {
      debugPrint("Failed to fetch route: ${response.body}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bus Route - ${widget.busId}')),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(10.1004392, 76.4942694),
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePath,
                strokeWidth: 6.0,
                color: Colors.blue.withOpacity(0.7),
              ),
            ],
          ),
          MarkerLayer(markers: _busStops),
        ],
      ),
    );
  }
}