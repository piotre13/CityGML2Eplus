import csv
import logging
import os

logger = logging.getLogger(__name__)

_DEFAULTS = {
    'u_wall': 0.6, 'u_roof': 0.4, 'u_ground': 0.5,
    'u_window': 2.0, 'g_window': 0.6,
}


class ArchetypeTable:
    def __init__(self, path: str):
        self._rows = []
        ext = os.path.splitext(path)[1].lower()
        if ext == '.csv':
            self._load_csv(path)
        elif ext in ('.xlsx', '.xls'):
            self._load_xlsx(path)
        else:
            raise ValueError(f"Unsupported archetype file type: {ext}")
        logger.debug("Loaded %d archetype rows from %s", len(self._rows), path)

    def _parse_row(self, raw: dict) -> dict:
        func = str(raw.get('function', '') or '').strip().lower()
        if not func or func.startswith('#'):
            return None
        vm = raw.get('vintage_min', '') or ''
        vx = raw.get('vintage_max', '') or ''
        return {
            'function': func,
            'vintage_min': int(str(vm).strip()) if str(vm).strip() else 0,
            'vintage_max': int(str(vx).strip()) if str(vx).strip() else 9999,
            'weight': str(raw.get('weight', '') or '').strip().lower(),
            'u_wall': float(raw.get('u_wall') or _DEFAULTS['u_wall']),
            'u_roof': float(raw.get('u_roof') or _DEFAULTS['u_roof']),
            'u_ground': float(raw.get('u_ground') or _DEFAULTS['u_ground']),
            'u_window': float(raw.get('u_window') or _DEFAULTS['u_window']),
            'g_window': float(raw.get('g_window') or _DEFAULTS['g_window']),
        }

    def _load_csv(self, path: str):
        with open(path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(
                (line for line in f if not line.lstrip().startswith('#'))
            )
            for raw in reader:
                row = self._parse_row(raw)
                if row:
                    self._rows.append(row)

    def _load_xlsx(self, path: str):
        try:
            import openpyxl
        except ImportError:
            raise ImportError("openpyxl required for .xlsx: pip install openpyxl")
        wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
        ws = wb.active
        rows = ws.iter_rows(values_only=True)
        headers = [str(h or '').strip() for h in next(rows)]
        for vals in rows:
            raw = dict(zip(headers, vals))
            row = self._parse_row(raw)
            if row:
                self._rows.append(row)

    def lookup(self, function: str, year: int, weight: str) -> dict:
        func = (function or 'residential').lower()
        wt = (weight or '').lower()
        yr = year if year else 1970

        candidates = [r for r in self._rows if r['vintage_min'] <= yr <= r['vintage_max']]
        if not candidates:
            candidates = list(self._rows)

        if not candidates:
            logger.warning(
                "Empty archetype table; using built-in defaults for function=%s year=%d weight=%s",
                function, year, weight,
            )
            return dict(_DEFAULTS)

        def score(r):
            s = 0
            if func in r['function'] or r['function'] in func:
                s += 2
            if wt and wt == r['weight']:
                s += 1
            return s

        best_score = max(score(r) for r in candidates)
        best = next(r for r in candidates if score(r) == best_score)
        if best_score == 0:
            logger.warning(
                "No matching archetype for function=%s year=%d weight=%s; using nearest row",
                function, year, weight,
            )
        return dict(best)
