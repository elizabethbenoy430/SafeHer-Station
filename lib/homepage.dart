import 'package:flutter/material.dart';
import 'package:station_app/myprofile.dart';
import 'package:station_app/viewcrime.dart';
import 'package:station_app/login.dart';


class StationHome extends StatelessWidget {
  const StationHome({super.key});

  // FEATURE CARD
  Widget featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shield, color: Color(0xFF1976D2), size: 22),
            SizedBox(width: 6),
            Text(
              "SafeHer Station",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,

        // 🔴 LOGOUT BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const StationLoginPage()),
                (route) => false,
              );
            },
          )
        ],
      ),

      // 🧍 STATION HOME CONTENT
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Welcome Station Officer ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Manage alerts, complaints & safety efficiently",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // FEATURE CARDS
              featureCard(
                icon: Icons.warning,
                title: "Incoming SOS Alerts",
                subtitle: "View and respond to active SOS requests",
              ),
              const SizedBox(height: 16),
              featureCard(
                icon: Icons.report,
                title: "Complaints",
                subtitle: "View and manage user complaints",
              ),
              const SizedBox(height: 16),
              featureCard(
                icon: Icons.assessment,
                title: "Statistics",
                subtitle: "View safety reports and data analytics",
              ),
              const SizedBox(height: 16),
              featureCard(
                icon: Icons.history,
                title: "Incident History",
                subtitle: "Check past SOS and complaint records",
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // 🔽 BOTTOM NAVIGATION WITH PAGE REDIRECT
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 0) {
            // Home - do nothing
          } 
          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationHome()),
            );
          } 
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationHome()),
            );
          } 
          else if (index == 3) {
            // ✅ CRIME PAGE
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewCrime()),
            );
          } 
          else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationMyProfile()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "SOS"),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: "Complaints"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Crime"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// 🔵 STATION PROFILE PAGE
class StationProfilePage extends StatelessWidget {
  const StationProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Station Profile"),
      ),
      body: const Center(
        child: Text(
          "Station Profile Page",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}