import 'package:flutter/material.dart';
import '../services/consultas_service.dart';
import '../theme.dart';

// Pantalla "Consultas": resultados de la Encuesta de Bienestar de Jóvenes
// AMG 2026, filtrados por tema, pregunta, género y edad, y comparados con
// la mini encuesta del Tec.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
} // DataScreen

// Qué población se muestra
enum _Poblacion { amg, tec, comparar }

class _DataScreenState extends State<DataScreen> {
  static const _encuesta = 'Bienestar de Jóvenes AMG 2026';
  static const _fuente =
      'Fuente: Encuesta de Bienestar de Jóvenes en el AMG 2026, '
      'Jalisco Cómo Vamos. Levantamiento del 25 de julio al 24 de agosto de 2026.';
  static const _fuenteTec =
      'Tec: mini encuesta "Bienestar de estudiantes del Tec 2026", contestada '
      'en esta app por estudiantes con correo @tec.mx.';

  late Future<List<Map<String, dynamic>>> _preguntas;
  Set<String> _comparables = {};
  Future<(List<Map<String, dynamic>>, Map<String, dynamic>?)>? _resultados;

  _Poblacion _poblacion = _Poblacion.amg;
  String? _tema;
  String? _preguntaId;
  String _genero = ConsultasService.generos.first;
  String _edad = ConsultasService.edades.first;

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  } // initState()

  void _cargarPreguntas() {
    _preguntas = Future.wait([
      ConsultasService.preguntas(),
      ConsultasService.comparables(),
    ]).then((r) {
      final preguntas = r[0] as List<Map<String, dynamic>>;
      _comparables = r[1] as Set<String>;
      // Valores precargados: primera pregunta del primer tema
      if (preguntas.isNotEmpty && _preguntaId == null) {
        _tema = preguntas.first['tema'] as String;
        _seleccionarPregunta(preguntas.first['id'] as String);
      } // if
      return preguntas;
    });
  } // _cargarPreguntas()

  void _seleccionarPregunta(String id) {
    _preguntaId = id;
    _resultados = Future.wait([
      ConsultasService.resultados(id),
      _comparables.contains(id)
          ? ConsultasService.resultadosTec(id)
          : Future<Map<String, dynamic>?>.value(null),
    ]).then((r) => (
          r[0] as List<Map<String, dynamic>>,
          r[1] as Map<String, dynamic>?,
        ));
  } // _seleccionarPregunta()

  void _recargar() {
    setState(() {
      _cargarPreguntas();
      if (_preguntaId != null) _seleccionarPregunta(_preguntaId!);
    });
  } // _recargar()

  // Al pasar a Tec o Comparar solo quedan las preguntas de la mini encuesta
  void _cambiarPoblacion(_Poblacion p, List<Map<String, dynamic>> preguntas) {
    setState(() {
      _poblacion = p;
      if (p != _Poblacion.amg && !_comparables.contains(_preguntaId)) {
        final primera = preguntas.firstWhere((q) => _comparables.contains(q['id']));
        _tema = primera['tema'] as String;
        _seleccionarPregunta(primera['id'] as String);
      } // if
    });
  } // _cambiarPoblacion()

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      // La key obliga a reconstruir el campo cuando cambia el valor desde fuera
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: (v) {
        if (v != null) onChanged(v);
      }, // onChanged
    );
  } // _buildDropdown()

  List<DropdownMenuItem<String>> _opciones(Iterable<String> valores) {
    return valores
        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
        .toList();
  } // _opciones()

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _preguntas,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } // if
        if (snapshot.hasError) return _buildError();
        return _buildContenido(context, snapshot.data!);
      }, // builder
    );
  } // build()

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No se pudieron cargar los datos.'),
          const SizedBox(height: 8),
          FilledButton(onPressed: _recargar, child: const Text('Reintentar')),
        ], // Column's children
      ),
    );
  } // _buildError()

  Widget _buildContenido(
    BuildContext context,
    List<Map<String, dynamic>> todas,
  ) {
    final soloTec = _poblacion != _Poblacion.amg;
    final preguntas = soloTec
        ? todas.where((p) => _comparables.contains(p['id'])).toList()
        : todas;
    final temas = <String>[];
    for (final p in preguntas) {
      if (!temas.contains(p['tema'])) temas.add(p['tema'] as String);
    } // for
    final delTema = preguntas.where((p) => p['tema'] == _tema).toList();
    final pregunta = preguntas.where((p) => p['id'] == _preguntaId).firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Consultas', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        // Survey (solo hay una por ahora; queda precargada)
        _buildDropdown(
          label: 'Encuesta',
          value: _encuesta,
          items: _opciones([_encuesta]),
          onChanged: (_) {},
        ), // Survey
        const SizedBox(height: 12),

        // Population: AMG, Tec or both
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<_Poblacion>(
            segments: [
              const ButtonSegment(value: _Poblacion.amg, label: Text('Jóvenes AMG')),
              ButtonSegment(
                value: _Poblacion.tec,
                label: const Text('Tec'),
                enabled: _comparables.isNotEmpty,
              ),
              ButtonSegment(
                value: _Poblacion.comparar,
                label: const Text('Comparar'),
                enabled: _comparables.isNotEmpty,
              ),
            ], // segments
            selected: {_poblacion},
            showSelectedIcon: false,
            onSelectionChanged: (s) => _cambiarPoblacion(s.first, todas),
          ),
        ), // Population
        if (soloTec) ...[
          const SizedBox(height: 4),
          Text(
            'Solo aparecen las preguntas que también tiene la mini encuesta del Tec.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),

        // Topic
        _buildDropdown(
          label: 'Tema',
          value: _tema,
          items: _opciones(temas),
          onChanged: (v) => setState(() {
            _tema = v;
            _seleccionarPregunta(
              preguntas.firstWhere((p) => p['tema'] == v)['id'] as String,
            );
          }),
        ), // Topic
        const SizedBox(height: 12),

        // Question
        _buildDropdown(
          label: 'Pregunta',
          value: _preguntaId,
          items: delTema
              .map(
                (p) => DropdownMenuItem(
                  value: p['id'] as String,
                  child: Text(
                    p['titulo'] as String,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ) // map
              .toList(),
          onChanged: (v) => setState(() => _seleccionarPregunta(v)),
        ), // Question
        const SizedBox(height: 12),

        // Gender and age, side by side (la mini encuesta del Tec no los pregunta)
        if (_poblacion != _Poblacion.tec)
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: _poblacion == _Poblacion.comparar ? 'Género (AMG)' : 'Género',
                  value: _genero,
                  items: _opciones(ConsultasService.generos),
                  onChanged: (v) => setState(() => _genero = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: _poblacion == _Poblacion.comparar ? 'Edad (AMG)' : 'Edad',
                  value: _edad,
                  items: _opciones(ConsultasService.edades),
                  onChanged: (v) => setState(() => _edad = v),
                ),
              ),
            ], // Row's children
          ), // Gender and age
        const SizedBox(height: 24),

        if (pregunta != null) _buildResultado(context, pregunta),
      ], // ListView children
    );
  } // _buildContenido()

  Widget _buildAviso(String texto) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(texto)),
          ], // Row's children
        ),
      ),
    );
  } // _buildAviso()

  // Nombre de la serie del AMG según los filtros, p. ej. "AMG · Mujer · 20 a 24 años"
  String _etiquetaAmg() {
    final partes = ['Jóvenes AMG'];
    if (_genero != ConsultasService.generos.first) partes.add(_genero);
    if (_edad != ConsultasService.edades.first) partes.add(_edad);
    return partes.join(' · ');
  } // _etiquetaAmg()

  Widget _buildResultado(BuildContext context, Map<String, dynamic> pregunta) {
    final textos = Theme.of(context).textTheme;
    return FutureBuilder<(List<Map<String, dynamic>>, Map<String, dynamic>?)>(
      future: _resultados,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        } // if
        if (snapshot.hasError) return _buildError();

        final (amg, tec) = snapshot.data!;
        final opciones = List<String>.from(pregunta['opciones'] as List);
        final filaAmg = amg
            .where((r) => r['genero'] == _genero && r['edad'] == _edad)
            .firstOrNull;
        final tecListo = tec != null && tec['porcentajes'] != null;
        final nTec = (tec?['n'] as num?)?.toInt() ?? 0;

        final verAmg = _poblacion != _Poblacion.tec;
        final verTec = _poblacion != _Poblacion.amg;

        // Series a dibujar: (nombre, color, porcentajes)
        final series = <(String, Color, List<double>)>[
          if (verAmg && filaAmg != null)
            (_etiquetaAmg(), AppColors.primaryText,
                ConsultasService.aDoubles(filaAmg['porcentajes'] as List)),
          if (verTec && tecListo)
            ('Estudiantes del Tec', AppColors.crimson,
                ConsultasService.aDoubles(tec['porcentajes'] as List)),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pregunta['grupo'] != null) ...[
              Text(pregunta['grupo'] as String, style: textos.bodySmall),
              const SizedBox(height: 4),
            ],
            Text(pregunta['titulo'] as String, style: textos.titleMedium),
            const SizedBox(height: 16),

            if (verAmg && filaAmg == null) ...[
              _buildAviso(
                'No hay suficientes personas en este grupo del AMG para '
                'mostrar resultados sin poner en riesgo su anonimato.',
              ),
              const SizedBox(height: 12),
            ],
            if (verTec && !tecListo) ...[
              _buildAviso(
                'La mini encuesta del Tec lleva $nTec '
                '${nTec == 1 ? 'respuesta' : 'respuestas'} a esta pregunta. '
                'Sus resultados se muestran a partir de ${ConsultasService.umbralTec}, '
                'para que nadie pueda ser identificado.',
              ),
              const SizedBox(height: 12),
            ],

            if (series.isNotEmpty) ...[
              if (series.length > 1) ...[
                _Leyenda(series: series),
                const SizedBox(height: 12),
              ],
              _BarrasPorcentaje(opciones: opciones, series: series),
              const SizedBox(height: 8),
              if (verAmg && filaAmg != null)
                Text('Jóvenes AMG encuestados en este grupo: ${filaAmg['n']}',
                    style: textos.bodySmall),
              if (verTec && tecListo)
                Text('Estudiantes del Tec que respondieron: $nTec',
                    style: textos.bodySmall),
            ],
            const SizedBox(height: 12),

            // Source lines
            if (verAmg) Text(_fuente, style: textos.bodySmall),
            if (verTec) ...[
              const SizedBox(height: 4),
              Text(_fuenteTec, style: textos.bodySmall),
            ],
          ], // Column's children
        );
      }, // builder
    );
  } // _buildResultado()
} // _DataScreenState

class _Leyenda extends StatelessWidget {
  final List<(String, Color, List<double>)> series;

  const _Leyenda({required this.series});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final (nombre, color, _) in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: color),
              const SizedBox(width: 6),
              Text(nombre),
            ], // Row's children
          ),
      ], // Wrap's children
    );
  } // build()
} // _Leyenda

// Gráfica de barras horizontales: por cada opción de respuesta, una barra
// por serie (una sola serie, o AMG y Tec juntas para comparar).
class _BarrasPorcentaje extends StatelessWidget {
  final List<String> opciones;
  final List<(String, Color, List<double>)> series;

  const _BarrasPorcentaje({required this.opciones, required this.series});

  @override
  Widget build(BuildContext context) {
    // Escala común a todas las series para que las barras se puedan comparar
    var maximo = 0.0;
    for (final (_, _, valores) in series) {
      for (final v in valores) {
        if (v > maximo) maximo = v;
      } // for
    } // for
    final unaSerie = series.length == 1;

    return Column(
      children: [
        for (var i = 0; i < opciones.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(opciones[i]),
                const SizedBox(height: 4),
                for (final (_, color, valores) in series)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: maximo == 0 ? 0 : valores[i] / maximo,
                              minHeight: 12,
                              // Con una sola serie se resalta la opción más alta;
                              // al comparar, cada serie lleva su color
                              color: !unaSerie
                                  ? color
                                  : valores[i] == maximo
                                      ? AppColors.crimson
                                      : AppColors.primaryText,
                              backgroundColor: AppColors.highlight.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 52,
                          child: Text(
                            '${(valores[i] * 100).toStringAsFixed(1)}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ], // Row's children
                    ),
                  ),
              ], // Column's children
            ),
          ),
      ], // Column's children
    );
  } // build()
} // _BarrasPorcentaje
