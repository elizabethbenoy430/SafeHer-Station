import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final supabase = Supabase.instance.client;

  int sosCount = 0;
  int crimeCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final sos = await supabase
          .from('tbl_sos')
          .select()
          .count(CountOption.exact);

      final crime = await supabase
          .from('tbl_crime')
          .select()
          .count(CountOption.exact);

      setState(() {
        sosCount = sos.count;
        crimeCount = crime.count;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget statCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.green[900]!.withOpacity(0.8),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.greenAccent),
          const SizedBox(height: 10),
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (sosCount > crimeCount ? sosCount : crimeCount).toDouble() + 5,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                  toY: sosCount.toDouble(),
                  width: 40,
                  color: Colors.greenAccent)
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                  toY: crimeCount.toDouble(),
                  width: 40,
                  color: Colors.redAccent)
            ],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text("SOS", style: TextStyle(color: Colors.white70));
                  case 1:
                    return const Text("Crime", style: TextStyle(color: Colors.white70));
                }
                return const Text("");
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) {
              return Text(val.toInt().toString(), style: const TextStyle(color: Colors.white70));
            }),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white12, strokeWidth: 1),
        ),
      ),
    );
  }

  Widget buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: sosCount.toDouble(),
            title: "SOS\n$sosCount",
            radius: 70,
            color: Colors.greenAccent,
            titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: crimeCount.toDouble(),
            title: "Crime\n$crimeCount",
            radius: 70,
            color: Colors.redAccent,
            titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
        sectionsSpace: 10,
        centerSpaceRadius: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bgl.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          // Content
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: statCard("SOS Sent", sosCount, Icons.warning),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: statCard("Crime Reports", crimeCount, Icons.gavel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Activity Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(height: 200, child: buildBarChart()),
                        const SizedBox(height: 30),
                        const Text(
                          "Activity Distribution",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(height: 200, child: buildPieChart()),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}