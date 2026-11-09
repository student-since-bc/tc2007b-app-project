import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes.dart';
import '../theme.dart';

// Pestaña "Jalisco Cómo Vamos": quiénes son, qué hacen, contacto y donaciones.
// Textos tomados de la presentación "JCV 2026 Reto TEC".
class JcvScreen extends StatelessWidget {
  const JcvScreen({super.key});

  static const _sitio = 'https://www.jaliscocomovamos.org';
  static const _correo = 'contacto@jaliscocomovamos.org';

  static const _principios = [
    (
      Icons.groups_outlined,
      'Carácter ciudadano',
      'No participan quienes desempeñen cargos públicos o pertenezcan a '
          'partidos políticos.',
    ),
    (
      Icons.account_balance_outlined,
      'Independencia financiera',
      'No reciben fondos ni recursos de ningún orden de gobierno o partidos '
          'políticos.',
    ),
    (
      Icons.flag_outlined,
      'Objetivo',
      'Mejorar las condiciones de vida de las personas mediante la generación '
          'y comunicación de información producto de sus investigaciones.',
    ),
  ];

  Future<void> _abrir(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    } // if
  } // _abrir()

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Jalisco Cómo Vamos', style: textos.headlineSmall),
        Text('Observatorio Ciudadano', style: textos.titleSmall),
        const SizedBox(height: 16),

        // Who they are
        const Text(
          'Somos un observatorio ciudadano que monitorea indicadores de calidad '
          'de vida para formular mejores políticas públicas e impulsar '
          'iniciativas ciudadanas.',
        ),
        const SizedBox(height: 16),
        Text('Misión', style: textos.titleMedium),
        const SizedBox(height: 4),
        const Text(
          'Organización innovadora y dinámica que involucra a ciudadanos, '
          'gobierno, medios y universidades para actuar corresponsablemente en '
          'la mejora del Área Metropolitana de Guadalajara y Jalisco.',
        ),
        const SizedBox(height: 16),

        // Principles
        for (final (icono, titulo, texto) in _principios)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icono, color: AppColors.primaryText),
            title: Text(titulo),
            subtitle: Text(texto),
          ),
        const SizedBox(height: 16),

        // Donations
        Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.crimson, width: 6)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apoya su trabajo', style: textos.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'Como no reciben recursos de gobiernos ni partidos, su trabajo '
                  'depende de donativos de la ciudadanía.',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, Routes.donation),
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('Donar'),
                  ),
                ),
              ], // Column's children
            ),
          ),
        ), // Donations
        const SizedBox(height: 16),

        // Contact
        Text('Contacto', style: textos.titleMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.language),
          title: const Text('jaliscocomovamos.org'),
          onTap: () => _abrir(context, Uri.parse(_sitio)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.email_outlined),
          title: const Text(_correo),
          onTap: () => _abrir(context, Uri(scheme: 'mailto', path: _correo)),
        ),
      ], // ListView children
    );
  } // build()
} // JcvScreen
