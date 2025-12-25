import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mohon lengkapi semua data')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String fullName =
          "${_firstNameController.text} ${_lastNameController.text}".trim();

      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: fullName,
        username: _firstNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Akun berhasil dibuat!'),
          ),
        );
        context.go('/loginPage');
      }
    } catch (e) {
      if (mounted) {
        String message = 'Gagal daftar';
        if (e.toString().contains('email-already-in-use')) {
          message = 'Email sudah terdaftar. Silakan login.';
        } else if (e.toString().contains('weak-password')) {
          message = 'Password terlalu lemah (min. 6 karakter).';
        } else {
          message = 'Gagal daftar: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.normal,
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.06,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset(
                      "assets/icons/back_button.png",
                      width: 36,
                      height: 36,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Daftar",
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Isi Form
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.82,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: screenHeight * 0.03, // Padding vertikal responsif
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buat Akun",
                        style: TextStyle(
                          fontFamily: 'Gabarito',
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darker,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ), // Jarak responsif 1% layar
                      Text(
                        "Daftarkan akun Anda untuk mengakses aplikasi",
                        style: TextStyle(
                          fontFamily: "Gabarito",
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // FORM INPUT
                      _buildTextField(
                        controller: _firstNameController,
                        label: "Nama Awal",
                        icon: Icons.person,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      _buildTextField(
                        controller: _lastNameController,
                        label: "Nama Akhir",
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // TOMBOL Sign Up
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkActive,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: AppColors.light,
                                )
                              : Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.light,
                                    fontFamily: 'Gabarito',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      Center(
                        child: Text(
                          "Atau lanjut dengan",
                          style: TextStyle(
                            color: AppColors.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // SOCIAL LOGIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(Icons.apple, Colors.black),
                          SizedBox(width: 30),
                          _socialButton(Icons.facebook, Colors.blue),
                          SizedBox(width: 30),
                          InkWell(
                            onTap: () {},
                            child: Image.asset(
                              "assets/icons/Google_logo.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: screenHeight * 0.04,
                      ), // Jarak bawah agar tidak mepet
                      // FOOTER
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Sudah punya akun? ",
                            style: TextStyle(
                              color: AppColors.darker,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: AppColors.normal,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push('/loginPage');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ), // Extra padding aman untuk HP poni/gesture bar
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, size: 30, color: color),
    );
  }
}
