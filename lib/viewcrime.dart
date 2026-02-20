import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // 🔹 FETCH CRIME WITH USER NAME
  Future<void> fetchCrimes() async {
    try {
      final response = await supabase
          .from('tbl_crime')
          .select('*, tbl_user(user_name)') // JOIN
          .order('crime_id', ascending: false);

      setState(() {
        crimeList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching crimes: $e");
      setState(() => isLoading = false);
    }
  }

  // OPEN FILE
  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open file';
    }
  }

  // CRIME CARD UI
  Widget buildCrimeCard(dynamic crime, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SL NO
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.tealAccent,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ✅ USER NAME
                  Text(
                    "Reported by: ${crime['tbl_user']?['user_name'] ?? 'Unknown User'}",
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ✅ crime_details
                  Text(
                    crime['crime_details'] ?? "No Description",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),

                  const SizedBox(height: 6),

                  // ✅ crime_date
                  Text(
                    "Date: ${crime['crime_date'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  // ✅ crime_file
                  if (crime['crime_file'] != null && crime['crime_file'] != "")
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.attach_file),
                      label: const Text("View File"),
                      onPressed: () => openFile(crime['crime_file']),
                    )
                  else
                    const Text(
                      "No File Uploaded",
                      style: TextStyle(color: Colors.white54),
                    ),
                ],
              ),
            ),
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
        centerTitle: true,
        title: const Text(
          "Crime List",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : crimeList.isEmpty
              ? const Center(
                  child: Text("No Crime Records Found",
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crimeList.length,
                  itemBuilder: (context, index) {
                    return buildCrimeCard(crimeList[index], index);
                  },
                ),
    );
  }
}