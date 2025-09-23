#!/usr/bin/env python3
import argparse
import csv
import json
import os
import sys
from typing import List, Dict, Any


def parse_args():
    p = argparse.ArgumentParser(description='Import vendor DTC datasets and merge into Strcar seed CSV')
    p.add_argument('--in', dest='inputs', nargs='+', required=True, help='Input files (CSV or JSON)')
    p.add_argument('--out-csv', required=True, help='Output CSV path (append or create)')
    p.add_argument('--manufacturer', required=True, help='Manufacturer slug (e.g., toyota, volkswagen, delphi, bosch, launch, autel, thinktool, ddt4all, pyren)')
    p.add_argument('--lang', default='en', choices=['en', 'tr'], help='Language of provided descriptions')
    p.add_argument('--code-field', default='code', help='Field name for DTC code in vendor files')
    p.add_argument('--desc-field', default='description', help='Field name for description')
    p.add_argument('--causes-field', default='causes', help='Field name for causes (string; ";" separated)')
    p.add_argument('--fixes-field', default='fixes', help='Field name for fixes (string; ";" separated)')
    p.add_argument('--system', default=None, help='Override system (Powertrain/Body/Chassis/Network). If omitted, inferred by code prefix (P/B/C/U)')
    p.add_argument('--license', default='Imported vendor content - check original license', help='License note to include')
    p.add_argument('--append', action='store_true', help='Append to existing CSV instead of overwriting')
    return p.parse_args()


def read_vendor_file(path: str) -> List[Dict[str, Any]]:
    ext = os.path.splitext(path)[1].lower()
    rows = []
    if ext == '.json':
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, dict) and 'rows' in data:
                data = data['rows']
            if isinstance(data, list):
                rows = data
    elif ext == '.csv':
        with open(path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            rows = list(reader)
    else:
        print(f'Skipping unsupported file: {path}', file=sys.stderr)
    return rows


def infer_system_from_code(code: str) -> str:
    if not code:
        return 'Powertrain'
    c = code.strip().upper()[:1]
    return {
        'P': 'Powertrain',
        'B': 'Body',
        'C': 'Chassis',
        'U': 'Network',
    }.get(c, 'Powertrain')


def normalize_code(code: str) -> str:
    code = (code or '').strip().upper()
    # ensure like P0123
    if len(code) >= 2 and code[1].isdigit():
        # pad numeric tail to 4
        head = code[0]
        tail = ''.join(ch for ch in code[1:] if ch.isalnum())
        if tail.isdigit():
            tail = tail.zfill(4)
            return head + tail
    return code


def merge_rows(inputs: List[str], args) -> List[Dict[str, str]]:
    seen_codes = set()
    out: List[Dict[str, str]] = []
    for path in inputs:
        for row in read_vendor_file(path):
            code = normalize_code(str(row.get(args.code_field, '')))
            if not code:
                continue
            system = args.system or infer_system_from_code(code)
            desc = str(row.get(args.desc_field, '')).strip()
            causes = str(row.get(args.causes_field, '')).strip()
            fixes = str(row.get(args.fixes_field, '')).strip()
            csv_row = {
                'code': code,
                'system': system,
                'manufacturer': args.manufacturer,
                'title_en': desc if args.lang == 'en' else '',
                'description_en': desc if args.lang == 'en' else '',
                'causes_en': causes if args.lang == 'en' else '',
                'fixes_en': fixes if args.lang == 'en' else '',
                'title_tr': desc if args.lang == 'tr' else '',
                'description_tr': desc if args.lang == 'tr' else '',
                'causes_tr': causes if args.lang == 'tr' else '',
                'fixes_tr': fixes if args.lang == 'tr' else '',
                'license': args.license,
            }
            key = (csv_row['manufacturer'], code)
            if key in seen_codes:
                continue
            seen_codes.add(key)
            out.append(csv_row)
    return out


def write_csv(rows: List[Dict[str, str]], out_csv: str, append: bool):
    headers = ['code','system','manufacturer','title_en','description_en','causes_en','fixes_en','title_tr','description_tr','causes_tr','fixes_tr','license']
    mode = 'a' if append and os.path.exists(out_csv) else 'w'
    write_header = not append or not os.path.exists(out_csv)
    with open(out_csv, mode, newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=headers)
        if write_header:
            w.writeheader()
        for r in rows:
            w.writerow(r)


def main():
    args = parse_args()
    rows = merge_rows(args.inputs, args)
    if not rows:
        print('No rows imported', file=sys.stderr)
        sys.exit(2)
    write_csv(rows, args.out_csv, args.append)
    print(f'Imported {len(rows)} rows into {args.out_csv}')


if __name__ == '__main__':
    main()

