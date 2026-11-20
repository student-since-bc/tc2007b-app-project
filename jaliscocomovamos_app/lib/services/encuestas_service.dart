import 'package:supabase_flutter/supabase_flutter.dart';
import '../mock/mock_data.dart'; // EstadoEncuesta

// Encuestas que contesta el estudiante (mini encuesta del Tec).
// La seguridad la pone Supabase: solo regresa las encuestas publicadas o
// cerradas de los grupos del usuario (ver políticas en 01_esquema.sql).
class EncuestasService {
  static final _db = Supabase.instance.client;

  // Encuestas del usuario con 'estadoUsuario' (disponible / ya_contestada /
  // cerrada), igual que en mock_data.dart para reutilizar SurveyCard.
  static Future<List<Map<String, dynamic>>> misEncuestas() async {
    final encuestas = await _db
        .from('encuestas')
        .select('id, titulo, descripcion, estado, apertura, cierre')
        .neq('estado', EstadoEncuesta.borrador)
        .order('apertura', ascending: false);
    final participaciones = await _db.from('participaciones').select('encuesta_id');
    final contestadas = {for (final p in participaciones) p['encuesta_id']};

    final hoy = DateTime.now();
    final dia = DateTime(hoy.year, hoy.month, hoy.day);
    return [
      for (final e in encuestas)
        {
          ...e,
          'estadoUsuario': contestadas.contains(e['id'])
              ? EstadoEncuesta.yaContestada
              : _abierta(e, dia)
                  ? EstadoEncuesta.disponible
                  : EstadoEncuesta.cerrada,
        },
    ];
  } // misEncuestas()

  static bool _abierta(Map<String, dynamic> e, DateTime dia) {
    if (e['estado'] != EstadoEncuesta.publicada) return false;
    final apertura = DateTime.tryParse(e['apertura'] as String? ?? '');
    final cierre = DateTime.tryParse(e['cierre'] as String? ?? '');
    if (apertura == null || cierre == null) return false;
    return !dia.isBefore(apertura) && !dia.isAfter(cierre);
  } // _abierta()

  static Future<List<Map<String, dynamic>>> preguntas(String encuestaId) async {
    final filas = await _db
        .from('preguntas')
        .select()
        .eq('encuesta_id', encuestaId)
        .order('orden');
    return List<Map<String, dynamic>>.from(filas);
  } // preguntas()

  // respuestas: preguntaId -> valores elegidos (vacío = sin contestar)
  static Future<void> enviar(String encuestaId, Map<String, List<String>> respuestas) {
    return _db.rpc('enviar_respuestas', params: {
      'p_encuesta_id': encuestaId,
      'p_respuestas': [
        for (final r in respuestas.entries)
          if (r.value.isNotEmpty) {'pregunta_id': r.key, 'valores': r.value},
      ],
    });
  } // enviar()

  // Los errores de enviar_respuestas ya vienen en español desde la base
  static String mensajeDeError(Object error) {
    if (error is PostgrestException) return error.message;
    return 'No se pudieron enviar tus respuestas. Revisa tu conexión e inténtalo de nuevo.';
  } // mensajeDeError()
} // EncuestasService

// Lo que se va pasando entre las pantallas al contestar una encuesta.
class SesionEncuesta {
  final Map<String, dynamic> encuesta;
  final List<Map<String, dynamic>> preguntas;
  final Map<String, List<String>> respuestas = {};

  SesionEncuesta(this.encuesta, this.preguntas);
} // SesionEncuesta
