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

  // 🔹 FETCH STATION DATA
  Future<void> fetchStationDetails() async {
    try {
      final response = await supabase
          .from('tbl_station') // ✅ Correct table name
          .select()
          .eq('station_id', supabase.auth.currentUser!.id)
          .single(); // Get only one row

      if (!mounted) return;

      setState(() {
        stationData = response;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // 🔹 PROFILE TILE WIDGET
  Widget infoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Station Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      // 🔹 BODY
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : stationData == null
              ? const Center(
                  child: Text("No Station Data Found",
                      style: TextStyle(color: Colors.white)))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // PROFILE ICON
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFF1E1E1E),
                          child: Icon(
                            Icons.local_police,
                            color: Colors.greenAccent,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          stationData!['station_name'] ?? "Police Station",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // DETAILS
                        infoTile("Station Name", stationData!['station_name'] ?? "N/A",
                            Icons.local_police),
                        infoTile("Email Address", stationData!['station_email'] ?? "N/A",
                            Icons.email),
                        infoTile("Contact Number",
                            stationData!['station_contact'] ?? "N/A", Icons.phone),
                        infoTile("Address", stationData!['station_address'] ?? "N/A",
                            Icons.location_on),
                        infoTile("Latitude",
                            stationData!['station_lantitude'] ?? "N/A", Icons.my_location),
                        infoTile("Longitude",
                            stationData!['station_longitude'] ?? "N/A", Icons.explore),
     

                        const SizedBox(height: 30),

                        // EDIT PROFILE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => StationEditProfile(),));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text(
                              "EDIT PROFILE",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // CHANGE PASSWORD BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => StationChangePassword(),));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4CAF50)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text(
                              "CHANGE PASSWORD",
                              style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
    );
  }
}
