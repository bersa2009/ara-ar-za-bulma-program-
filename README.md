# Strcar – Universal OBD/ELM Diagnostic App

## Setup
- Install Flutter SDK
- Run:
```bash
flutter pub get
flutter test
```

## Permissions
- Android 12+: BLUETOOTH_SCAN, BLUETOOTH_CONNECT
- Location (BLE scan on Android)
- iOS: Bluetooth (BLE) usage description, Local network (for WiFi adapters)

## Devices (recommended)
- BLE: Vgate iCar Pro BLE, OBDLink MX+
- Classic (Android): Vgate iCar Pro BT 3.0, BAFX
- WiFi: OBDLink MX WiFi, generic ELM327 mini

## Legal & Safety
- Do not use the app while driving.
- Data privacy: Reports stored locally. See `LEGAL.md` for details.

## DTC Seeds
- Maintain `assets/dtc_seed_en.json` and `assets/dtc_seed_tr.json`.
- Edit with CSV: see `tools/dtc_seed_template.csv` and run converter:
```bash
dart tools/convert_csv_to_json.dart tools/dtc_seed_template.csv assets/
```

## Beta
- Android: Internal Testing track (Play Console)
- iOS: TestFlight