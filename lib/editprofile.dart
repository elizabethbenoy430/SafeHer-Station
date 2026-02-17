import 'package:flutter/material.dart';

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
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

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

  void updateProfile() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated Successfully"),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

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

                    // LATITUDE
                    TextFormField(
                      controller: latitudeController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputStyle(
                        "Latitude",
                        icon: Icons.my_location,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Latitude required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // LONGITUDE
                    TextFormField(
                      controller: longitudeController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputStyle("Longitude", icon: Icons.explore),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Longitude required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),

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
