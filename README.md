# Strcar – Universal OBD/ELM Diagnostic App

## Setup
- Install Flutter SDK
- Run:
```bash
flutter pub get
flutter test
```

### Import 10k+ DTC seeds
Fill `tools/dtc_seed_template.csv` (TR/EN original content, manufacturer required) and convert:
```bash
dart tools/convert_csv_to_json.dart tools/dtc_seed_template.csv assets/
```
On first run, the app seeds the SQLite DB. For very large datasets, allow time for seeding.

## Permissions
- Android 12+: BLUETOOTH_SCAN, BLUETOOTH_CONNECT
- Location (BLE scan on Android)
- iOS: Bluetooth (BLE) usage description, Local network (for WiFi adapters)

## Devices (recommended)
- BLE: Vgate iCar Pro BLE, OBDLink MX+, Panlong BLE
- Classic (Android): Vgate iCar Pro BT 3.0, BAFX
- WiFi: OBDLink MX WiFi, generic ELM327 mini

### Compatibility Matrix (target)
| Transport | Brand examples |
| --- | --- |
| BLE | Vgate iCar Pro BLE, OBDLink MX+, Panlong |
| Classic (Android) | Vgate iCar Pro BT 3.0, BAFX |
| WiFi | OBDLink MX WiFi, ELM327 mini WiFi |

## Legal & Safety
- Do not use the app while driving.
- Data privacy: Reports stored locally. See `LEGAL.md` for details.

## DTC Seeds
- Maintain `assets/dtc_seed_en.json` and `assets/dtc_seed_tr.json`.
- Edit with CSV: see `tools/dtc_seed_template.csv` and run converter:
```bash
dart tools/convert_csv_to_json.dart tools/dtc_seed_template.csv assets/
# manufacturer is required by default; to relax:
# dart tools/convert_csv_to_json.dart tools/dtc_seed_template.csv assets/ --no-require-manufacturer
```

### Generate 10k+ DTCs (templated)
```bash
dart tools/generate_sae_dtc.dart --out-csv tools/dtc_seed_template.csv --langs en,tr \
  --include-manufacturers toyota,vw,ford,bmw,mercedes --target-count 10000
dart tools/convert_csv_to_json.dart tools/dtc_seed_template.csv assets/
```

### Import vendor datasets (Launch/Delphi/Bosch/Autel/Thinktool/DDT4All/PyRen)
```bash
python3 tools/import_vendor_dtc.py --in vendor_delphi.csv vendor_bosch.json \
  --out-csv tools/dtc_seed_template.csv --manufacturer delphi --lang en --append
dart tools/convert_csv_to_json.dart tools/dtc_seed_template.csv assets/
```
Note: Ensure you respect original licenses of vendor datasets. The app seeds from JSON; use `--require-manufacturer` (default) to keep provenance.

After conversion, the app will seed the SQLite DB on first run. For very large seed files (10k+), initial seeding may take a minute on older devices.

## Features
- **Welcome Screen**: Guided setup with Bluetooth/Wi-Fi connection, vehicle selection, and OBD device scanning
- Universal DTC read (03/07/0A) and clear (04)
- VIN read (09-02) and brand hint via WMI
- BLE/Classic/WiFi transports
- Local DTC DB (TR/EN) with titles/descriptions/causes/fixes
- PDF export and TTS reading
- Vehicle information persistence across app sessions

## Beta
- Android: Internal Testing track (Play Console)
- iOS: TestFlight