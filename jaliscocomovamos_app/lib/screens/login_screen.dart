import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';

// Paso 1 del login: capturar el correo institucional y mandar el código OTP.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final correo = _correoController.text.trim();

    // 1. Validar que sea correo del Tec usando tu AuthService
    if (!AuthService.esCorreoTec(correo)) {
      setState(() => _error = 'Usa un correo institucional válido (@tec.mx).');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // 2. Enviar el código OTP a través de Supabase
      await AuthService.enviarCodigo(correo);
      if (!mounted) return;

      // 3. Navegar a LoginCodeScreen enviando el correo como argumento
      Navigator.of(context).pushNamed(
        Routes.loginCode,
        arguments: correo,
      );
    } catch (e) {
      // 4. Mostrar el error traducido de tu AuthService
      setState(() => _error = AuthService.mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Ingresa tu correo institucional',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Te enviaremos un código de verificación para confirmar tu identidad.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) {
              if (!_cargando) _enviarCodigo();
            },
            decoration: InputDecoration(
              labelText: 'Correo (@tec.mx)',
              hintText: 'a01234567@tec.mx',
              border: const OutlineInputBorder(),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _cargando ? null : _enviarCodigo,
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar código'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.privacy),
            child: const Text('Aviso de privacidad'),
          ),
        ],
      ),
    );
  }
}