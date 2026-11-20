-- ===========================================================================
-- Jalisco Cómo Vamos · Esquema de la base de datos
-- Se corre UNA vez en Supabase → SQL Editor (pegar todo y dar "Run").
--
-- Idea central de privacidad:
--   * participaciones  -> QUIÉN ya contestó una encuesta (sin sus respuestas)
--   * envios/respuestas -> QUÉ se contestó (sin saber quién)
--   No hay ninguna columna que una las dos cosas, y nadie (ni el admin)
--   puede leer respuestas individuales: solo resultados agregados mediante
--   la función resultados_encuesta(), que respeta el umbral de 100.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Datos públicos de Jalisco Cómo Vamos (pantalla Datos, RF-1.x)
-- ---------------------------------------------------------------------------
create table public.indicadores (
  id          text primary key,              -- ej. 'seguridad_percepcion'
  tema        text not null,                 -- ej. 'Seguridad'
  nombre      text not null,
  unidad      text not null,                 -- ej. 'porcentaje'
  fuente      text,
  actualizado date
);

create table public.indicador_datos (
  indicador_id text not null references public.indicadores(id) on delete cascade,
  municipio    text not null,
  periodo      text not null,                -- ej. '2025'
  valor        numeric not null,
  primary key (indicador_id, municipio, periodo)
);


-- ---------------------------------------------------------------------------
-- Usuarios y grupos (RF-3.2)
-- ---------------------------------------------------------------------------
create table public.perfiles (
  id     uuid primary key references auth.users(id) on delete cascade,
  correo text not null,
  rol    text not null default 'estudiante' check (rol in ('estudiante', 'admin'))
);

create table public.grupos (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null unique,
  descripcion text
);

create table public.grupo_miembros (
  grupo_id uuid not null references public.grupos(id) on delete cascade,
  user_id  uuid not null references public.perfiles(id) on delete cascade,
  primary key (grupo_id, user_id)
);


-- ---------------------------------------------------------------------------
-- Encuestas y preguntas (RF-2.x, RF-3.x)
-- ---------------------------------------------------------------------------
create table public.encuestas (
  id          uuid primary key default gen_random_uuid(),
  titulo      text not null,
  descripcion text,
  estado      text not null default 'borrador'
              check (estado in ('borrador', 'publicada', 'cerrada')),
  apertura    date,
  cierre      date,
  creada      timestamptz not null default now()
);

create table public.encuesta_grupos (
  encuesta_id uuid not null references public.encuestas(id) on delete cascade,
  grupo_id    uuid not null references public.grupos(id) on delete cascade,
  primary key (encuesta_id, grupo_id)
);

create table public.preguntas (
  id           uuid primary key default gen_random_uuid(),
  encuesta_id  uuid not null references public.encuestas(id) on delete cascade,
  orden        int  not null,
  tipo         text not null check (tipo in
               ('opcion_unica', 'opcion_multiple', 'escala', 'numero', 'si_no')),
  texto        text not null,
  opciones     text[],                       -- solo opcion_unica / opcion_multiple
  min          numeric,                      -- escala, numero, o mínimo de opciones
  max          numeric,                      -- escala, numero, o máximo de opciones
  etiqueta_min text,                         -- escala
  etiqueta_max text,                         -- escala
  unidad       text,                         -- numero (ej. 'minutos')
  obligatoria  boolean not null default true
);


-- ---------------------------------------------------------------------------
-- Respuestas (anónimas)
-- ---------------------------------------------------------------------------
-- Solo registra que el usuario ya contestó (para no dejarlo contestar dos veces).
create table public.participaciones (
  encuesta_id uuid not null references public.encuestas(id) on delete cascade,
  user_id     uuid not null references public.perfiles(id) on delete cascade,
  primary key (encuesta_id, user_id)
);

-- Un envío = un cuestionario contestado. Sin user_id y sin hora, a propósito,
-- para que no se pueda cruzar con participaciones.
create table public.envios (
  id          uuid primary key default gen_random_uuid(),
  encuesta_id uuid not null references public.encuestas(id) on delete cascade
);

-- Una fila por valor elegido (opción múltiple genera varias filas).
create table public.respuestas (
  envio_id    uuid not null references public.envios(id) on delete cascade,
  pregunta_id uuid not null references public.preguntas(id) on delete cascade,
  valor       text not null
);

create index on public.respuestas (pregunta_id);
create index on public.envios (encuesta_id);


-- ===========================================================================
-- Funciones
-- ===========================================================================

-- ¿El usuario actual es administrador?
create function public.es_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from perfiles where id = auth.uid() and rol = 'admin');
$$;

-- Crea el perfil automáticamente cuando alguien inicia sesión por primera vez.
-- Los correos @tec.mx entran solos al grupo "Todos los estudiantes".
create function public.crear_perfil()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  insert into perfiles (id, correo) values (new.id, new.email);
  if new.email ilike '%@tec.mx' then
    insert into grupo_miembros (grupo_id, user_id)
    select id, new.id from grupos where nombre = 'Todos los estudiantes';
  end if;
  return new;
end;
$$;

create trigger al_crear_usuario
  after insert on auth.users
  for each row execute function public.crear_perfil();

-- Enviar una encuesta contestada. Desde Flutter:
--   await supabase.rpc('enviar_respuestas', params: {
--     'p_encuesta_id': encuestaId,
--     'p_respuestas': [
--       {'pregunta_id': '...', 'valores': ['Bicicleta']},
--       {'pregunta_id': '...', 'valores': ['Baches', 'Basura']},
--     ],
--   });
create function public.enviar_respuestas(p_encuesta_id uuid, p_respuestas jsonb)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_envio uuid;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión para contestar';
  end if;

  if not exists (
    select 1 from encuestas
    where id = p_encuesta_id
      and estado = 'publicada'
      and current_date between apertura and cierre
  ) then
    raise exception 'La encuesta no está abierta';
  end if;

  if not exists (
    select 1 from encuesta_grupos eg
    join grupo_miembros gm on gm.grupo_id = eg.grupo_id
    where eg.encuesta_id = p_encuesta_id and gm.user_id = auth.uid()
  ) then
    raise exception 'Esta encuesta no está asignada a tu grupo';
  end if;

  -- Todas las preguntas obligatorias tienen al menos un valor
  if exists (
    select 1 from preguntas p
    where p.encuesta_id = p_encuesta_id and p.obligatoria
      and not exists (
        select 1 from jsonb_array_elements(p_respuestas) x
        where (x->>'pregunta_id')::uuid = p.id
          and jsonb_array_length(x->'valores') > 0
      )
  ) then
    raise exception 'Faltan preguntas obligatorias';
  end if;

  -- Cada valor es válido para el tipo de su pregunta
  if exists (
    select 1
    from jsonb_array_elements(p_respuestas) x
    left join preguntas p
      on p.id = (x->>'pregunta_id')::uuid and p.encuesta_id = p_encuesta_id
    where p.id is null
       or (p.tipo <> 'opcion_multiple' and jsonb_array_length(x->'valores') > 1)
       or (p.tipo = 'opcion_multiple'
           and jsonb_array_length(x->'valores') > coalesce(p.max, 999))
       or exists (
         select 1 from jsonb_array_elements_text(x->'valores') v(val)
         where not coalesce(case p.tipo
           when 'opcion_unica'    then val = any(p.opciones)
           when 'opcion_multiple' then val = any(p.opciones)
           when 'si_no'           then val in ('Sí', 'No')
           when 'escala'  then case when val ~ '^[0-9]+$'
                                    then val::int between p.min and p.max end
           when 'numero'  then case when val ~ '^[0-9]+(\.[0-9]+)?$'
                                    then val::numeric between coalesce(p.min, val::numeric)
                                                          and coalesce(p.max, val::numeric) end
         end, false)
       )
  ) then
    raise exception 'Hay respuestas inválidas';
  end if;

  insert into participaciones (encuesta_id, user_id)
  values (p_encuesta_id, auth.uid())
  on conflict do nothing;
  if not found then
    raise exception 'Ya contestaste esta encuesta';
  end if;

  insert into envios (encuesta_id) values (p_encuesta_id) returning id into v_envio;

  insert into respuestas (envio_id, pregunta_id, valor)
  select v_envio, (x->>'pregunta_id')::uuid, val
  from jsonb_array_elements(p_respuestas) x
  cross join lateral jsonb_array_elements_text(x->'valores') v(val);
end;
$$;

-- Cuántas personas han contestado (siempre se puede consultar).
create function public.total_respuestas(p_encuesta_id uuid)
returns bigint
language sql stable security definer set search_path = public
as $$
  select count(*) from envios where encuesta_id = p_encuesta_id;
$$;

-- Conteos por pregunta y valor. Si hay menos de 100 respuestas no regresa
-- nada (la app muestra Textos.mensajeUmbral).
create function public.resultados_encuesta(p_encuesta_id uuid)
returns table (pregunta_id uuid, valor text, conteo bigint)
language sql stable security definer set search_path = public
as $$
  select r.pregunta_id, r.valor, count(*)
  from respuestas r
  join envios e on e.id = r.envio_id
  where e.encuesta_id = p_encuesta_id
    and (select count(*) from envios where encuesta_id = p_encuesta_id) >= 100
    and exists (select 1 from encuestas where id = p_encuesta_id and estado <> 'borrador')
  group by r.pregunta_id, r.valor;
$$;

revoke execute on function public.enviar_respuestas(uuid, jsonb) from public, anon;
revoke execute on function public.crear_perfil() from public, anon, authenticated;


-- ===========================================================================
-- Seguridad (Row Level Security)
-- Sin una política explícita, nadie puede leer ni escribir la tabla.
-- ===========================================================================
alter table public.indicadores      enable row level security;
alter table public.indicador_datos  enable row level security;
alter table public.perfiles         enable row level security;
alter table public.grupos           enable row level security;
alter table public.grupo_miembros   enable row level security;
alter table public.encuestas        enable row level security;
alter table public.encuesta_grupos  enable row level security;
alter table public.preguntas        enable row level security;
alter table public.participaciones  enable row level security;
alter table public.envios           enable row level security;  -- sin políticas: nadie
alter table public.respuestas       enable row level security;  -- sin políticas: nadie

-- Datos públicos: cualquiera los lee (incluso visitantes sin sesión)
create policy "leer indicadores" on public.indicadores
  for select to anon, authenticated using (true);
create policy "admin edita indicadores" on public.indicadores
  for all to authenticated using (es_admin()) with check (es_admin());

create policy "leer datos de indicadores" on public.indicador_datos
  for select to anon, authenticated using (true);
create policy "admin edita datos de indicadores" on public.indicador_datos
  for all to authenticated using (es_admin()) with check (es_admin());

-- Perfiles: cada quien ve el suyo; solo el admin cambia roles
create policy "ver perfil propio" on public.perfiles
  for select to authenticated using (id = auth.uid() or es_admin());
create policy "admin edita perfiles" on public.perfiles
  for update to authenticated using (es_admin()) with check (es_admin());

-- Grupos
create policy "leer grupos" on public.grupos
  for select to authenticated using (true);
create policy "admin edita grupos" on public.grupos
  for all to authenticated using (es_admin()) with check (es_admin());

create policy "ver mis grupos" on public.grupo_miembros
  for select to authenticated using (user_id = auth.uid() or es_admin());
create policy "admin asigna grupos" on public.grupo_miembros
  for all to authenticated using (es_admin()) with check (es_admin());

-- Encuestas: el estudiante ve las publicadas/cerradas de sus grupos
create policy "ver encuestas" on public.encuestas
  for select to authenticated using (
    es_admin() or (
      estado <> 'borrador' and exists (
        select 1 from encuesta_grupos eg
        join grupo_miembros gm on gm.grupo_id = eg.grupo_id
        where eg.encuesta_id = encuestas.id and gm.user_id = auth.uid()
      )
    )
  );
create policy "admin edita encuestas" on public.encuestas
  for all to authenticated using (es_admin()) with check (es_admin());

create policy "leer encuesta_grupos" on public.encuesta_grupos
  for select to authenticated using (true);
create policy "admin edita encuesta_grupos" on public.encuesta_grupos
  for all to authenticated using (es_admin()) with check (es_admin());

-- Preguntas: visibles si puedes ver su encuesta
create policy "ver preguntas" on public.preguntas
  for select to authenticated using (
    exists (select 1 from encuestas e where e.id = preguntas.encuesta_id)
  );
create policy "admin edita preguntas" on public.preguntas
  for all to authenticated using (es_admin()) with check (es_admin());

-- Participaciones: solo ves las tuyas (para marcar "ya contestada")
create policy "ver mis participaciones" on public.participaciones
  for select to authenticated using (user_id = auth.uid());
