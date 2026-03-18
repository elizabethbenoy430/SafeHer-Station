import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:station_app/login.dart'; // Ensure this matches your login file name
import 'package:station_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  // ✅ GLASS INPUT STYLE
  InputDecoration _glassInputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.greenAccent, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 1),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
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

  // ✅ REGISTRATION LOGIC
 Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 🔹 Create auth user
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw "Registration failed";
    }

    // 🔹 Request Location Permissions first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Location permissions are denied by the user.";
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw "Location permissions are permanently denied. Please enable them in app settings.";
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 🔹 Insert station details
    await supabase.from('tbl_station').insert({
      'station_id': res.user!.id,
      'station_name': nameController.text.trim(),
      'station_email': email,
      'station_contact': contactController.text.trim(),
      'station_address': addressController.text.trim(),
      'station_lantitude': position.latitude,
      'station_longitude': position.longitude,
      'station_password': passwordController.text.trim(),
      'station_status': 'pending',
    });

    if (mounted) {
      _showSuccessDialog();
    }

  } catch (e) {
    print("Registration error: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // ✅ SUCCESS DIALOG
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user, color: Colors.greenAccent, size: 60),
              const SizedBox(height: 20),
              const Text("Station Registered",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                  "Your registration is pending. Please check your email to verify your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const StationLoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text("GO TO LOGIN",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Layer
          Positioned.fill(
            child: Image.asset("assets/bgl.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),

          // 2. Content Layer
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.security_outlined, color: Colors.greenAccent, size: 60),
                  const SizedBox(height: 15),
                  const Text("Station Enrollment",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const Text("Register your station to the SafeHer network",
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 30),

                  // Frosted Glass Form Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputStyle("Station Name", Icons.local_police_outlined),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputStyle("Official Email", Icons.email_outlined),
                                validator: (v) => !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v!)
                                    ? "Invalid email"
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: contactController,
                                style: const TextStyle(color: Colors.white),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                decoration: _glassInputStyle("Contact Number", Icons.phone_outlined),
                                validator: (v) => v!.length != 10 ? "10 digits required" : null,
                              ),
                              const SizedBox(height: 15),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: addressController,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 2,
                                decoration: _glassInputStyle("Station Address", Icons.map_outlined),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: !_showPassword,
                                decoration: _glassInputStyle("Password", Icons.lock_outline).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white54, size: 20),
                                    onPressed: () => setState(() => _showPassword = !_showPassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v!.length < 8) return "8+ characters required";
                                  if (!RegExp(r'[A-Z]').hasMatch(v)) return "Needs uppercase";
                                  if (!RegExp(r'[0-9]').hasMatch(v)) return "Needs a number";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              
                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.greenAccent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.black)
                                      : const Text("ENROLL STATION",
                                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ),
                              ),
                              const SizedBox(height: 15),
                              
                              // ✅ BACK TO LOGIN BUTTON
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StationLoginPage()),
                                  );
                                },
                                child: const Text("Already have an account? Login",
                                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}