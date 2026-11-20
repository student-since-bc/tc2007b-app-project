import 'package:flutter/material.dart';
import '../mock/mock_data.dart'; // Textos.correoArco

// Aviso de privacidad simplificado.
// [CONFIRMAR] BORRADOR: el texto debe validarlo Jalisco Cómo Vamos
// (responsable, domicilio y correo para derechos ARCO).
class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({super.key});

  static const _secciones = [
    (
      'Responsable',
      'Jalisco Cómo Vamos, Observatorio Ciudadano, es responsable del '
          'tratamiento de los datos personales que se recaban en esta app.',
    ),
    (
      'Qué datos recabamos',
      'Solo tu correo institucional @tec.mx, para verificar que eres '
          'estudiante del Tec. Tus respuestas a las encuestas se guardan por '
          'separado y sin ningún dato que permita relacionarlas contigo.',
    ),
    (
      'Para qué los usamos',
      '1. Verificar que eres estudiante con un correo @tec.mx.\n'
          '2. Evitar que una misma persona conteste una encuesta más de una vez.\n'
          '3. Generar estadísticas agregadas que comparan a la comunidad del Tec '
          'con las juventudes del Área Metropolitana de Guadalajara.',
    ),
    (
      'Cómo protegemos tus respuestas',
      'Nadie, ni siquiera quienes administran la app, puede ver respuestas '
          'individuales. Solo se publican resultados agregados, y únicamente '
          'cuando hay suficientes respuestas para que nadie pueda ser '
          'identificado.',
    ),
    (
      'Con quién los compartimos',
      'No vendemos ni compartimos tus datos personales. Los datos se '
          'almacenan en un proveedor de servicios en la nube (Supabase) que '
          'solo los guarda por cuenta del responsable.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Aviso de privacidad')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (titulo, cuerpo) in _secciones) ...[
            Text(titulo, style: textos.titleMedium),
            const SizedBox(height: 4),
            Text(cuerpo),
            const SizedBox(height: 16),
          ],
          Text('Tus derechos (ARCO)', style: textos.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Puedes solicitar el acceso, rectificación, cancelación u oposición '
            'al tratamiento de tus datos, o revocar tu consentimiento, '
            'escribiendo a:',
          ),
          const SizedBox(height: 4),
          SelectableText(
            Textos.correoArco,
            style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Cualquier cambio a este aviso se publicará en esta misma sección.',
            style: textos.bodySmall,
          ),
        ], // ListView children
      ),
    );
  } // build()
} // PrivacyNoticeScreen
