import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:station_app/myprofile.dart';
import 'package:station_app/statistics.dart';
import 'package:station_app/viewcrime.dart';
import 'package:station_app/login.dart';
import 'package:station_app/viewsosactivity.dart';

class StationHome extends StatefulWidget {
  const StationHome({super.key});

  @override
  State<StationHome> createState() => _StationHomeState();
}

class _StationHomeState extends State<StationHome> {
  int totalSOS = 0;
  int totalCrimes = 0;
  bool loading = true;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      final sos = await supabase.from('tbl_sos').select();
      final crimes = await supabase.from('tbl_crime').select();
      
      setState(() {
        totalSOS = sos.length;
        totalCrimes = crimes.length;
        loading = false;
      });
    } catch (e) {
      print("Error fetching counts: $e");
      setState(() => loading = false);
    }
  }

  // ✅ FEATURE CARD
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

  Widget _quickStat(String label, int value, Color color) {
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
            Text(value.toString(),
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
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
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
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
          // 🔹 Background
          Positioned.fill(
            child: Image.asset("assets/bgl.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),

          // 🔹 Content
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
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),

                  // Quick Stats Row
                  loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.greenAccent),
                        )
                      : Row(
                          children: [
                            _quickStat("Total SOS", totalSOS, Colors.orangeAccent),
                            const SizedBox(width: 15),
                            _quickStat("Total Crimes", totalCrimes, Colors.redAccent),
                          ],
                        ),

                  const SizedBox(height: 30),
                  const Text(
                    "CORE MANAGEMENT",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 15),

                  // FEATURE CARDS
                  featureCard(
                    icon: Icons.notifications_active_outlined,
                    title: "View SOS Alerts",
                    subtitle: "Review SOS activity",
                    accentColor: Colors.orangeAccent,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ViewSOSActivity())),
                  ),
                  featureCard(
                    icon: Icons.gavel_rounded,
                    title: "Crime Records",
                    subtitle: "Detailed incident analysis",
                    accentColor: Colors.tealAccent,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ViewCrime())),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
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
              if(index==2)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewSOSActivity()));
              else if (index == 3)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCrime()));
              else if (index == 4)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StationMyProfile()));
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "SOS Activity"),
              BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Records"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}