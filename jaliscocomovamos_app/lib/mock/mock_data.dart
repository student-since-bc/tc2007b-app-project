// Datos falsos para el MVP de flujo.
// Cuando llegue el JSON real de Jalisco Cómo Vamos, esto se reemplaza.

// ---------------------------------------------------------------------------
// Roles (para el demo switcher del Perfil)
// ---------------------------------------------------------------------------
class Roles {
  static const visitante = 'visitante';
  static const estudiante = 'estudiante';
  static const admin = 'admin';
}

// ---------------------------------------------------------------------------
// Tipos de pregunta (RF-2.5)
// ---------------------------------------------------------------------------
class TipoPregunta {
  static const opcionUnica = 'opcion_unica';
  static const opcionMultiple = 'opcion_multiple';
  static const escala = 'escala';
  static const numero = 'numero';
  static const siNo = 'si_no';
}

// ---------------------------------------------------------------------------
// Estados de encuesta
// ---------------------------------------------------------------------------
class EstadoEncuesta {
  // Ciclo del administrador (RF-3.4)
  static const borrador = 'borrador';
  static const publicada = 'publicada';
  static const cerrada = 'cerrada';

  // Lo que ve el estudiante en "Mis encuestas"
  static const disponible = 'disponible';
  static const yaContestada = 'ya_contestada';
}

// ---------------------------------------------------------------------------
// Textos fijos que se repiten en varias pantallas
// ---------------------------------------------------------------------------
class Textos {
  static const mensajeUmbral =
      'Aún no hay suficientes respuestas para mostrar este resultado.';
  static const advertenciaEnvio =
      'Una vez enviada, tu respuesta no podrá modificarse.';
  static const respuestaAnonima =
      'Tu respuesta es anónima: no se vincula con tu identidad.';
  static const errorDominio =
      'Usa tu correo institucional @tec.mx para iniciar sesión.';
  static const advertenciaDemograficas =
      'Combinar varias preguntas demográficas puede permitir reidentificar '
      'a los encuestados. Inclúyelas solo si son necesarias.';
  static const avisoSalidaDonacion =
      'Saldrás de la app. La donación es voluntaria y no afecta tu '
      'participación en las encuestas.';
  static const avisoRespuestasIndividuales =
      'Como administrador solo ves resultados agregados, nunca respuestas '
      'individuales.';
  static const correoArco = 'privacidad@ejemplo.org'; // [CONFIRMAR]
}

// ---------------------------------------------------------------------------
// Filtros de la pantalla Datos (RF-1.2)
// ---------------------------------------------------------------------------
const List<String> municipiosZmg = [
  'Guadalajara',
  'Zapopan',
  'San Pedro Tlaquepaque',
  'Tonalá',
  'Tlajomulco de Zúñiga',
  'El Salto',
  'Ixtlahuacán de los Membrillos',
  'Juanacatlán',
  'Zapotlanejo',
];

const List<String> temas = [
  'Seguridad',
  'Educación',
  'Calidad de vida',
  'Movilidad',
  'Medio ambiente',
];

const List<String> periodos = ['2023', '2024', '2025'];

// ---------------------------------------------------------------------------
// Indicadores de ejemplo (forma ilustrativa del JSON, SRS 4.1)
// ---------------------------------------------------------------------------
const List<Map<String, dynamic>> indicadores = [
  {
    'id': 'seguridad_percepcion',
    'tema': 'Seguridad',
    'nombre': 'Percepción de inseguridad',
    'unidad': 'porcentaje',
    'datos': [
      {'ciudad': 'Guadalajara', 'periodo': '2025', 'valor': 71.2},
      {'ciudad': 'Zapopan', 'periodo': '2025', 'valor': 68.4},
      {'ciudad': 'San Pedro Tlaquepaque', 'periodo': '2025', 'valor': 74.9},
      {'ciudad': 'Tonalá', 'periodo': '2025', 'valor': 76.3},
      {'ciudad': 'Tlajomulco de Zúñiga', 'periodo': '2025', 'valor': 72.8},
      {'ciudad': 'El Salto', 'periodo': '2025', 'valor': 78.1},
      {'ciudad': 'Ixtlahuacán de los Membrillos', 'periodo': '2025', 'valor': 61.5},
      {'ciudad': 'Juanacatlán', 'periodo': '2025', 'valor': 64.0},
      {'ciudad': 'Zapotlanejo', 'periodo': '2025', 'valor': 58.7},
    ],
  },
  {
    'id': 'educacion_satisfaccion',
    'tema': 'Educación',
    'nombre': 'Satisfacción con la educación pública',
    'unidad': 'porcentaje',
    'datos': [
      {'ciudad': 'Guadalajara', 'periodo': '2025', 'valor': 54.3},
      {'ciudad': 'Zapopan', 'periodo': '2025', 'valor': 61.7},
      {'ciudad': 'San Pedro Tlaquepaque', 'periodo': '2025', 'valor': 49.8},
      {'ciudad': 'Tonalá', 'periodo': '2025', 'valor': 47.2},
      {'ciudad': 'Tlajomulco de Zúñiga', 'periodo': '2025', 'valor': 52.6},
      {'ciudad': 'El Salto', 'periodo': '2025', 'valor': 45.9},
      {'ciudad': 'Ixtlahuacán de los Membrillos', 'periodo': '2025', 'valor': 55.0},
      {'ciudad': 'Juanacatlán', 'periodo': '2025', 'valor': 50.4},
      {'ciudad': 'Zapotlanejo', 'periodo': '2025', 'valor': 57.1},
    ],
  },
];

// Metadatos que se muestran bajo cada gráfica (RF-1.5)
const Map<String, String> fuenteDatosPublicos = {
  'fuente': 'Jalisco Cómo Vamos',
  'periodo': '2025',
  'actualizado': '01/10/2026',
};

// ---------------------------------------------------------------------------
// Grupos (RF-3.2)
// ---------------------------------------------------------------------------
const List<Map<String, dynamic>> grupos = [
  {
    'id': 'g1',
    'nombre': 'Todos los estudiantes',
    'descripcion': 'Estudiantes del Tec Guadalajara con correo @tec.mx',
  },
  {
    'id': 'g2',
    'nombre': 'Ingeniería · 1er semestre',
    'descripcion': 'Primer ingreso, carreras de ingeniería',
  },
  {
    'id': 'g3',
    'nombre': 'Mujeres universitarias',
    'descripcion': 'Encuesta específica de percepción de seguridad',
  },
];

// ---------------------------------------------------------------------------
// Usuarios de demo (para el switcher y la pantalla de Perfil)
// ---------------------------------------------------------------------------
const Map<String, dynamic> estudianteDemo = {
  'correo': 'a01234567@tec.mx',
  'rol': Roles.estudiante,
  'grupos': ['g1', 'g2'],
};

const Map<String, dynamic> adminDemo = {
  'correo': 'admin@ejemplo.org',
  'rol': Roles.admin,
  'grupos': <String>[],
};

const String correoInvalidoDemo = 'isaac@gmail.com';
const String codigoDemo = '123456';

// ---------------------------------------------------------------------------
// Preguntas (una por cada tipo, RF-2.5 / RF-2.6)
// ---------------------------------------------------------------------------
const List<Map<String, dynamic>> preguntasDemo = [
  {
    'id': 'p1',
    'tipo': TipoPregunta.opcionUnica,
    'texto': '¿Cómo te mueves principalmente por la ciudad?',
    'opciones': [
      'Camión / transporte público',
      'Auto particular',
      'Bicicleta',
      'A pie',
      'Aplicación de transporte',
    ],
    'obligatoria': true,
  },
  {
    'id': 'p2',
    'tipo': TipoPregunta.opcionMultiple,
    'texto': '¿Qué problemas has notado en tu colonia? (elige hasta 3)',
    'opciones': [
      'Alumbrado público',
      'Baches',
      'Basura',
      'Inseguridad',
      'Falta de transporte',
      'Falta de áreas verdes',
    ],
    'min': 1,
    'max': 3,
    'obligatoria': true,
  },
  {
    'id': 'p3',
    'tipo': TipoPregunta.escala,
    'texto': 'Me siento seguro/a caminando de noche en mi colonia.',
    'min': 1,
    'max': 5,
    'etiquetaMin': 'Nada de acuerdo',
    'etiquetaMax': 'Totalmente de acuerdo',
    'obligatoria': true,
  },
  {
    'id': 'p4',
    'tipo': TipoPregunta.numero,
    'texto': '¿Cuántos minutos tardas en llegar a tu escuela?',
    'min': 0,
    'max': 240,
    'unidad': 'minutos',
    'obligatoria': false,
  },
  {
    'id': 'p5',
    'tipo': TipoPregunta.siNo,
    'texto': '¿Has usado el transporte público en el último mes?',
    'obligatoria': true,
  },
  {
    'id': 'p6',
    'tipo': TipoPregunta.escala,
    'texto': 'En general, ¿qué tan satisfecho/a estás con tu calidad de vida?',
    'min': 1,
    'max': 7,
    'etiquetaMin': 'Nada satisfecho/a',
    'etiquetaMax': 'Muy satisfecho/a',
    'obligatoria': false,
  },
];

// ---------------------------------------------------------------------------
// Encuestas
//   'estadoAdmin'   -> borrador / publicada / cerrada (panel de administración)
//   'estadoUsuario' -> disponible / ya_contestada / cerrada (Mis encuestas)
// ---------------------------------------------------------------------------
const List<Map<String, dynamic>> encuestas = [
  {
    'id': 's1',
    'titulo': 'Movilidad y transporte en la ZMG',
    'descripcion':
        'Queremos conocer cómo se mueven los estudiantes por la ciudad. '
        'Toma unos 3 minutos.',
    'estadoAdmin': EstadoEncuesta.publicada,
    'estadoUsuario': EstadoEncuesta.disponible,
    'grupos': ['g1'],
    'preguntas': ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'],
    'apertura': '15/11/2026',
    'cierre': '30/11/2026',
    'totalRespuestas': 142,
  },
  {
    'id': 's2',
    'titulo': 'Percepción de seguridad universitaria',
    'descripcion': 'Encuesta sobre seguridad dentro y cerca del campus.',
    'estadoAdmin': EstadoEncuesta.publicada,
    'estadoUsuario': EstadoEncuesta.yaContestada,
    'grupos': ['g1', 'g3'],
    'preguntas': ['p3', 'p5'],
    'apertura': '01/11/2026',
    'cierre': '20/11/2026',
    'totalRespuestas': 87, // menos de 100 -> resultados ocultos
  },
  {
    'id': 's3',
    'titulo': 'Bienestar estudiantil 2026',
    'descripcion': 'Encuesta del periodo anterior. Ya no recibe respuestas.',
    'estadoAdmin': EstadoEncuesta.cerrada,
    'estadoUsuario': EstadoEncuesta.cerrada,
    'grupos': ['g1', 'g2'],
    'preguntas': ['p6', 'p5'],
    'apertura': '01/09/2026',
    'cierre': '30/09/2026',
    'totalRespuestas': 310,
  },
  {
    'id': 's4',
    'titulo': 'Áreas verdes (borrador)',
    'descripcion': 'Aún en preparación; no visible para estudiantes.',
    'estadoAdmin': EstadoEncuesta.borrador,
    'estadoUsuario': null, // los borradores no se muestran a estudiantes
    'grupos': <String>[],
    'preguntas': ['p1', 'p2'],
    'apertura': '',
    'cierre': '',
    'totalRespuestas': 0,
  },
];

// ---------------------------------------------------------------------------
// Resultados agregados (RF-1.4)
//   Cada resultado trae 'total'; si total < 100 la UI muestra
//   Textos.mensajeUmbral en vez de las barras.
// ---------------------------------------------------------------------------
const List<Map<String, dynamic>> resultadosAgregados = [
  {
    'encuestaId': 's1',
    'preguntaId': 'p1',
    'total': 142,
    'conteos': {
      'Camión / transporte público': 58,
      'Auto particular': 41,
      'Bicicleta': 9,
      'A pie': 21,
      'Aplicación de transporte': 13,
    },
  },
  {
    'encuestaId': 's1',
    'preguntaId': 'p5',
    'total': 142,
    'conteos': {'Sí': 109, 'No': 33},
  },
  {
    'encuestaId': 's2',
    'preguntaId': 'p3',
    'total': 87, // ¡bajo el umbral!
    'conteos': {'1': 12, '2': 18, '3': 25, '4': 20, '5': 12},
  },
  {
    'encuestaId': 's3',
    'preguntaId': 'p6',
    'total': 310,
    'conteos': {
      '1': 8,
      '2': 15,
      '3': 33,
      '4': 71,
      '5': 94,
      '6': 59,
      '7': 30,
    },
  },
];

const int umbralMinimoRespuestas = 100;

// ---------------------------------------------------------------------------
// Fase 2 (opcional): asistente y donaciones
// ---------------------------------------------------------------------------
const List<Map<String, String>> chatDemo = [
  {
    'de': 'usuario',
    'texto': '¿Cuál municipio tiene mayor percepción de inseguridad?',
  },
  {
    'de': 'asistente',
    'texto': 'En 2025, El Salto tuvo el mayor porcentaje (78.1%).',
    'fuente': 'Jalisco Cómo Vamos · 2025 · Actualizado 01/10/2026',
  },
];

const String urlDonacionDemo = 'https://ejemplo.org/donar'; // [CONFIRMAR]

// ---------------------------------------------------------------------------
// Helpers de lectura (no son "lógica": solo atajos para no repetir bucles)
// ---------------------------------------------------------------------------
Map<String, dynamic>? preguntaPorId(String id) {
  for (final p in preguntasDemo) {
    if (p['id'] == id) return p;
  }
  return null;
}

Map<String, dynamic>? encuestaPorId(String id) {
  for (final e in encuestas) {
    if (e['id'] == id) return e;
  }
  return null;
}

String nombreGrupo(String id) {
  for (final g in grupos) {
    if (g['id'] == id) return g['nombre'] as String;
  }
  return id;
}