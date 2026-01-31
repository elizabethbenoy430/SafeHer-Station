import 'package:flutter/material.dart';
import 'homepage.dart'; // StationHome page

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

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StationHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B1B1B), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Top Wave Green (like User Login)
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 🔹 Login Form Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    const Icon(Icons.shield, color: Colors.white, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Station Officer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Manage alerts, complaints & safety efficiently",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: const TextStyle(color: Colors.grey),
                                prefixIcon:
                                    const Icon(Icons.email, color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: const TextStyle(color: Colors.grey),
                                prefixIcon:
                                    const Icon(Icons.lock, color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 🔴 Glowing Login Button
                            AnimatedGlowButton(onTap: _login),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Optional: Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialButton(Icons.facebook, Colors.blue),
                        const SizedBox(width: 20),
                        socialButton(Icons.g_mobiledata, Colors.red),
                      ],
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

  Widget socialButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {},
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
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 12).animate(
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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.6),
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 120),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height + 50, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
