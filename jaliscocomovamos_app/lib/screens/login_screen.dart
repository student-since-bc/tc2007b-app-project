import 'package:flutter/material.dart';
import '../mock/mock_data.dart'; // Textos.errorDominio
import '../routes.dart';
import '../services/auth_service.dart';

// Paso 1 del login: correo @tec.mx + aceptar el aviso de privacidad.
// Supabase manda un código al correo (paso 2: LoginCodeScreen).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _aceptaAviso = false;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final correo = _emailController.text.trim();
    if (!AuthService.esCorreoTec(correo)) {
      setState(() => _error = Textos.errorDominio);
      return;
    } // if

    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await AuthService.enviarCodigo(correo);
      if (!mounted) return;
      Navigator.of(context).pushNamed(Routes.loginCode, arguments: correo);
    } catch (e) {
      setState(() => _error = AuthService.mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    } // try / catch
  } // _enviarCodigo()

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

              Card(
                elevation: 4,
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
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Te enviaremos un código a tu correo institucional. '
                        'No necesitas contraseña.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        onSubmitted: (_) {
                          if (_aceptaAviso && !_enviando) _enviarCodigo();
                        },
                        decoration: InputDecoration(
                          labelText: 'Correo institucional',
                          hintText: 'a01234567@tec.mx',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email_outlined),
                          errorText: _error,
                          errorMaxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Privacy notice (must be accepted to continue)
                      CheckboxListTile(
                        value: _aceptaAviso,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (v) => setState(() => _aceptaAviso = v ?? false),
                        title: const Text('He leído y acepto el aviso de privacidad'),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(Routes.privacy),
                          icon: const Icon(Icons.privacy_tip_outlined),
                          label: const Text('Leer aviso de privacidad'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _aceptaAviso && !_enviando ? _enviarCodigo : null,
                        child: _enviando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Enviar código'),
                      ),
                      // Para usar un código que ya llegó (p. ej. si pedir otro falla)
                      TextButton(
                        onPressed: _enviando
                            ? null
                            : () {
                                final correo = _emailController.text.trim();
                                if (!AuthService.esCorreoTec(correo)) {
                                  setState(() => _error = Textos.errorDominio);
                                  return;
                                } // if
                                Navigator.of(context).pushNamed(Routes.loginCode, arguments: correo);
                              },
                        child: const Text('Ya tengo un código'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),


              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
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
