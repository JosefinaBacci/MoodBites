import 'package:flutter/material.dart';
import '../presenter/login_presenter.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formLogInKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final passController = TextEditingController();
  final presenter = LoginPresenter();
  bool rememberPassword = true;

  void _login() async {
    if (_formLogInKey.currentState!.validate()) {
      try {
        final user = await presenter.login(
          userController.text,
          passController.text,
        );
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  }

  void _register() async {
    if (_formLogInKey.currentState!.validate()) {
      try {
        final user = await presenter.register(
          userController.text,
          passController.text,
        );
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registration failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DADC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF011C45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to MoodBites!',
                    style: TextStyle(fontSize: 20, color: Color(0xFF011C45)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/robotHandFront.png', height: 160),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF2E3D59),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formLogInKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: userController,
                      cursorColor: const Color(0xFF3B4D65),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter username";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "User",
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(153, 59, 77, 101),
                        ),
                        filled: true,
                        fillColor: Color(0xFFD3DADC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: passController,
                      cursorColor: const Color(0xFF2E3D59),
                      obscureText: true,
                      obscuringCharacter: "*",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(153, 59, 77, 101),
                        ),
                        filled: true,
                        fillColor: Color(0xFFD3DADC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberPassword,
                              onChanged: (bool? value) {
                                setState(() {
                                  rememberPassword = value ?? false;
                                });
                              },
                              activeColor: Colors.lightBlueAccent,
                            ),
                            const Text(
                              "Remember me",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const Text(
                          'forgot password?',
                          style: TextStyle(color: Colors.lightBlueAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB6E7F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        'or login with',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialIcon('assets/images/facebook.png'),
                        _buildSocialIcon('assets/images/google.png'),
                        _buildSocialIcon('assets/images/apple.png'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New here? ',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: _register,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String path) {
    return Container(
      width: 55,
      height: 55,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFD3DADC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(path),
    );
  }
}
