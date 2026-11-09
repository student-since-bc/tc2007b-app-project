-- ===========================================================================
-- Mini encuesta para estudiantes del Tec
-- Usa las mismas preguntas de la Encuesta de Bienestar de Jóvenes AMG 2026
-- para poder comparar resultados Tec vs AMG en Consultas.
-- Correr DESPUÉS de 03_consultas.sql, una sola vez.
-- ===========================================================================

-- Qué pregunta de JCV (consulta_preguntas.id) replica cada pregunta.
-- Sin llave foránea a propósito: 03_consultas.sql recrea esa tabla.
alter table public.preguntas add column consulta_pregunta_id text;

-- Quitar las encuestas de demostración de 02_datos_demo.sql
-- (también se borran sus preguntas y respuestas falsas).
delete from public.encuestas where titulo in (
  'Movilidad y transporte en la ZMG',
  'Percepción de seguridad universitaria',
  'Bienestar estudiantil 2026',
  'Áreas verdes (borrador)'
);

do $$
declare
  v_encuesta uuid;
  -- Preguntas elegidas, en el orden en que se muestran
  v_preguntas text[] := array[
    'Q_6',       -- satisfacción con la vida
    'Q_7',       -- calidad de vida
    'Q_8',       -- felicidad
    'Q_9',       -- satisfacción contigo misma(o)
    'Q_10',      -- vida afectiva o emocional
    'T_Q_11_4',  -- te sientes triste
    'Q_36',      -- satisfacción con tu salud
    'Q_41',      -- salud mental
    'Q_25',      -- uso de chatbots de IA
    'Q_69'       -- medio de transporte
  ];
begin
  insert into encuestas (titulo, descripcion, estado, apertura, cierre)
  values ('Bienestar de estudiantes del Tec 2026',
          'Algunas preguntas de la Encuesta de Bienestar de Jóvenes de Jalisco Cómo Vamos, '
          'para comparar a la comunidad del Tec con las juventudes del AMG. Toma unos 3 minutos.',
          'publicada', current_date, current_date + 30)
  returning id into v_encuesta;

  insert into encuesta_grupos (encuesta_id, grupo_id)
  select v_encuesta, id from grupos where nombre = 'Todos los estudiantes';

  insert into preguntas (encuesta_id, orden, tipo, texto, opciones, obligatoria, consulta_pregunta_id)
  select v_encuesta,
         array_position(v_preguntas, c.id),
         'opcion_unica',
         coalesce(c.grupo || ' ', '') || c.titulo,
         -- La app es autoaplicada: sin la opción "No sabe/No contestó" del encuestador
         array(select o from unnest(c.opciones) o where o !~* '^no (sabe|contest)'),
         true,
         c.id
  from consulta_preguntas c
  where c.id = any(v_preguntas);

  if (select count(*) from preguntas where encuesta_id = v_encuesta) <> array_length(v_preguntas, 1) then
    raise exception 'Falta alguna pregunta en consulta_preguntas: ¿corriste 03_consultas.sql?';
  end if;
end;
$$;
