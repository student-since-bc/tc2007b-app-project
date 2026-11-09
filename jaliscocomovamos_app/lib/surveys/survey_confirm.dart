import 'package:flutter/material.dart';
import '../mock/mock_data.dart'; // Textos
import '../routes.dart';
import '../services/encuestas_service.dart';

class SurveyConfirmScreen extends StatefulWidget {
  const SurveyConfirmScreen({super.key});

  @override
  State<SurveyConfirmScreen> createState() => _SurveyConfirmScreenState();
} // SurveyConfirmScreen

class _SurveyConfirmScreenState extends State<SurveyConfirmScreen> {
  bool _enviando = false;
  String? _error;

  Future<void> _enviar(SesionEncuesta sesion) async {
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await EncuestasService.enviar(sesion.encuesta['id'] as String, sesion.respuestas);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.surveyDone,
        (route) => route.isFirst,
      ); // pushNamedAndRemoveUntil
    } catch (e) {
      setState(() => _error = EncuestasService.mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    } // try / catch
  } // _enviar()

  @override
  Widget build(BuildContext context) {
    final sesion = ModalRoute.of(context)!.settings.arguments as SesionEncuesta;
    final contestadas = sesion.respuestas.values.where((v) => v.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar envío')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            sesion.encuesta['titulo'] as String,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Contestaste $contestadas de ${sesion.preguntas.length} preguntas.'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Textos.advertenciaEnvio),
                  const SizedBox(height: 8),
                  Text(Textos.respuestaAnonima),
                ], // children
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          // Send button
          FilledButton(
            onPressed: _enviando ? null : () => _enviar(sesion),
            child: _enviando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar respuestas'),
          ),
          const SizedBox(height: 12),
          // Go-back button
          OutlinedButton(
            onPressed: _enviando ? null : () => Navigator.pop(context),
            child: const Text('Volver y revisar'),
          ),
        ], // children
      ),
    );
  } // build()
} // _SurveyConfirmScreenState
