import 'package:flutter/material.dart';

class StationRegistration extends StatefulWidget {
  const StationRegistration({super.key});

  @override
  State<StationRegistration> createState() => _StationRegistrationState();
}

class _StationRegistrationState extends State<StationRegistration> {
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

  void registerStation() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Station Registration Successful"),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    // TODO: Save to database / Firebase / API
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Police Icon
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1E1E1E),
                  child: Icon(
                    Icons.local_police,
                    color: Colors.lightBlueAccent,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Police Station Registration",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Station Name
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputStyle("Station Name", icon: Icons.local_police),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Station name required";
                          }
                          return null;
                        },
                        
                      ),

                      const SizedBox(height: 18),

                      // Email
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputStyle("Email Address", icon: Icons.email),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Contact
                      TextFormField(
                        controller: contactController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: _inputStyle("Contact Number", icon: Icons.phone),
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

                      // Address
                      TextFormField(
                        controller: addressController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: _inputStyle("Address", icon: Icons.location_on),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Address required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Latitude
                      TextFormField(
                        controller: latitudeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputStyle("Latitude", icon: Icons.my_location),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Latitude required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Longitude
                      TextFormField(
                        controller: longitudeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputStyle("Longitude", icon: Icons.explore),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Longitude required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: registerStation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Login Link
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to Login page
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.greenAccent),
                        ),
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
}
