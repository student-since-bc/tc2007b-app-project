import 'package:flutter/material.dart';
import '../mock/mock_data.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
} // DataScreen

class _DataScreenState extends State<DataScreen> {
  String _ciudad = 'Todas';
  String _tema = 'Seguridad';
  String _periodo = '2025';

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      }, // onChanged
    );
  } // _buildDropdown()

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? indicador;
    for (final i in indicadores) {
      if (i['tema'] == _tema) indicador = i;
    } // for

    final List<Map<String, dynamic>> filas = [];
    if (indicador != null) {
      for (final d in indicador['datos'] as List) {
        final fila = Map<String, dynamic>.from(d as Map);
        final okCiudad = _ciudad == 'Todas' || fila['ciudad'] == _ciudad;
        final okPeriodo = fila['periodo'] == _periodo;
        if (okCiudad && okPeriodo) filas.add(fila);
      } // for
    } // if

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Datos', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        // City
        _buildDropdown(
          label: 'Ciudad',
          value: _ciudad,
          items: ['Todas', ...municipiosZmg],
          onChanged: (v) => setState(() => _ciudad = v),
        ), // City
        const SizedBox(height: 12),

        // Topic
        _buildDropdown(
          label: 'Tema',
          value: _tema,
          items: temas,
          onChanged: (v) => setState(() => _tema = v),
        ), // Topic
        const SizedBox(height: 12),

        // Period
        _buildDropdown(
          label: 'Periodo',
          value: _periodo,
          items: periodos,
          onChanged: (v) => setState(() => _periodo = v),
        ), // Period
        const SizedBox(height: 24),

        if (filas.isNotEmpty) ...[
          Text(
            indicador!['nombre'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Fake chart
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 64),
                  SizedBox(height: 8),
                  Text('Gráfica (placeholder)'),
                ], // Column's children
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lets the table scroll sideways if it is wider than the screen
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Municipio')),
                DataColumn(label: Text('Valor (%)')),
              ], // Columns
              rows: filas
                  .map(
                    (fila) => DataRow(
                      cells: [
                        DataCell(Text(fila['ciudad'] as String)),
                        DataCell(Text('${fila['valor']}%')),
                      ], // Cells
                    ),
                  ) // Map
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Source line
          Text(
            'Fuente: ${fuenteDatosPublicos['fuente']} · Periodo $_periodo · '
            'Actualizado ${fuenteDatosPublicos['actualizado']}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else // Not enough answers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(Textos.mensajeUmbral)),
                ], // Row's children
              ),
            ),
          ),
      ], // ListView children
    );
  } // build()
} // _DataScreenState
