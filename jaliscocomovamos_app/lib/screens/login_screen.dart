import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart'; // Re-imported to use your custom AppColors

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Square box/Card with color from your palette
              Card(
                elevation: 4,
                color: AppColors.lime, // Uses one of your palette colors (#D5E14D)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText, // #003979
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo o Usuario',
                          filled: true,
                          fillColor: Colors.white, // White background for input contrast
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person, color: AppColors.primaryText),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          filled: true,
                          fillColor: Colors.white, // White background for input contrast
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock, color: AppColors.primaryText),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryText,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement login logic later
                        },
                        child: const Text('Iniciar sesión'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // "Entrar como invitado" button at the bottom
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    side: const BorderSide(color: AppColors.highlight, width: 2),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(Routes.shell);
                  },
                  child: const Text('Entrar como invitado'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}