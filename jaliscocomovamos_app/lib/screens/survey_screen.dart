import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import '../mock/mock_data.dart'; // EstadoEncuesta
import '../services/auth_service.dart';
import '../services/encuestas_service.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/survey_card.dart';

class SurveyScreen extends StatelessWidget {
  // Lleva a la pestaña Consultas (la maneja MainShell)
  final VoidCallback onVerResultados;

  const SurveyScreen({super.key, required this.onVerResultados});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Encuestas', style: textos.headlineSmall),
        const SizedBox(height: 16),

        // Jalisco Cómo Vamos survey (already done, open to everyone)
        _BienestarCard(onVerResultados: onVerResultados),
        const SizedBox(height: 32),

        // Tec mini survey
        Text('Mini encuesta para estudiantes del Tec', style: textos.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Contesta algunas de las mismas preguntas que Jalisco Cómo Vamos les '
          'hizo a las juventudes del AMG, para comparar sus resultados con los '
          'de la comunidad del Tec. Es anónima y solo para estudiantes con '
          'correo @tec.mx.',
        ),
        const SizedBox(height: 16),
        const _EncuestasTec(),
      ], // children
    ); // ListView
  } // build()
} // SurveyScreen

// Lista de encuestas del estudiante (Supabase). Sin sesión, pide iniciarla.
class _EncuestasTec extends StatefulWidget {
  const _EncuestasTec();

  @override
  State<_EncuestasTec> createState() => _EncuestasTecState();
} // _EncuestasTec

class _EncuestasTecState extends State<_EncuestasTec> {
  late final StreamSubscription<AuthState> _sesion;
  Future<List<Map<String, dynamic>>>? _encuestas;

  @override
  void initState() {
    super.initState();
    _cargar();
    // Recargar al iniciar o cerrar sesión
    _sesion = AuthService.cambios.listen((_) => setState(_cargar));
  } // initState()

  @override
  void dispose() {
    _sesion.cancel();
    super.dispose();
  } // dispose()

  void _cargar() {
    _encuestas = AuthService.haySesion ? EncuestasService.misEncuestas() : null;
  } // _cargar()

  Future<void> _abrir(Map<String, dynamic> e) async {
    final estado = e['estadoUsuario'];
    if (estado == EstadoEncuesta.disponible) {
      await Navigator.pushNamed(context, Routes.surveyIntro, arguments: e);
      // Al volver (p. ej. después de enviar), actualizar "ya contestada"
      if (mounted) setState(_cargar);
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
  } // _abrir()

  @override
  Widget build(BuildContext context) {
    if (_encuestas == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inicia sesión con tu correo @tec.mx para contestar.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.loginEmail),
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
              ),
            ], // Column's children
          ),
        ),
      );
    } // if

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _encuestas,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } // if
        if (snapshot.hasError) {
          return Column(
            children: [
              const Text('No se pudieron cargar las encuestas.'),
              TextButton(
                onPressed: () => setState(_cargar),
                child: const Text('Reintentar'),
              ),
            ], // Column's children
          );
        } // if
        final encuestas = snapshot.data!;
        if (encuestas.isEmpty) {
          return const Text('Por ahora no tienes encuestas asignadas.');
        } // if
        return Column(
          children: [
            for (final e in encuestas)
              SurveyCard(encuesta: e, onTap: () => _abrir(e)),
          ], // Column's children
        );
      }, // builder
    );
  } // build()
} // _EncuestasTecState

// Tarjeta de la Encuesta de Bienestar de Jóvenes AMG 2026 de JCV.
class _BienestarCard extends StatelessWidget {
  final VoidCallback onVerResultados;

  const _BienestarCard({required this.onVerResultados});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        // Franja de color a la izquierda para distinguirla de las demás
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.crimson, width: 6)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encuesta de Bienestar de Jóvenes 2026',
              style: textos.titleMedium,
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(Icons.location_city, size: 18),
                  label: Text('Área Metropolitana de Guadalajara'),
                ),
                Chip(
                  avatar: Icon(Icons.public, size: 18),
                  label: Text('Libre consulta'),
                ),
              ], // Wrap's children
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta encuesta ya la realizó Jalisco Cómo Vamos: entrevistó cara a '
              'cara a 1,207 jóvenes de 15 a 29 años del Área Metropolitana de '
              'Guadalajara, del 25 de julio al 24 de agosto de 2026. No necesitas '
              'contestarla; sus resultados son de libre consulta, sin iniciar sesión.',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onVerResultados,
                icon: const Icon(Icons.bar_chart),
                label: const Text('Ver resultados'),
              ),
            ),
          ], // Column's children
        ),
      ),
    );
  } // build()
} // _BienestarCard
