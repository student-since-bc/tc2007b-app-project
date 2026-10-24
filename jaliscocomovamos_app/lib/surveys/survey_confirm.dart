import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../routes.dart';

class SurveyConfirmScreen extends StatelessWidget {
  const SurveyConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final encuesta = encuestaPorId(id)!;
    final total = (encuesta['preguntas'] as List).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar envío')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            encuesta['titulo'] as String,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Contestaste $total preguntas.'),
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
          const SizedBox(height: 24),
          // Send button
          FilledButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.surveyDone,
              (route) => route.isFirst,
            ), // pushNamedAndRemoveUntil
            child: const Text('Enviar respuestas'),
          ),
          const SizedBox(height: 12),
          // Go-back button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver y revisar'),
          ),
        ], // children
      ),
    );
  } // build()
} // SurveyConfirmScreen
