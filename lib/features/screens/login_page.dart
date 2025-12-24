import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email dan Password harus diisi')));
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Format email tidak valid'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil Service Login
      await AuthService().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Login Berhasil!'),
          ),
        );

        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        String message = 'Gagal Login';
        // Pesan error yang lebih manusiawi
        if (e.toString().contains('user-not-found')) {
          message = 'Email tidak ditemukan. Silakan daftar dulu.';
        } else if (e.toString().contains('wrong-password')) {
          message = 'Password salah.';
        } else if (e.toString().contains('invalid-credential')) {
          message = 'Email atau Password salah.';
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
                    "Login",
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

            // Form Login
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
                    vertical: screenHeight * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang!",
                        style: TextStyle(
                          fontFamily: 'Gabarito',
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darker,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Masuk ke akun Anda untuk melanjutkan",
                        style: TextStyle(
                          fontFamily: "Gabarito",
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      // INPUT EMAIL
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // INPUT PASSWORD
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            if (_emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Masukkan email Anda terlebih dahulu untuk reset password',
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              await AuthService().resetPassword(
                                _emailController.text.trim(),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Link reset password telah dikirim ke email Anda!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Gagal mengirim link reset password. Pastikan email terdaftar.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // TOMBOL LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.light,
                                    fontFamily: 'Gabarito',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),
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
                          Icon(Icons.apple, size: 30),
                          SizedBox(width: 30),
                          Icon(Icons.facebook, color: Colors.blue, size: 30),
                          SizedBox(width: 30),
                          Image.asset(
                            "assets/icons/Google_logo.png",
                            width: 30,
                            height: 30,
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.08),

                      // FOOTER SIGN UP
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Belum punya akun? ",
                            style: TextStyle(
                              color: AppColors.darker,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: AppColors.normal,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push('/SignUpPage');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
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
}
