import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:station_app/heic.dart'; // Add this

class ViewCrime extends StatefulWidget {
  const ViewCrime({super.key});

  @override
  State<ViewCrime> createState() => _ViewCrimeState();
}

class _ViewCrimeState extends State<ViewCrime> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> crimeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCrimes();
  }

  Future<void> fetchCrimes() async {
    try {
      final response = await supabase.from('tbl_crime').select().order('crime_date', ascending: false);
      setState(() {
        crimeList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching crimes: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open file');
    }
  }

  Widget buildCrimeCard(dynamic crime, int index) {
    String? fileUrl = crime['crime_file'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF3B3654)], // Darker, cleaner gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.tealAccent,
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crime['crime_details'] ?? "No Description",
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Date: ${crime['crime_date'] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // --- IMAGE PREVIEW SECTION ---
            if (fileUrl != null && fileUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black26,
                  child: GestureDetector(
                    onTap: () => openFile(fileUrl),
                    child: HeicImage(imageUrl: fileUrl),
                  ),
                ),
              )
            else
              const Text("No File Uploaded", style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Crime Records", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : crimeList.isEmpty
              ? const Center(child: Text("No Records Found", style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crimeList.length,
                  itemBuilder: (context, index) => buildCrimeCard(crimeList[index], index),
                ),
    );
  }
}



