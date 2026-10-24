import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../routes.dart';
import '../widgets/survey_card.dart';

class MySurveysScreen extends StatelessWidget {
  const MySurveysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Mis encuestas', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final e in encuestas)
          if (e['estadoUsuario'] != null)
            SurveyCard(
              encuesta: e,
              onTap: () {
                final estado = e['estadoUsuario'];
                if (estado == EstadoEncuesta.disponible) {
                  Navigator.pushNamed(context, Routes.surveyIntro, arguments: e['id']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // The message bar
                    SnackBar(
                      content: Text(
                        estado == EstadoEncuesta.yaContestada
                            ? 'Ya contestaste esta encuesta.'
                            : 'Esta encuesta ya está cerrada.',
                      ),
                    ),
                  ); // showSnackBar
                } // if / else
              }, // onTap()
            ),
      ], // children
    );
  } // build()
} // MySurveysScreen
