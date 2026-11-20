"""Prueba del reporte con datos SINTÉTICOS (no son resultados del producto)."""
import csv, json, os, random, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
rows = list(csv.DictReader(open(os.path.join(HERE, 'cases.csv'), encoding='utf-8')))
random.seed(1)
res = []
for r in rows:
    for k in range(3):
        ok = random.random() < 0.9
        comps = [{'pass': ok, 'reason': '[R1 cifras] x'}]
        res.append({'vars': {'id': r['id']}, 'success': ok, 'cost': 0.001, 'latencyMs': 800, 'gradingResult': {'componentResults': comps}})
p = '/tmp/synthetic.json'; json.dump({'results': {'results': res}}, open(p, 'w'))
print(subprocess.run([sys.executable, os.path.join(HERE, 'report.py'), p], capture_output=True, text=True).stdout)
