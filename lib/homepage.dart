import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:station_app/myprofile.dart';
import 'package:station_app/viewcrime.dart';
import 'package:station_app/login.dart';

class StationHome extends StatelessWidget {
  const StationHome({super.key});

  // ✅ UPDATED GLASS FEATURE CARD
  Widget featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color accentColor = const Color(0xFF1976D2),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 26),
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
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.3), size: 14),
                ],
              ),
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
        centerTitle: true,
        title: const Text(
          "SafeHer Station",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const StationLoginPage()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. 🔹 BACKGROUND
          Positioned.fill(
            child: Image.asset("assets/bgl.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),

          // 2. 🔹 CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Officer,",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Station active status: Online",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Quick Stats Row (Optional addition for professional look)
                  Row(
                    children: [
                      _quickStat("Active SOS", "03", Colors.orangeAccent),
                      const SizedBox(width: 15),
                      _quickStat("Pending", "12", Colors.blueAccent),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "CORE MANAGEMENT",
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 15),

                  // FEATURE CARDS
                  featureCard(
                    icon: Icons.notifications_active_outlined,
                    title: "Incoming SOS Alerts",
                    subtitle: "Respond to real-time emergencies",
                    accentColor: Colors.orangeAccent,
                    onTap: () {}, // Add navigation
                  ),
                  featureCard(
                    icon: Icons.assignment_late_outlined,
                    title: "Complaints",
                    subtitle: "Review and assign cases",
                    accentColor: Colors.blueAccent,
                    onTap: () {},
                  ),
                  featureCard(
                    icon: Icons.gavel_rounded,
                    title: "Crime Records",
                    subtitle: "Detailed incident analysis",
                    accentColor: Colors.tealAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCrime())),
                  ),
                  featureCard(
                    icon: Icons.analytics_outlined,
                    title: "Statistics",
                    subtitle: "Safety trends and data logs",
                    accentColor: Colors.purpleAccent,
                    onTap: () {},
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔽 BOTTOM NAVIGATION
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            backgroundColor: Colors.white.withOpacity(0.05),
            selectedItemColor: Colors.greenAccent,
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) {
              if (index == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCrime()));
              } else if (index == 4) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StationMyProfile()));
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "SOS"),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Inbox"),
              BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Records"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}