import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:station_app/heic.dart';

class ViewCrime extends StatefulWidget {
  const ViewCrime({super.key});

  @override
  State<ViewCrime> createState() => _ViewCrimeState();
}

class _ViewCrimeState extends State<ViewCrime> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<dynamic> crimeList = [];
  bool isLoading = true;

  double? stationLat;
  double? stationLng;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchStationLocation();
    await fetchCrimes();
  }

  /// ✅ Get station location
  Future<void> fetchStationLocation() async {
    try {
      final user = supabase.auth.currentUser;

      final response = await supabase
          .from('tbl_station')
          .select('station_lantitude, station_longitude')
          .eq('station_id', user!.id)
          .single();

      stationLat =
          double.tryParse(response['station_lantitude'].toString());
      stationLng =
          double.tryParse(response['station_longitude'].toString());
    } catch (e) {
      debugPrint("Station location error: $e");
    }
  }

  /// ✅ Distance Formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;

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

  /// ✅ Fetch + filter crimes
  Future<void> fetchCrimes() async {
    try {
      if (stationLat == null || stationLng == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await supabase
          .from('tbl_crime')
          .select()
          .order('crime_date', ascending: false);

      List<Map<String, dynamic>> filteredList = [];

      for (var crime in response) {
        if (crime['crime_latitude'] != null &&
            crime['crime_longitude'] != null) {
          double lat =
              double.tryParse(crime['crime_latitude'].toString()) ?? 0;
          double lng =
              double.tryParse(crime['crime_longitude'].toString()) ?? 0;

          double distance =
              calculateDistance(stationLat!, stationLng!, lat, lng);

          if (distance <= 5) {
            crime['distance'] = distance;
            filteredList.add(Map<String, dynamic>.from(crime));
          }
        }
      }

      filteredList.sort(
          (a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        crimeList = filteredList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching crimes: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final Uri url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    await launchUrl(url);
  }

  Widget buildCrimeCard(dynamic crime, int index) {
    String? fileUrl = crime['crime_file'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.tealAccent,
                child: Text("${index + 1}",
                    style: const TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crime['crime_details'] ?? "",
                        style: const TextStyle(color: Colors.white)),
                    Text("Date: ${crime['crime_date']}",
                        style: const TextStyle(color: Colors.white60)),
                    Text(
                      "Distance: ${crime['distance'].toStringAsFixed(2)} km",
                      style:
                          const TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 📍 Map button
          TextButton(
            onPressed: () => openMap(
              double.parse(crime['crime_latitude'].toString()),
              double.parse(crime['crime_longitude'].toString()),
            ),
            child: const Text("View Location"),
          ),

          /// 🖼 File Preview
          if (fileUrl != null && fileUrl.isNotEmpty)
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(fileUrl)),
              child: HeicImage(imageUrl: fileUrl),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Nearby Crimes"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : crimeList.isEmpty
              ? const Center(
                  child: Text("No Nearby Crimes",
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crimeList.length,
                  itemBuilder: (context, index) =>
                      buildCrimeCard(crimeList[index], index),
                ),
    );
  }
}