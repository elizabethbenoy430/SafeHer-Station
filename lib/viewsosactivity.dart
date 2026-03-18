import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewSOSActivity extends StatefulWidget {
  const ViewSOSActivity({super.key});

  @override
  State<ViewSOSActivity> createState() => _ViewSOSActivityState();
}

class _ViewSOSActivityState extends State<ViewSOSActivity> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<dynamic> sosList = [];
  bool isLoading = true;

  double? stationLat;
  double? stationLng;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// ✅ Orchestrator: Ensures station coords exist before calculating SOS distances
  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    await fetchStationLocation();
    await fetchSOSActivity();
  }

  Future<void> fetchStationLocation() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('tbl_station')
          .select('station_lantitude, station_longitude')
          .eq('station_id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          // Note: Kept your spelling 'lantitude' to match your DB query
          stationLat = double.tryParse(response['station_lantitude'].toString());
          stationLng = double.tryParse(response['station_longitude'].toString());
        });
      }
    } catch (e) {
      debugPrint("Station Location Error: $e");
    }
  }

  /// ✅ Haversine Formula for Distance
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth radius in km
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> fetchSOSActivity() async {
    // Prevent calculation if station location failed to load
    if (stationLat == null || stationLng == null) {
      debugPrint("Calculation skipped: Station coordinates are null.");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await supabase.from('tbl_sos').select('''
          sos_id,
          sos_status,
          sos_seen,
          created_at,
          sos_latitude,
          sos_longitude,
          sos_message,
          tbl_user(user_name)
        ''').order('created_at', ascending: false);

      List<Map<String, dynamic>> filteredList = [];

      for (var sos in response) {
        if (sos['sos_latitude'] != null && sos['sos_longitude'] != null) {
          double lat = double.tryParse(sos['sos_latitude'].toString()) ?? 0;
          double lng = double.tryParse(sos['sos_longitude'].toString()) ?? 0;

          // Safe calculation using ! because we checked for nulls above
          double distance = calculateDistance(stationLat!, stationLng!, lat, lng);

          if (distance <= 5) {
            sos['distance'] = distance;
            filteredList.add(Map<String, dynamic>.from(sos));
          }
        }
      }

      // Sort: Nearest first
      filteredList.sort((a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        sosList = filteredList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch SOS Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateSeenStatus(int sosId, String status) async {
    try {
      await supabase
          .from('tbl_sos')
          .update({'sos_seen': status})
          .eq('sos_id', sosId);
      
      fetchSOSActivity(); // Refresh list after update
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  /// ✅ Fixed Map Launcher URL
  Future<void> _openMap(double lat, double lng) async {
    final String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri url = Uri.parse(googleUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $googleUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Nearby SOS Activity",
          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: _initializeData,
          )
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bgl.png", fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.black)),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85))),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
              : sosList.isEmpty
                  ? const Center(child: Text("No Nearby SOS (within 5 km)", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sosList.length,
                      itemBuilder: (context, index) {
                        final sos = sosList[index];
                        return _buildSOSCard(sos, index);
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildSOSCard(Map<String, dynamic> sos, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.greenAccent,
                child: Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sos['tbl_user']?['user_name'] ?? "Unknown", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(sos['created_at'] ?? "", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(20)),
                child: Text(sos['sos_status'] ?? "Unknown", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (sos['sos_message'] != null) Text(sos['sos_message'], style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Distance: ${sos['distance'].toStringAsFixed(2)} km", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            "Seen Status: ${sos['sos_seen'] ?? "Not Seen"}",
            style: TextStyle(
              color: sos['sos_seen'] == "Seen" ? Colors.greenAccent : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openMap(double.parse(sos['sos_latitude'].toString()), double.parse(sos['sos_longitude'].toString())),
            child: Row(
              children: const [
                Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                SizedBox(width: 5),
                Text("View on Map", style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => updateSeenStatus(sos['sos_id'], "Seen"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                child: const Text("Seen", style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => updateSeenStatus(sos['sos_id'], "Not Seen"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Not Seen", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}