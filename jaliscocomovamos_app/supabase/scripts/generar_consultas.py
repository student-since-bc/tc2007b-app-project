"""
Genera supabase/03_consultas.sql a partir de la base de la
Encuesta de Bienestar de Jóvenes AMG 2026 (carpeta recursos/).

Solo sube porcentajes agregados (ponderados con FACTOR), nunca respuestas
individuales. Cada pregunta se calcula para Todos/Hombre/Mujer x
Todas/15-19/20-24/25-29; si un grupo tiene menos de MIN_N personas
se omite para no permitir reidentificación.

Uso (desde jaliscocomovamos_app/):
    python supabase/scripts/generar_consultas.py
"""
import csv
import json
import os
import re

AQUI = os.path.dirname(os.path.abspath(__file__))
RECURSOS = os.path.join(AQUI, '..', '..', '..', 'recursos')
SALIDA = os.path.join(AQUI, '..', '03_consultas.sql')

MIN_N = 30

# Temas de la encuesta (presentación JCV, p. 21) y sus variables, en orden.
TEMAS = [
    ('Bienestar subjetivo', ['Q_6', 'Q_7', 'Q_8', 'Q_9', 'Q_10', 'T_Q_11_']),
    ('Educación y trabajo', ['T_Q_13_', 'Q_14', 'Q_15', 'Q_16', 'Q_17', 'T_Q_18_', 'T_Q_19_']),
    ('Tiempo libre', ['Q_20', 'Q_21', 'Q_22', 'T_Q_23_', 'T_Q_24_', 'Q_25', 'Q_26', 'Q_28', 'Q_29_']),
    ('Hogar y familia', ['T_Q_12_', 'Q_30', 'Q_31', 'Q_32', 'Q_33', 'Q_34', 'Q_35']),
    ('Salud', ['Q_36', 'Q_37', 'Q_38', 'Q_39', 'Q_40', 'Q_41', 'Q_42']),
    ('Seguridad', ['T_Q_43_', 'T_Q_44_', 'Q_45', 'Q_46', 'Q_47', 'Q_48', 'Q_49', 'Q_50',
                   'T_Q_51_', 'Q_52', 'T_Q_53_']),
    ('Comunidad', ['Q_54', 'T_Q_55_', 'Q_56', 'T_Q_57_', 'T_Q_58_', 'T_Q_59_', 'T_Q_60_',
                   'Q_61', 'T_Q_62_', 'T_Q_63_', 'T_Q_64_', 'T_Q_65_', 'Q_66', 'Q_67', 'Q_68']),
    ('Transporte', ['Q_69', 'Q_70recode']),
]

# Títulos que no se pueden limpiar automáticamente
TITULOS = {
    'Q_33': '¿Qué tan satisfecha(o) estás con la casa en la que vives?',
    'Q_36': '¿Qué tan satisfecha(o) te sientes con tu salud?',
    # La etiqueta original viene cortada ("...Considerando es") en el
    # diccionario y en el libro de códigos. [CONFIRMAR] redacción con JCV.
    'Q_41': 'Considerando tu bienestar emocional, ¿cómo calificarías tu salud mental?',
}

GENEROS = {'Todos': None, 'Hombre': '1', 'Mujer': '2'}          # Q_71
EDADES = {'Todas': None, '15 a 19 años': '1', '20 a 24 años': '2', '25 a 29 años': '3'}  # Q_72recode

PREAMBULO = re.compile(
    r'^En una escala del 1 al 5, donde 1 (?:es|significa) "[^"]*" y 5 (?:es|significa) "[^"]*",\s*'
    r'(?:por favor dime,\s*)?(?:en general,\s*)?', re.I)


def variables_de(prefijo, dic):
    """'Q_6' -> ['Q_6']; 'T_Q_11_' -> ['T_Q_11_1', 'T_Q_11_2', ...] en orden."""
    if not prefijo.endswith('_'):
        return [prefijo]
    patron = re.compile(re.escape(prefijo) + r'\d+$')
    encontradas = [k for k in dic if patron.match(k)]
    return sorted(encontradas, key=lambda k: int(k.rsplit('_', 1)[1]))


def limpiar(texto):
    texto = texto.replace('[NO LEER]', '')  # instrucción para el encuestador
    texto = ' '.join(texto.replace('\t', ' ').split())
    # Mayúscula en la primera letra, aunque empiece con '¿'
    return re.sub(r'^([¿¡"]*)(\w)', lambda m: m.group(1) + m.group(2).upper(), texto)


def titulo_y_grupo(variables, dic):
    """Para baterías (T_Q_xx_n) separa el enunciado común del reactivo."""
    etiquetas = [dic[v]['etiqueta'] for v in variables]
    if len(etiquetas) == 1:
        return [(limpiar(PREAMBULO.sub('', etiquetas[0])), None)]
    comun = os.path.commonprefix(etiquetas)
    # Cortar el enunciado en el último signo de cierre antes del reactivo
    # (o en el último espacio si el enunciado no tiene puntuación)
    corte = max(comun.rfind('?'), comun.rfind(':'), comun.rfind('…'))
    comun = comun[:corte + 1] if corte >= 0 else comun[:comun.rfind(' ') + 1]
    grupo = limpiar(PREAMBULO.sub('', comun)) or None
    return [(limpiar(e[len(comun):]), grupo) for e in etiquetas]


def sql_texto(s):
    return 'null' if s is None else "'" + s.replace("'", "''") + "'"


def sql_arreglo(valores, es_texto):
    if es_texto:
        return 'array[' + ', '.join(sql_texto(v) for v in valores) + ']::text[]'
    return 'array[' + ', '.join(f'{v:.4f}' for v in valores) + ']::numeric[]'


def main():
    with open(os.path.join(RECURSOS, 'Bienestar_de_Jovenes_Jul-Ago_2026_diccionario.json'), encoding='utf-8') as f:
        dic = json.load(f)
    # El CSV conserva los códigos de "No sabe" (en el JSON quedaron vacíos);
    # -1 significa que la pregunta no se le hizo a esa persona.
    with open(os.path.join(RECURSOS, 'Base de Datos_Bienestar de Jovenes - Jul-Ago 2026.csv'), encoding='latin-1') as f:
        base = [{k: (None if v in ('', '-1') else v) for k, v in r.items()} for r in csv.DictReader(f)]
    for r in base:
        r['FACTOR'] = float(r['FACTOR'])

    preguntas, resultados = [], []
    for tema_orden, (tema, prefijos) in enumerate(TEMAS, start=1):
        orden = 0
        for prefijo in prefijos:
            variables = variables_de(prefijo, dic)
            assert variables, f'No existe {prefijo} en el diccionario'
            for var, (titulo, grupo) in zip(variables, titulo_y_grupo(variables, dic)):
                titulo = TITULOS.get(var, titulo)
                codigos = list(dic[var]['valores'].keys())
                opciones = [limpiar(dic[var]['valores'][c]) for c in codigos]
                orden += 1
                preguntas.append((var, tema, tema_orden, orden, grupo, titulo, opciones))

                for genero, g in GENEROS.items():
                    for edad, e in EDADES.items():
                        filas = [r for r in base
                                 if r.get(var) is not None
                                 and (g is None or r.get('Q_71') == g)
                                 and (e is None or r.get('Q_72recode') == e)]
                        if len(filas) < MIN_N:
                            continue
                        total = sum(r['FACTOR'] for r in filas)
                        pesos = {c: 0.0 for c in codigos}
                        for r in filas:
                            pesos[r[var]] += r['FACTOR']
                        porcentajes = [pesos[c] / total for c in codigos]
                        resultados.append((var, genero, edad, len(filas), porcentajes))

    with open(SALIDA, 'w', encoding='utf-8', newline='\n') as out:
        out.write('-- Generado por supabase/scripts/generar_consultas.py. No editar a mano.\n')
        out.write('-- Resultados agregados de la Encuesta de Bienestar de Jóvenes AMG 2026.\n')
        out.write('-- Se puede volver a correr: borra y recrea las tablas de consulta.\n\n')
        out.write(ESQUEMA)
        out.write('\ninsert into public.consulta_preguntas '
                  '(id, tema, tema_orden, orden, grupo, titulo, opciones) values\n')
        out.write(',\n'.join(
            f'  ({sql_texto(v)}, {sql_texto(t)}, {to}, {o}, {sql_texto(g)}, {sql_texto(ti)}, '
            f'{sql_arreglo(op, True)})'
            for v, t, to, o, g, ti, op in preguntas) + ';\n')
        out.write('\ninsert into public.consulta_resultados '
                  '(pregunta_id, genero, edad, n, porcentajes) values\n')
        out.write(',\n'.join(
            f'  ({sql_texto(v)}, {sql_texto(g)}, {sql_texto(e)}, {n}, {sql_arreglo(p, False)})'
            for v, g, e, n, p in resultados) + ';\n')

    print(f'{len(preguntas)} preguntas, {len(resultados)} resultados -> {os.path.normpath(SALIDA)}')


ESQUEMA = """drop table if exists public.consulta_resultados;
drop table if exists public.consulta_preguntas;

create table public.consulta_preguntas (
  id         text primary key,           -- variable del cuestionario, ej. 'Q_6'
  tema       text not null,
  tema_orden int  not null,
  orden      int  not null,              -- orden dentro del tema
  grupo      text,                       -- enunciado común de una batería
  titulo     text not null,
  opciones   text[] not null
);

-- Un renglón por pregunta x población x género x edad.
-- porcentajes[i] corresponde a opciones[i] (fracción de 0 a 1, ponderada).
create table public.consulta_resultados (
  pregunta_id text not null references public.consulta_preguntas(id) on delete cascade,
  poblacion   text not null default 'AMG' check (poblacion in ('AMG', 'TEC')),
  genero      text not null,              -- 'Todos' | 'Hombre' | 'Mujer'
  edad        text not null,              -- 'Todas' | '15 a 19 años' | ...
  n           int  not null,              -- personas encuestadas en el grupo
  porcentajes numeric[] not null,
  primary key (pregunta_id, poblacion, genero, edad)
);

alter table public.consulta_preguntas  enable row level security;
alter table public.consulta_resultados enable row level security;

-- Libre consulta: cualquiera puede leer (incluso sin iniciar sesión)
create policy "leer consulta_preguntas" on public.consulta_preguntas
  for select to anon, authenticated using (true);
create policy "leer consulta_resultados" on public.consulta_resultados
  for select to anon, authenticated using (true);

-- Ya no se usan (eran los datos de ejemplo por municipio)
drop table if exists public.indicador_datos;
drop table if exists public.indicadores;
"""

if __name__ == '__main__':
    main()
