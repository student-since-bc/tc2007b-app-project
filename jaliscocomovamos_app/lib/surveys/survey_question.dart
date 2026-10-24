import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../routes.dart';

class SurveyQuestionScreen extends StatefulWidget {
  const SurveyQuestionScreen({super.key});

  @override
  State<SurveyQuestionScreen> createState() => _SurveyQuestionScreenState();
} // SurveyQuestionScreen

class _SurveyQuestionScreenState extends State<SurveyQuestionScreen> {
  String? _opcion;
  final Set<String> _multi = {};
  double? _escala;

  Widget _buildSingleChoice(List<String> opciones) {
    return Column(
      children: [
        for (final o in opciones)
          ListTile(
            leading: Icon(
              _opcion == o ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            ),
            // Option's text
            title: Text(o),
            onTap: () => setState(() => _opcion = o),
          ),
      ], // children
    );
  } // _buildSingleChoice()

  Widget _buildInput(String tipo, Map<String, dynamic> p) {
    if (tipo == TipoPregunta.opcionUnica) {
      return _buildSingleChoice((p['opciones'] as List).cast<String>());
    } // opción única

    if (tipo == TipoPregunta.siNo) {
      // Two fixed options
      return _buildSingleChoice(const ['Sí', 'No']);
    } // sí / no

    if (tipo == TipoPregunta.opcionMultiple) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hint telling how many options can be picked
          Text('Elige entre ${p['min']} y ${p['max']} opciones'),
          for (final o in (p['opciones'] as List).cast<String>())
            CheckboxListTile(
              value: _multi.contains(o),
              title: Text(o),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _multi.add(o);
                } else {
                  _multi.remove(o);
                } // if / else
              }), // onChanged()
            ),
        ], // children
      );
    } // opción múltiple

    if (tipo == TipoPregunta.escala) {
      final double min = (p['min'] as int).toDouble();
      final double max = (p['max'] as int).toDouble();
      final double valor = _escala ?? min;
      return Column(
        children: [
          Slider(
            value: valor,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: valor.toInt().toString(),
            onChanged: (v) => setState(() => _escala = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p['etiquetaMin'] as String),
              Text(p['etiquetaMax'] as String),
            ], // children
          ),
          Text('Valor: ${valor.toInt()}'),
        ], // children
      );
    } // escala

    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Tu respuesta',
        suffixText: p['unidad'] as String,
        helperText: 'Entre ${p['min']} y ${p['max']}',
      ),
    );
  } // _buildInput()

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String id = args['id'] as String;
    final int index = args['index'] as int;
    final encuesta = encuestaPorId(id)!;
    final ids = encuesta['preguntas'] as List;
    final pregunta = preguntaPorId(ids[index] as String)!;
    final bool esUltima = index == ids.length - 1;
    final bool obligatoria = pregunta['obligatoria'] as bool;

    return Scaffold(
      // Top bar with the survey title
      appBar: AppBar(title: Text(encuesta['titulo'] as String)),
      // Scrollable content
      body: ListView(
        // Space around the content
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(value: (index + 1) / ids.length),
          const SizedBox(height: 8),
          Text('Pregunta ${index + 1} de ${ids.length}'),
          const SizedBox(height: 16),
          Text(
            '${pregunta['texto']}${obligatoria ? ' *' : ''}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInput(pregunta['tipo'] as String, pregunta),
          const SizedBox(height: 24),
          // Next / review button
          FilledButton(
            onPressed: () {
              if (esUltima) {
                Navigator.pushNamed(context, Routes.surveyConfirm, arguments: id);
              } else {
                Navigator.pushNamed(
                  context,
                  Routes.surveyQuestion,
                  arguments: {'id': id, 'index': index + 1},
                ); // Navigator
              } // if / else
            }, // onPressed()
            child: Text(esUltima ? 'Revisar y enviar' : 'Siguiente'),
          ),
        ], // children
      ),
    );
  } // build()
} // SurveyQuestionScreenState
