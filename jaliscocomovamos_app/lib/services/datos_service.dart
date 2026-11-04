import 'package:supabase_flutter/supabase_flutter.dart';

// Lectura de los datos públicos (pantalla Datos, RF-1.x).
// Devuelve la misma forma que `indicadores` en mock_data.dart:
//   {id, tema, nombre, unidad, fuente, actualizado,
//    datos: [{municipio, periodo, valor}, ...]}
class DatosService {
  static final _db = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> indicadores() async {
    final filas = await _db
        .from('indicadores')
        .select('*, datos:indicador_datos(municipio, periodo, valor)')
        .order('tema');
    return List<Map<String, dynamic>>.from(filas);
  } // indicadores()
} // DatosService
