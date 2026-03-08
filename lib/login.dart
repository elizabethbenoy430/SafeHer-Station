import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:station_app/main.dart';
import 'package:station_app/stationregistration.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage.dart'; 
import 'stationregistration.dart'; // ✅ Ensure this points to your registration file

class StationLoginPage extends StatefulWidget {
  const StationLoginPage({super.key});

  @override
  State<StationLoginPage> createState() => _StationLoginPageState();
}

class _StationLoginPageState extends State<StationLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StationHome()),
          );
        }
      } else {
        showError("Login failed - No session created");
      }
    } catch (e) {
      if (e is AuthException) {
        showError(e.message);
      } else {
        showError("An unexpected error occurred.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/bgl.png",
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. 🔹 Dark Tint Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          // 3. 🔹 Semi-Transparent Top Wave
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.7),
                    const Color(0xFF81C784).withOpacity(0.4)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 4. 🔹 Glassmorphic Login Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Shield Icon with Glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 80),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "OFFICER LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      "Authorized Personnel Only",
                      style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1),
                    ),
                    const SizedBox(height: 35),

                    // --- GLASS CARD ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _emailController,
                                  label: "Station Email",
                                  icon: Icons.badge_outlined,
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: "Access Code",
                                  icon: Icons.lock_open_rounded,
                                  isPassword: true,
                                  validator: (v) => v!.length < 6 ? "Invalid Code" : null,
                                ),
                                const SizedBox(height: 30),
                                
                                // 🔴 Glowing Login Button
                                _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.greenAccent)
                                  : AnimatedGlowButton(onTap: login),

                                const SizedBox(height: 20),

                                // ✅ REDIRECT TO REGISTRATION
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const StationRegistration()),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      children: [
                                        const TextSpan(text: "Don't have an account? "),
                                        TextSpan(
                                          text: "Create One",
                                          style: TextStyle(
                                            color: Colors.greenAccent.withOpacity(0.9),
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    const Text(
                      "Emergency Response & Monitoring System",
                      style: TextStyle(color: Colors.white24, fontSize: 11),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.greenAccent.withOpacity(0.7), size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ) 
          : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 1),
        ),
      ),
    );
  }
}

// 🔴 Glowing Login Button
class AnimatedGlowButton extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedGlowButton({required this.onTap, super.key});

  @override
  State<AnimatedGlowButton> createState() => _AnimatedGlowButtonState();
}

class _AnimatedGlowButtonState extends State<AnimatedGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 5, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: _animation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text(
              "AUTHENTICATE",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
        );
      },
    );
  }
}

// 🔹 Top Wave Clipper
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width / 2, size.height + 40, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}