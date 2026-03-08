import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:station_app/main.dart';
import 'package:station_app/myprofile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StationEditProfile extends StatefulWidget {
  const StationEditProfile({super.key});

  @override
  State<StationEditProfile> createState() => _StationEditProfileState();
}

class _StationEditProfileState extends State<StationEditProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String oldemail = "";
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadStationData();
  }

  Future<void> loadStationData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_station')
          .select()
          .eq('station_id', userId)
          .single();

      setState(() {
        nameController.text = response['station_name'] ?? "";
        emailController.text = response['station_email'] ?? "";
        contactController.text = response['station_contact'] ?? "";
        addressController.text = response['station_address'] ?? "";
        oldemail = response['station_email'] ?? "";
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Load error: $e");
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isUpdating = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final newEmail = emailController.text.trim().toLowerCase();
      if (newEmail != oldemail.trim().toLowerCase()) {
        await supabase.auth.updateUser(UserAttributes(email: newEmail));
      }

      await supabase.from('tbl_station').update({
        'station_name': nameController.text.trim(),
        'station_email': newEmail,
        'station_contact': contactController.text.trim(),
        'station_address': addressController.text.trim(),
      }).eq('station_id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.greenAccent),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StationMyProfile()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update Failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  // ✅ GLASS INPUT STYLE
  InputDecoration _glassInputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.greenAccent, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
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
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/bgl.png", fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.75))),
          
          isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Glass Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.black26,
                                  child: Icon(Icons.edit_location_alt_outlined, color: Colors.greenAccent, size: 35),
                                ),
                                const SizedBox(height: 20),
                                const Text("Station Authorization", 
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 25),

                                TextFormField(
                                  controller: nameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputStyle("Station Name", Icons.account_balance_outlined),
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputStyle("Official Email", Icons.email_outlined),
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: contactController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputStyle("Contact Number", Icons.phone_outlined),
                                  validator: (v) => v!.length != 10 ? "Enter 10 digits" : null,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: addressController,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 2,
                                  decoration: _glassInputStyle("Full Address", Icons.map_outlined),
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: isUpdating ? null : updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.greenAccent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 0,
                                    ),
                                    child: isUpdating 
                                      ? const CircularProgressIndicator(color: Colors.black)
                                      : const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}