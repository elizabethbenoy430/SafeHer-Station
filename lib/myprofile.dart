import 'package:flutter/material.dart';

class StationMyProfile extends StatelessWidget {
  const StationMyProfile({super.key});

  Widget infoTile(String title, IconData icon) {
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
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "--",
                style: TextStyle(
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF1E1E1E),
                child: Icon(
                  Icons.local_police, // 👮 POLICE STATION ICON
                  color: Colors.grey,
                  size: 40,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Police Station Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              infoTile("Station Name", Icons.local_police),
              infoTile("Email Address", Icons.email),
              infoTile("Contact Number", Icons.phone),
              infoTile("Address", Icons.location_on),
              infoTile("Latitude", Icons.my_location),
              infoTile("Longitude", Icons.explore),

              const SizedBox(height: 30),

              // EDIT PROFILE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Edit Profile
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "EDIT PROFILE",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
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
                    // TODO: Navigate to Change Password
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "CHANGE PASSWORD",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
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
