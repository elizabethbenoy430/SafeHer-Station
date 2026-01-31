import 'package:flutter/material.dart';

class StationChangePassword extends StatefulWidget {
  const StationChangePassword({super.key});

  @override
  State<StationChangePassword> createState() =>
      _StationChangePasswordState();
}

class _StationChangePasswordState
    extends State<StationChangePassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController =
      TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();

  bool hideOld = true;
  bool hideNew = true;
  bool hideRetype = true;

  InputDecoration _inputStyle(String hint,
      {IconData? icon,
      bool obscure = true,
      VoidCallback? toggle}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon:
          icon != null ? Icon(icon, color: Colors.grey) : null,
      suffixIcon: toggle != null
          ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggle,
            )
          : null,
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      errorStyle:
          const TextStyle(color: Colors.redAccent),
    );
  }

  void changePassword() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password Changed Successfully"),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    oldPasswordController.clear();
    newPasswordController.clear();
    retypePasswordController.clear();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    retypePasswordController.dispose();
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
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24),
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

                    // 🔐 ICON IMAGE
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 45,
                        color: Color(0xFF4CAF50),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Update Your Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Make sure your new password is strong",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // OLD PASSWORD
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: hideOld,
                      style:
                          const TextStyle(color: Colors.white),
                      decoration: _inputStyle(
                        "Old Password",
                        icon: Icons.lock_outline,
                        obscure: hideOld,
                        toggle: () {
                          setState(() {
                            hideOld = !hideOld;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return "Old password required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // NEW PASSWORD
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: hideNew,
                      style:
                          const TextStyle(color: Colors.white),
                      decoration: _inputStyle(
                        "New Password",
                        icon: Icons.lock,
                        obscure: hideNew,
                        toggle: () {
                          setState(() {
                            hideNew = !hideNew;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return "New password required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // RETYPE PASSWORD
                    TextFormField(
                      controller:
                          retypePasswordController,
                      obscureText: hideRetype,
                      style:
                          const TextStyle(color: Colors.white),
                      decoration: _inputStyle(
                        "Retype New Password",
                        icon: Icons.lock_reset,
                        obscure: hideRetype,
                        toggle: () {
                          setState(() {
                            hideRetype = !hideRetype;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return "Please retype password";
                        }
                        if (value !=
                            newPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF4CAF50),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "UPDATE PASSWORD",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
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
