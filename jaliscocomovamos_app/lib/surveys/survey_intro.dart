import 'package:flutter/material.dart';
import '../mock/mock_data.dart'; // Textos.respuestaAnonima
import '../routes.dart';
import '../services/encuestas_service.dart';

class SurveyIntroScreen extends StatefulWidget {
  const SurveyIntroScreen({super.key});

  @override
  State<SurveyIntroScreen> createState() => _SurveyIntroScreenState();
} // SurveyIntroScreen

class _SurveyIntroScreenState extends State<SurveyIntroScreen> {
  Future<List<Map<String, dynamic>>>? _preguntas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final encuesta = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _preguntas ??= EncuestasService.preguntas(encuesta['id'] as String);
  } // didChangeDependencies()

  // '2026-12-08' -> '08/12/2026'
  String _fecha(String? iso) {
    final f = DateTime.tryParse(iso ?? '');
    if (f == null) return '';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  } // _fecha()

  @override
  Widget build(BuildContext context) {
    final encuesta = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      // Top bar
      appBar: AppBar(title: const Text('Encuesta')),
      // Scrollable content
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _preguntas,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } // if
          if (snapshot.hasError) {
            return const Center(child: Text('No se pudo cargar la encuesta.'));
          } // if
          final preguntas = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title
              Text(
                encuesta['titulo'] as String,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              // Description
              Text(encuesta['descripcion'] as String? ?? ''),
              const SizedBox(height: 16),
              // Number of questions
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text('${preguntas.length} preguntas'),
              ),
              // Closing date
              ListTile(
                leading: const Icon(Icons.event),
                title: Text('Cierra el ${_fecha(encuesta['cierre'] as String?)}'),
              ),
              const SizedBox(height: 8),
              Text(
                Textos.respuestaAnonima,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              // The start button
              FilledButton(
                onPressed: preguntas.isEmpty
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          Routes.surveyQuestion,
                          arguments: {
                            'sesion': SesionEncuesta(encuesta, preguntas),
                            'index': 0,
                          },
                        ), // Navigator
                child: const Text('Comenzar'),
              ),
            ], // children
          );
        }, // builder
      ),
    );
  } // build()
} // _SurveyIntroScreenState
