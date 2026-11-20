-- ===========================================================================
-- Comparación AMG vs Tec (pantalla Consultas)
-- Resultados agregados de la mini encuesta del Tec, en el mismo formato que
-- consulta_resultados para poder ponerlos lado a lado.
-- Correr DESPUÉS de 04_mini_encuesta_tec.sql. Se puede volver a correr.
-- ===========================================================================

-- Preguntas de JCV (consulta_preguntas.id) que también están en alguna
-- encuesta del Tec, para saber cuáles se pueden comparar.
create or replace function public.preguntas_comparables()
returns setof text
language sql stable security definer set search_path = public
as $$
  select distinct p.consulta_pregunta_id
  from preguntas p
  join encuestas e on e.id = p.encuesta_id
  where p.consulta_pregunta_id is not null
    and e.estado <> 'borrador';
$$;

-- Resultados del Tec para una pregunta de JCV:
--   n           -> cuántas personas la han contestado (siempre se regresa)
--   porcentajes -> fracción por opción, en el orden de consulta_preguntas.opciones;
--                  null mientras haya menos de 100 respuestas (anonimato)
create or replace function public.resultados_tec(p_consulta_pregunta_id text)
returns table (n bigint, porcentajes numeric[])
language sql stable security definer set search_path = public
as $$
  with r as (
    select r.envio_id, r.valor
    from respuestas r
    join preguntas p on p.id = r.pregunta_id
    join encuestas e on e.id = p.encuesta_id
    where p.consulta_pregunta_id = p_consulta_pregunta_id
      and e.estado <> 'borrador'
  ), total as (
    select count(distinct envio_id) as n from r
  )
  select total.n,
         case when total.n >= 100 then (
           select array_agg(
                    round((select count(*) from r where r.valor = o.opcion)::numeric / total.n, 4)
                    order by o.orden)
           from consulta_preguntas c,
                unnest(c.opciones) with ordinality as o(opcion, orden)
           where c.id = p_consulta_pregunta_id
         ) end
  from total;
$$;
