import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ IMPORTANT
import 'package:station_app/login.dart';
import 'package:station_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 70),
              const SizedBox(height: 20),
              const Text(
                "Registration Completed!",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Check your email to verify your account.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => StationLoginPage()),
                    );
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user == null) throw "Registration failed";

      await supabase.from('tbl_station').insert({
        'station_id': res.user!.id,
        'station_name': nameController.text.trim(),
        'station_email': email,
        'station_contact': contactController.text.trim(), // ✅ FIXED
        'station_password': password,
        'station_address': addressController.text.trim(),
        'station_lantitude': latitudeController.text.trim(),
        'station_longitude': longitudeController.text.trim(),
        'station_status': 'pending',
      });

      if (mounted) _showSuccessDialog();
    } catch (e) {
      _showError(e.toString());
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    passwordController.dispose();
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
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1E1E1E),
                  child: Icon(Icons.local_police, color: Colors.lightBlueAccent, size: 50),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Police Station Registration",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                        validator: (v) => v == null || v.isEmpty ? "Station name required" : null,
                      ),

                      const SizedBox(height: 18),

                      // Email
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputStyle("Email Address", icon: Icons.email),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Email required";
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Contact (ONLY 10 DIGITS)
                      TextFormField(
                        controller: contactController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: _inputStyle("Contact Number", icon: Icons.phone),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Contact number required";
                          if (value.length != 10) return "Enter exactly 10 digits";
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
                        validator: (v) => v == null || v.isEmpty ? "Address required" : null,
                      ),

                      const SizedBox(height: 18),

                      // Latitude
                      TextFormField(
                        controller: latitudeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputStyle("Latitude", icon: Icons.my_location),
                        validator: (v) => v == null || v.isEmpty ? "Latitude required" : null,
                      ),

                      const SizedBox(height: 18),

                      // Longitude
                      TextFormField(
                        controller: longitudeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputStyle("Longitude", icon: Icons.explore),
                        validator: (v) => v == null || v.isEmpty ? "Longitude required" : null,
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD FIELD (STRONG VALIDATION)
                      TextFormField(
                        controller: passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: !_showPassword,
                        decoration: _inputStyle("Password", icon: Icons.lock).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Password required";
                          if (value.length < 8) return "Minimum 8 characters required";
                          if (!RegExp(r'[A-Z]').hasMatch(value)) return "Add one uppercase letter";
                          if (!RegExp(r'[a-z]').hasMatch(value)) return "Add one lowercase letter";
                          if (!RegExp(r'[0-9]').hasMatch(value)) return "Add one number";
                          if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) return "Add one special character";
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                                  "REGISTER",
                                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => StationLoginPage()));
                        },
                        child: const Text("Already have an account? Login", style: TextStyle(color: Colors.greenAccent)),
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
