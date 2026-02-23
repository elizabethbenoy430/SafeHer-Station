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
      final oldEmail = oldemail.trim().toLowerCase();
      bool emailChanged = newEmail != oldEmail;

      // 1. Update Auth Email
      // Since confirmation is OFF, this will update the email immediately in Supabase Auth
      if (emailChanged) {
        await supabase.auth.updateUser(UserAttributes(email: newEmail));
      }

      // 2. Update the database table (tbl_station)
      await supabase
          .from('tbl_station')
          .update({
            'station_name': nameController.text.trim(),
            'station_email': newEmail,
            'station_contact': contactController.text.trim(),
            'station_address': addressController.text.trim(),
          })
          .eq('station_id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile and Auth Email updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StationMyProfile()),
      );
    } catch (e) {
      debugPrint("Update error: $e");
      String errorMessage = e is AuthApiException ? e.message : e.toString();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update Failed: $errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  InputDecoration _inputStyle(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();

    super.dispose();
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
          "Edit Station Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 👮 POLICE STATION ICON
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_police,
                        size: 45,
                        color: Color(0xFF4CAF50),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Update Police Station Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Edit your police station information below",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // STATION NAME
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputStyle(
                        "Station Name",
                        icon: Icons.account_balance,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Station name required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // EMAIL
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle(
                        "Email Address",
                        icon: Icons.email,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                        ).hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CONTACT
                    TextFormField(
                      controller: contactController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: _inputStyle(
                        "Contact Number",
                        icon: Icons.phone,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Contact number required";
                        }
                        if (value.length != 10) {
                          return "Enter valid 10 digit number";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ADDRESS
                    TextFormField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _inputStyle(
                        "Address",
                        icon: Icons.location_on,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Address required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // UPDATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "UPDATE PROFILE",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
