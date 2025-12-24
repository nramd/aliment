import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk layout yang responsif
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: screenSize * 0.15,
        child: AppBar(
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/back_button.png",
              width: 36,
              height: 36,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          backgroundColor: AppColors.normal,
          flexibleSpace: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 130.0),
              child: Text(
                "Login",
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.normal),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 15),
                  child: Text(
                    "Selamat Datang!",
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darker,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "Masuk ke akun Anda untuk melanjutkan",
                    style: TextStyle(
                      fontFamily: "Gabarito",
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility_off),
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.normal, fontSize: 11),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkActive,
                      minimumSize: Size(343, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.light,
                        fontFamily: 'Gabarito',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: Text(
                    "Atau lanjut dengan",
                    style: TextStyle(color: AppColors.normal, fontSize: 11),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.apple, size: 30),
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.facebook, color: Colors.blue, size: 30),
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/icons/Google_logo.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 100),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Belum punya akun? ",
                      style: TextStyle(color: AppColors.darker, fontSize: 11),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            color: AppColors.normal,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.normal,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
