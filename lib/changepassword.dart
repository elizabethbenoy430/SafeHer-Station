import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:station_app/main.dart';

class StationChangePassword extends StatefulWidget {
  const StationChangePassword({super.key});

  @override
  State<StationChangePassword> createState() => _StationChangePasswordState();
}

class _StationChangePasswordState extends State<StationChangePassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

  bool _oldObscure = true;
  bool _newObscure = true;
  bool _retypeObscure = true;
  bool isUpdating = false;

  // Password validation: Min 8 chars, 1 capital, 1 number
  bool isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  // ✅ GLASS INPUT STYLE
  InputDecoration _glassInputStyle(String label, IconData icon, Widget? suffix) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.greenAccent, size: 20),
      suffixIcon: suffix,
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
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Future<String?> getDbPassword() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('tbl_station')
        .select('station_password')
        .eq('station_id', userId)
        .single();
    return response['station_password'];
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUpdating = true);

    try {
      final userId = supabase.auth.currentUser!.id;
      final dbPassword = await getDbPassword();

      if (dbPassword != oldPasswordController.text.trim()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect old password"), backgroundColor: Colors.redAccent),
          );
        }
        setState(() => isUpdating = false);
        return;
      }

      await supabase
          .from('tbl_station')
          .update({'station_password': retypePasswordController.text.trim()})
          .eq('station_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password Updated Successfully"), backgroundColor: Colors.greenAccent),
        );
        Navigator.pop(context);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: const Text("Security", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/bgl.png", fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.8))),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.lock_reset_rounded, color: Colors.greenAccent, size: 70),
                    const SizedBox(height: 10),
                    const Text("Change Password", 
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("Keep your station access secure", 
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 30),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // OLD PASSWORD
                                TextFormField(
                                  controller: oldPasswordController,
                                  obscureText: _oldObscure,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputStyle("Current Password", Icons.lock_outline, 
                                    IconButton(
                                      icon: Icon(_oldObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                                      onPressed: () => setState(() => _oldObscure = !_oldObscure),
                                    )
                                  ),
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 15),

                                // NEW PASSWORD
                                TextFormField(
                                  controller: newPasswordController,
                                  obscureText: _newObscure,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputStyle("New Password", Icons.vpn_key_outlined, 
                                    IconButton(
                                      icon: Icon(_newObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                                      onPressed: () => setState(() => _newObscure = !_newObscure),
                                    )
                                  ),
                                  validator: (v) => !isValidPassword(v!) ? "8+ chars, 1 Capital, 1 Number" : null,
                                ),
                                const SizedBox(height: 15),

                                // RETYPE PASSWORD
                                TextFormField(
                                  controller: retypePasswordController,
                                  obscureText: _retypeObscure,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputStyle("Confirm New Password", Icons.repeat_rounded, 
                                    IconButton(
                                      icon: Icon(_retypeObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                                      onPressed: () => setState(() => _retypeObscure = !_retypeObscure),
                                    )
                                  ),
                                  validator: (v) => v != newPasswordController.text ? "Passwords don't match" : null,
                                ),
                                const SizedBox(height: 30),

                                // UPDATE BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: isUpdating ? null : changePassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.greenAccent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: isUpdating 
                                      ? const CircularProgressIndicator(color: Colors.black)
                                      : const Text("UPDATE PASSWORD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
          ),
        ],
      ),
    );
  }
}