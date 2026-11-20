-- ===========================================================================
-- Jalisco Cómo Vamos · Datos de ejemplo
-- Los mismos de lib/mock/mock_data.dart, para que la app tenga algo que
-- mostrar. Correr DESPUÉS de 01_esquema.sql, una sola vez.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Indicadores públicos
-- ---------------------------------------------------------------------------
insert into public.indicadores (id, tema, nombre, unidad, fuente, actualizado) values
  ('seguridad_percepcion',   'Seguridad', 'Percepción de inseguridad',
   'porcentaje', 'Placeholder', null),
  ('educacion_satisfaccion', 'Educación', 'Satisfacción con la educación pública',
   'porcentaje', 'Placeholder', null);

insert into public.indicador_datos (indicador_id, municipio, periodo, valor) values
  ('seguridad_percepcion', 'Guadalajara',                   '2025', 71.2),
  ('seguridad_percepcion', 'Zapopan',                       '2025', 68.4),
  ('seguridad_percepcion', 'San Pedro Tlaquepaque',         '2025', 74.9),
  ('seguridad_percepcion', 'Tonalá',                        '2025', 76.3),
  ('seguridad_percepcion', 'Tlajomulco de Zúñiga',          '2025', 72.8),
  ('seguridad_percepcion', 'El Salto',                      '2025', 78.1),
  ('seguridad_percepcion', 'Ixtlahuacán de los Membrillos', '2025', 61.5),
  ('seguridad_percepcion', 'Juanacatlán',                   '2025', 64.0),
  ('seguridad_percepcion', 'Zapotlanejo',                   '2025', 58.7),
  ('educacion_satisfaccion', 'Guadalajara',                   '2025', 54.3),
  ('educacion_satisfaccion', 'Zapopan',                       '2025', 61.7),
  ('educacion_satisfaccion', 'San Pedro Tlaquepaque',         '2025', 49.8),
  ('educacion_satisfaccion', 'Tonalá',                        '2025', 47.2),
  ('educacion_satisfaccion', 'Tlajomulco de Zúñiga',          '2025', 52.6),
  ('educacion_satisfaccion', 'El Salto',                      '2025', 45.9),
  ('educacion_satisfaccion', 'Ixtlahuacán de los Membrillos', '2025', 55.0),
  ('educacion_satisfaccion', 'Juanacatlán',                   '2025', 50.4),
  ('educacion_satisfaccion', 'Zapotlanejo',                   '2025', 57.1);


-- ---------------------------------------------------------------------------
-- Grupos, encuestas, preguntas y respuestas de prueba
-- ---------------------------------------------------------------------------
do $$
declare
  g_todos   uuid;
  g_ing     uuid;
  g_mujeres uuid;
  s1 uuid; s2 uuid; s3 uuid; s4 uuid;
  s1_p1 uuid; s1_p5 uuid; s2_p3 uuid; s3_p6 uuid;
begin
  -- Grupos -----------------------------------------------------------------
  insert into grupos (nombre, descripcion)
  values ('Todos los estudiantes', 'Estudiantes del Tec Guadalajara con correo @tec.mx')
  returning id into g_todos;

  insert into grupos (nombre, descripcion)
  values ('Ingeniería · 1er semestre', 'Primer ingreso, carreras de ingeniería')
  returning id into g_ing;

  insert into grupos (nombre, descripcion)
  values ('Mujeres universitarias', 'Encuesta específica de percepción de seguridad')
  returning id into g_mujeres;

  -- s1: Movilidad (abierta ahora mismo) -------------------------------------
  insert into encuestas (titulo, descripcion, estado, apertura, cierre)
  values ('Movilidad y transporte en la ZMG',
          'Queremos conocer cómo se mueven los estudiantes por la ciudad. Toma unos 3 minutos.',
          'publicada', current_date - 3, current_date + 26)
  returning id into s1;

  insert into encuesta_grupos values (s1, g_todos);

  insert into preguntas (encuesta_id, orden, tipo, texto, opciones, obligatoria)
  values (s1, 1, 'opcion_unica', '¿Cómo te mueves principalmente por la ciudad?',
          array['Camión / transporte público', 'Auto particular', 'Bicicleta',
                'A pie', 'Aplicación de transporte'], true)
  returning id into s1_p1;

  insert into preguntas (encuesta_id, orden, tipo, texto, opciones, min, max, obligatoria)
  values (s1, 2, 'opcion_multiple', '¿Qué problemas has notado en tu colonia? (elige hasta 3)',
          array['Alumbrado público', 'Baches', 'Basura', 'Inseguridad',
                'Falta de transporte', 'Falta de áreas verdes'], 1, 3, true);

  insert into preguntas (encuesta_id, orden, tipo, texto, min, max, etiqueta_min, etiqueta_max, obligatoria)
  values (s1, 3, 'escala', 'Me siento seguro/a caminando de noche en mi colonia.',
          1, 5, 'Nada de acuerdo', 'Totalmente de acuerdo', true);

  insert into preguntas (encuesta_id, orden, tipo, texto, min, max, unidad, obligatoria)
  values (s1, 4, 'numero', '¿Cuántos minutos tardas en llegar a tu escuela?',
          0, 240, 'minutos', false);

  insert into preguntas (encuesta_id, orden, tipo, texto, obligatoria)
  values (s1, 5, 'si_no', '¿Has usado el transporte público en el último mes?', true)
  returning id into s1_p5;

  insert into preguntas (encuesta_id, orden, tipo, texto, min, max, etiqueta_min, etiqueta_max, obligatoria)
  values (s1, 6, 'escala', 'En general, ¿qué tan satisfecho/a estás con tu calidad de vida?',
          1, 7, 'Nada satisfecho/a', 'Muy satisfecho/a', false);

  -- s2: Seguridad (abierta, menos de 100 respuestas) ------------------------
  insert into encuestas (titulo, descripcion, estado, apertura, cierre)
  values ('Percepción de seguridad universitaria',
          'Encuesta sobre seguridad dentro y cerca del campus.',
          'publicada', current_date - 7, current_date + 16)
  returning id into s2;

  insert into encuesta_grupos values (s2, g_todos), (s2, g_mujeres);

  insert into preguntas (encuesta_id, orden, tipo, texto, min, max, etiqueta_min, etiqueta_max, obligatoria)
  values (s2, 1, 'escala', 'Me siento seguro/a caminando de noche en mi colonia.',
          1, 5, 'Nada de acuerdo', 'Totalmente de acuerdo', true)
  returning id into s2_p3;

  insert into preguntas (encuesta_id, orden, tipo, texto, obligatoria)
  values (s2, 2, 'si_no', '¿Has usado el transporte público en el último mes?', true);

  -- s3: Bienestar (cerrada) -------------------------------------------------
  insert into encuestas (titulo, descripcion, estado, apertura, cierre)
  values ('Bienestar estudiantil 2026',
          'Encuesta del periodo anterior. Ya no recibe respuestas.',
          'cerrada', '2026-09-01', '2026-09-30')
  returning id into s3;

  insert into encuesta_grupos values (s3, g_todos), (s3, g_ing);

  insert into preguntas (encuesta_id, orden, tipo, texto, min, max, etiqueta_min, etiqueta_max, obligatoria)
  values (s3, 1, 'escala', 'En general, ¿qué tan satisfecho/a estás con tu calidad de vida?',
          1, 7, 'Nada satisfecho/a', 'Muy satisfecho/a', false)
  returning id into s3_p6;

  insert into preguntas (encuesta_id, orden, tipo, texto, obligatoria)
  values (s3, 2, 'si_no', '¿Has usado el transporte público en el último mes?', true);

  -- s4: Áreas verdes (borrador) ---------------------------------------------
  insert into encuestas (titulo, descripcion, estado)
  values ('Áreas verdes (borrador)', 'Aún en preparación; no visible para estudiantes.', 'borrador')
  returning id into s4;

  insert into preguntas (encuesta_id, orden, tipo, texto, opciones, obligatoria)
  values (s4, 1, 'opcion_unica', '¿Cómo te mueves principalmente por la ciudad?',
          array['Camión / transporte público', 'Auto particular', 'Bicicleta',
                'A pie', 'Aplicación de transporte'], true);

  -- Respuestas falsas (mismos conteos que resultadosAgregados) --------------
  -- s1: 142 envíos
  with e as (
    insert into envios (encuesta_id)
    select s1 from generate_series(1, 142)
    returning id
  ), n as (
    select id, row_number() over () as i from e
  )
  insert into respuestas (envio_id, pregunta_id, valor)
  select id, s1_p1, case
           when i <=  58 then 'Camión / transporte público'
           when i <=  99 then 'Auto particular'
           when i <= 108 then 'Bicicleta'
           when i <= 129 then 'A pie'
           else 'Aplicación de transporte'
         end
  from n
  union all
  select id, s1_p5, case when i <= 109 then 'Sí' else 'No' end
  from n;

  -- s2: 87 envíos (bajo el umbral de 100)
  with e as (
    insert into envios (encuesta_id)
    select s2 from generate_series(1, 87)
    returning id
  ), n as (
    select id, row_number() over () as i from e
  )
  insert into respuestas (envio_id, pregunta_id, valor)
  select id, s2_p3, case
           when i <= 12 then '1'
           when i <= 30 then '2'
           when i <= 55 then '3'
           when i <= 75 then '4'
           else '5'
         end
  from n;

  -- s3: 310 envíos
  with e as (
    insert into envios (encuesta_id)
    select s3 from generate_series(1, 310)
    returning id
  ), n as (
    select id, row_number() over () as i from e
  )
  insert into respuestas (envio_id, pregunta_id, valor)
  select id, s3_p6, case
           when i <=   8 then '1'
           when i <=  23 then '2'
           when i <=  56 then '3'
           when i <= 127 then '4'
           when i <= 221 then '5'
           when i <= 280 then '6'
           else '7'
         end
  from n;
end;
$$;
