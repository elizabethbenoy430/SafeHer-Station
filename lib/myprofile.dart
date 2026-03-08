import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:station_app/changepassword.dart';
import 'package:station_app/editprofile.dart';
import 'package:station_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StationMyProfile extends StatefulWidget {
  const StationMyProfile({super.key});

  @override
  State<StationMyProfile> createState() => _StationMyProfileState();
}

class _StationMyProfileState extends State<StationMyProfile> {
  Map<String, dynamic>? stationData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStationDetails();
  }

  Future<void> fetchStationDetails() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('tbl_station')
          .select()
          .eq('station_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        stationData = response;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  // ✅ GLASS INFO TILE
  Widget infoTile(String title, String? value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.greenAccent, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(
                        value ?? "Not Set",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Station Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. 🔹 BACKGROUND
          Positioned.fill(
            child: Image.asset("assets/bgl.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          // 2. 🔹 CONTENT
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
              : stationData == null
                  ? const Center(child: Text("❌ No Data Found", style: TextStyle(color: Colors.white)))
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // PROFILE HEADER
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 2),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.black45,
                                      child: Icon(Icons.shield_rounded, color: Colors.greenAccent, size: 50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              stationData!['station_name']?.toUpperCase() ?? "POLICE STATION",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w900),
                            ),
                            const Text(
                              "AUTHORIZED STATION PROFILE",
                              style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 40),

                            // DETAILS TILES
                            infoTile("OFFICIAL NAME", stationData!['station_name'], Icons.badge_outlined),
                            infoTile("EMAIL ADDRESS", stationData!['station_email'], Icons.alternate_email),
                            infoTile("CONTACT LINE", stationData!['station_contact'], Icons.phone_in_talk_outlined),
                            infoTile("LOCATION", stationData!['station_address'], Icons.map_outlined),
                            
                            // Coordinates Row
                            Row(
                              children: [
                                Expanded(child: infoTile("LAT", stationData!['station_lantitude'], Icons.location_on)),
                                const SizedBox(width: 10),
                                Expanded(child: infoTile("LONG", stationData!['station_longitude'], Icons.explore)),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // BUTTONS
                            ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StationEditProfile())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: const Text("EDIT STATION DETAILS", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),

                            const SizedBox(height: 15),

                            OutlinedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StationChangePassword())),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("CHANGE PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}