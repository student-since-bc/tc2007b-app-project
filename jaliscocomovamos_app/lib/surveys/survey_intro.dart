import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../routes.dart';

class SurveyIntroScreen extends StatelessWidget {
  const SurveyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final encuesta = encuestaPorId(id)!;
    final totalPreguntas = (encuesta['preguntas'] as List).length;
    final grupos = (encuesta['grupos'] as List)
        .map((g) => nombreGrupo(g as String))
        .join(', ');

    return Scaffold(
      // Top bar
      appBar: AppBar(title: const Text('Encuesta')),
      // Scrollable content
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          Text(
            encuesta['titulo'] as String,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          // Description
          Text(encuesta['descripcion'] as String),
          const SizedBox(height: 16),
          // Number of questions
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text('$totalPreguntas preguntas'),
          ),
          // Closing date
          ListTile(
            leading: const Icon(Icons.event),
            title: Text('Cierra el ${encuesta['cierre']}'),
          ),
          // Group
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text('Dirigida a: $grupos'),
          ),
          const SizedBox(height: 8),
          Text(
            Textos.respuestaAnonima,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          // The start button
          FilledButton(
            onPressed: () => Navigator.pushNamed(
              context,
              Routes.surveyQuestion,
              arguments: {'id': id, 'index': 0},
            ), // Navigator
            child: const Text('Comenzar'),
          ),
        ], // children
      ),
    );
  } // build()
} // SurveyIntroScreen
