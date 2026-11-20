import 'package:flutter/material.dart';
import '../mock/mock_data.dart'; // TipoPregunta
import '../routes.dart';
import '../services/encuestas_service.dart';

class SurveyQuestionScreen extends StatefulWidget {
  const SurveyQuestionScreen({super.key});

  @override
  State<SurveyQuestionScreen> createState() => _SurveyQuestionScreenState();
} // SurveyQuestionScreen

class _SurveyQuestionScreenState extends State<SurveyQuestionScreen> {
  late SesionEncuesta _sesion;
  late int _index;
  late Map<String, dynamic> _pregunta;

  // Valores elegidos en esta pregunta (se guardan en la sesión al cambiar,
  // así no se pierden al regresar a una pregunta anterior)
  List<String> get _valores => _sesion.respuestas[_pregunta['id']] ?? const [];
  set _valores(List<String> v) => _sesion.respuestas[_pregunta['id'] as String] = v;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _sesion = args['sesion'] as SesionEncuesta;
    _index = args['index'] as int;
    _pregunta = _sesion.preguntas[_index];
  } // didChangeDependencies()

  Widget _buildSingleChoice(List<String> opciones) {
    return Column(
      children: [
        for (final o in opciones)
          ListTile(
            leading: Icon(
              _valores.contains(o) ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            ),
            // Option's text
            title: Text(o),
            onTap: () => setState(() => _valores = [o]),
          ),
      ], // children
    );
  } // _buildSingleChoice()

  Widget _buildInput(String tipo, Map<String, dynamic> p) {
    final opciones = List<String>.from(p['opciones'] as List? ?? const []);

    if (tipo == TipoPregunta.opcionUnica) {
      return _buildSingleChoice(opciones);
    } // opción única

    if (tipo == TipoPregunta.siNo) {
      // Two fixed options
      return _buildSingleChoice(const ['Sí', 'No']);
    } // sí / no

    if (tipo == TipoPregunta.opcionMultiple) {
      final max = (p['max'] as num?)?.toInt() ?? opciones.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hint telling how many options can be picked
          Text('Elige hasta $max opciones'),
          for (final o in opciones)
            CheckboxListTile(
              value: _valores.contains(o),
              title: Text(o),
              onChanged: (v) => setState(() {
                final elegidas = [..._valores];
                if (v == true && elegidas.length < max) {
                  elegidas.add(o);
                } else {
                  elegidas.remove(o);
                } // if / else
                _valores = elegidas;
              }), // onChanged()
            ),
        ], // children
      );
    } // opción múltiple

    if (tipo == TipoPregunta.escala) {
      final double min = (p['min'] as num).toDouble();
      final double max = (p['max'] as num).toDouble();
      final actual = _valores.isEmpty ? null : double.parse(_valores.first);
      return Column(
        children: [
          Slider(
            value: actual ?? min,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: (actual ?? min).toInt().toString(),
            onChanged: (v) => setState(() => _valores = [v.toInt().toString()]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p['etiqueta_min'] as String? ?? ''),
              Text(p['etiqueta_max'] as String? ?? ''),
            ], // children
          ),
          Text(actual == null
              ? 'Mueve el control para responder'
              : 'Valor: ${actual.toInt()}'),
        ], // children
      );
    } // escala

    return TextFormField(
      initialValue: _valores.isEmpty ? '' : _valores.first,
      keyboardType: TextInputType.number,
      onChanged: (v) => setState(() => _valores = v.trim().isEmpty ? [] : [v.trim()]),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Tu respuesta',
        suffixText: p['unidad'] as String?,
        helperText: p['min'] == null ? null : 'Entre ${p['min']} y ${p['max']}',
      ),
    );
  } // _buildInput()

  @override
  Widget build(BuildContext context) {
    final total = _sesion.preguntas.length;
    final bool esUltima = _index == total - 1;
    final bool obligatoria = _pregunta['obligatoria'] as bool;
    final bool puedeSeguir = !obligatoria || _valores.isNotEmpty;

    return Scaffold(
      // Top bar with the survey title
      appBar: AppBar(title: Text(_sesion.encuesta['titulo'] as String)),
      // Scrollable content
      body: ListView(
        // Space around the content
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(value: (_index + 1) / total),
          const SizedBox(height: 8),
          Text('Pregunta ${_index + 1} de $total'),
          const SizedBox(height: 16),
          Text(
            '${_pregunta['texto']}${obligatoria ? ' *' : ''}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInput(_pregunta['tipo'] as String, _pregunta),
          const SizedBox(height: 24),
          // Next / review button
          FilledButton(
            onPressed: !puedeSeguir
                ? null
                : () {
                    if (esUltima) {
                      Navigator.pushNamed(context, Routes.surveyConfirm, arguments: _sesion);
                    } else {
                      Navigator.pushNamed(
                        context,
                        Routes.surveyQuestion,
                        arguments: {'sesion': _sesion, 'index': _index + 1},
                      ); // Navigator
                    } // if / else
                  }, // onPressed()
            child: Text(esUltima ? 'Revisar y enviar' : 'Siguiente'),
          ),
          if (!puedeSeguir) ...[
            const SizedBox(height: 8),
            Text(
              '* Esta pregunta es obligatoria.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ], // children
      ),
    );
  } // build()
} // SurveyQuestionScreenState
