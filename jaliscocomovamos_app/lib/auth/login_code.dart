import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';

// Paso 2 del login: escribir el código que llegó al correo.
class LoginCodeScreen extends StatefulWidget {
  const LoginCodeScreen({super.key});

  @override
  State<LoginCodeScreen> createState() => _LoginCodeScreenState();
} // LoginCodeScreen

class _LoginCodeScreenState extends State<LoginCodeScreen> {
  final _codigoController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  } // dispose()

  Future<void> _verificar(String correo) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await AuthService.verificarCodigo(correo, _codigoController.text);
      if (!mounted) return;
      // Sesión iniciada: regresar a la app sin dejar el login en el historial
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.shell, (_) => false);
    } catch (e) {
      setState(() => _error = AuthService.mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    } // try / catch
  } // _verificar()

  Future<void> _reenviar(String correo) async {
    try {
      await AuthService.enviarCodigo(correo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un código nuevo.')),
      );
    } catch (e) {
      setState(() => _error = AuthService.mensajeDeError(e));
    } // try / catch
  } // _reenviar()

  @override
  Widget build(BuildContext context) {
    final correo = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Código de verificación')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Revisa tu correo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enviamos un código a $correo. Si no lo ves, revisa la carpeta '
            'de correo no deseado.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codigoController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (!_cargando) _verificar(correo);
            },
            decoration: InputDecoration(
              labelText: 'Código',
              border: const OutlineInputBorder(),
              errorText: _error,
              errorMaxLines: 3,
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            // Supabase manda códigos de 6 dígitos (o hasta 8 si se configura)
            onPressed: _cargando || _codigoController.text.trim().length < 6
                ? null
                : () => _verificar(correo),
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verificar'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _cargando ? null : () => _reenviar(correo),
            child: const Text('Reenviar código'),
          ),
        ], // ListView children
      ),
    );
  } // build()
} // _LoginCodeScreenState
