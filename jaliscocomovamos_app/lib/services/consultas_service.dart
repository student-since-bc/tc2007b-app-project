import 'package:supabase_flutter/supabase_flutter.dart';

// Lectura de los resultados agregados de la Encuesta de Bienestar de
// Jóvenes AMG 2026 (pantalla Consultas). Ver supabase/03_consultas.sql.
class ConsultasService {
  static final _db = Supabase.instance.client;

  static const generos = ['Todos', 'Hombre', 'Mujer'];
  static const edades = ['Todas', '15 a 19 años', '20 a 24 años', '25 a 29 años'];

  // Todas las preguntas, ordenadas por tema y orden dentro del tema:
  //   {id, tema, tema_orden, orden, grupo, titulo, opciones}
  static Future<List<Map<String, dynamic>>> preguntas() async {
    final filas = await _db
        .from('consulta_preguntas')
        .select()
        .order('tema_orden')
        .order('orden');
    return List<Map<String, dynamic>>.from(filas);
  } // preguntas()

  // Resultados de una pregunta para todos los grupos de género y edad:
  //   {genero, edad, n, porcentajes}
  // Los grupos con muy pocas personas no existen (no se publican).
  static Future<List<Map<String, dynamic>>> resultados(String preguntaId) async {
    final filas = await _db
        .from('consulta_resultados')
        .select('genero, edad, n, porcentajes')
        .eq('pregunta_id', preguntaId)
        .eq('poblacion', 'AMG');
    return List<Map<String, dynamic>>.from(filas);
  } // resultados()

  // Ids de las preguntas que también están en la mini encuesta del Tec.
  // Si 05_comparacion_tec.sql no se ha corrido, regresa un conjunto vacío.
  static Future<Set<String>> comparables() async {
    try {
      final filas = await _db.rpc('preguntas_comparables') as List;
      return filas.map((f) => f.toString()).toSet();
    } catch (_) {
      return {};
    } // try / catch
  } // comparables()

  // Resultados del Tec (todos los estudiantes): {n, porcentajes}.
  // porcentajes es null mientras haya menos de [umbralTec] respuestas.
  static const umbralTec = 100;

  static Future<Map<String, dynamic>> resultadosTec(String preguntaId) async {
    final filas = await _db.rpc(
      'resultados_tec',
      params: {'p_consulta_pregunta_id': preguntaId},
    ) as List;
    return Map<String, dynamic>.from(filas.first as Map);
  } // resultadosTec()

  // Los porcentajes pueden llegar como número o como texto
  static List<double> aDoubles(List valores) =>
      valores.map((v) => v is num ? v.toDouble() : double.parse(v.toString())).toList();
} // ConsultasService
