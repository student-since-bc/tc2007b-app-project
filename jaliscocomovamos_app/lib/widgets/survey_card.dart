import 'package:flutter/material.dart';
import '../mock/mock_data.dart';

class SurveyCard extends StatelessWidget {
  final Map<String, dynamic> encuesta;
  final VoidCallback onTap;

  const SurveyCard({
    super.key,
    required this.encuesta,
    required this.onTap,
  }); // SurveyCard

  @override
  Widget build(BuildContext context) {
    final estado = encuesta['estadoUsuario'] as String;

    String etiqueta;
    IconData icono;

    if (estado == EstadoEncuesta.disponible) {
      etiqueta = 'Disponible';
      icono = Icons.play_circle_outline;
    } else if (estado == EstadoEncuesta.yaContestada) {
      etiqueta = 'Ya contestada';
      icono = Icons.check_circle_outline;
    } else {
      etiqueta = 'Cerrada';
      icono = Icons.lock_outline;
    } // if / else

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                encuesta['titulo'] as String,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(encuesta['descripcion'] as String),
              const SizedBox(height: 12),
              Chip(
                avatar: Icon(icono, size: 18),
                label: Text(etiqueta),
              ),
            ], // children
          ),
        ),
      ),
    );
  } // build()
} // SurveyCard
