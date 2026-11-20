import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';

// Paso 1 del login: pedir el correo electrónico para enviar el código.
class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
} // LoginEmailScreen

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _emailController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  } // dispose()

  Future<void> _enviar() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Por favor ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // Envía el código OTP a través de tu servicio de autenticación
      await AuthService.enviarCodigo(email);
      if (!mounted) return;

      // Navegar a la pantalla de código pasando el correo como argumento
      Navigator.of(context).pushNamed(Routes.loginCode, arguments: email);
    } catch (e) {
      setState(() => _error = AuthService.mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    } // try / catch
  } // _enviar()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '¡Bienvenido!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tu correo para recibir un código de verificación de acceso.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onSubmitted: (_) {
              if (!_cargando) _enviar();
            },
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              border: const OutlineInputBorder(),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _cargando ? null : _enviar,
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar código'),
          ),
        ], // ListView children
      ),
    );
  } // build()
} // _LoginEmailScreenState