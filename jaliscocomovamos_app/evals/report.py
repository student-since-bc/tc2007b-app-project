#!/usr/bin/env python3
"""Resume una corrida de promptfoo (JSON) por categoría y compara con evals/thresholds.yaml.
Uso: python3 evals/report.py evals/results/baseline.json
NOTA: la forma exacta del JSON cambia entre versiones de promptfoo; el script busca los campos de forma tolerante.
Probado solo con datos sintéticos (evals/report_selftest.py), no con una corrida real."""
import csv, json, sys, collections, os
import yaml

HERE = os.path.dirname(os.path.abspath(__file__))

def load_results(path):
    d = json.load(open(path, encoding='utf-8'))
    r = d.get('results', d)
    if isinstance(r, dict): r = r.get('results', [])
    return d, r

def row_vars(r):
    return r.get('vars') or (r.get('testCase') or {}).get('vars') or {}

def fig_rule_failed(r):
    comps = (r.get('gradingResult') or {}).get('componentResults') or []
    for c in comps:
        if str(c.get('reason', '')).startswith('[R1') and not c.get('pass', True): return True
    return False

def summarize(results, th):
    cases = {c['id']: c for c in csv.DictReader(open(os.path.join(HERE, 'cases.csv'), encoding='utf-8'))}
    per_case = collections.defaultdict(list)
    meta = {}
    cost = 0.0; lat = 0.0
    fig_total = fig_fail = 0
    for r in results:
        v = row_vars(r); cid = v.get('id') or v.get('__id')
        if cid not in cases: continue
        per_case[cid].append(bool(r.get('success')))
        meta[cid] = cases[cid]
        cost += float(r.get('cost') or 0); lat += float(r.get('latencyMs') or 0)
        fig_total += 1; fig_fail += fig_rule_failed(r)
    by_cat = collections.defaultdict(lambda: dict(runs=0, ok=0, cases=0, strict_ok=0))
    for cid, outs in per_case.items():
        c = by_cat[meta[cid]['category']]
        c['cases'] += 1; c['runs'] += len(outs); c['ok'] += sum(outs); c['strict_ok'] += all(outs)
    # consistencia de grupos de paráfrasis: en cada repetición todos los miembros deben pasar
    groups = collections.defaultdict(list)
    for cid, outs in per_case.items():
        g = meta[cid]['group']
        if g: groups[g].append(outs)
    gc_ok = gc_tot = 0
    for g, members in groups.items():
        k = min(len(m) for m in members)
        for rep in range(k):
            gc_tot += 1; gc_ok += all(m[rep] for m in members)
    return by_cat, (gc_ok, gc_tot), (fig_total, fig_fail), cost, lat, len(results)

def main(path):
    th = yaml.safe_load(open(os.path.join(HERE, 'thresholds.yaml'), encoding='utf-8'))
    d, results = load_results(path)
    by_cat, (gc_ok, gc_tot), (ft, ff), cost, lat, n = summarize(results, th)
    print('| Categoría | Casos | Corridas | Tasa de aprobación | pass^k | Umbral | Resultado |')
    print('|---|---|---|---|---|---|---|')
    for cat, t in th['categories'].items():
        c = by_cat.get(cat)
        if not c: print(f'| {cat} | 0 | 0 | — | — | {t["min_pass_rate"]:.0%} | sin casos |'); continue
        rate = c['ok'] / c['runs']; strict = c['strict_ok'] / c['cases']
        val = strict if t.get('strict_all_k') else rate
        print(f'| {cat} | {c["cases"]} | {c["runs"]} | {rate:.1%} | {strict:.1%} | {t["min_pass_rate"]:.0%}{" (pass^k)" if t.get("strict_all_k") else ""} | {"OK" if val >= t["min_pass_rate"] else "POR DEBAJO"} |')
    if gc_tot: print(f'\nConsistencia de grupos de paráfrasis: {gc_ok}/{gc_tot} = {gc_ok / gc_tot:.1%} (mín. {th["categories"]["paraphrase"]["group_consistency_min"]:.0%})')
    if ft: print(f'Regla transversal R1 (cifras con respaldo): {ft - ff}/{ft} = {(ft - ff) / ft:.1%} (mín. 100%)')
    print(f'Corridas: {n} | Costo total: ${cost:.4f} | Tiempo acumulado de latencia: {lat / 1000:.1f} s')

if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, 'results', 'baseline.json'))
