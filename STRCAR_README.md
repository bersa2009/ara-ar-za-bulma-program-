# Strcar - OBD-II Diagnostic Application

## Overview
Strcar is a comprehensive OBD-II diagnostic application built with Flutter that provides advanced vehicle diagnostics, real-time monitoring, and maintenance tracking capabilities.

## Features Implemented

### 🔹 1. Arıza Tespiti (Fault Detection)
- ECU fault code (DTC) reading and clearing
- Displays found faults in a list format
- Example: P0300 – Random Cylinder Misfire
- Clear fault codes functionality with confirmation

### 🔹 2. Canlı Veri (Live Data)
- Real-time parameters from engine, transmission, and sensors
- Parameters include: RPM, speed, fuel pressure, engine temperature, O₂ sensor values
- Presented with graphics and tabular views
- Color-coded indicators based on value ranges

### 🔹 3. Sensör Bilgisi (Sensor Information)
- Real-time status of all vehicle sensors
- Sensors include: ABS, lambda, MAP, MAF, TPS, ECT, IAT, etc.
- Non-working/faulty sensors are clearly marked
- Detailed sensor information and descriptions

### 🔹 4. Yapay Zeka (AI Analysis)
- Analyzes fault codes and provides solution recommendations
- Predicts recurring faults based on historical data
- Statistics showing:
  - "Most common fault"
  - "Most recommended solution"
- Confidence levels and estimated repair costs

### 🔹 5. Batarya Testi (Battery Test)
- Measures battery voltage, charge status, alternator performance
- Battery life estimation
- Warns user about weak batteries
- Progressive test simulation with real-time feedback

### 🔹 6. Km Bakım (Mileage Maintenance)
- Mileage-based maintenance calendar
- Examples:
  - 10,000 km → Oil change
  - 20,000 km → Air filter replacement
- Notifications for upcoming maintenance
- Track overdue and upcoming services

### 🔹 7. Araç Kimlik No (VIN Decoder)
- Reads VIN number from OBD or manual input
- Retrieves vehicle information: model, year, engine type, manufacturing location
- Additional: Service records and recall information display
- Comprehensive vehicle feature listing

### 🔹 8. Hataları Kaydet (Save Reports)
- Saves DTC and sensor data as reports
- Historical reports can be exported as PDF/Excel
- Creates service history
- Report management with filtering and search

### 🔹 9. Güncelleme (Updates)
- Updates application database and code library
- Downloads new DTC codes, maintenance recommendations, sensor lists
- Application version update checking
- Component-wise update management

## Bottom Navigation Menu
- **Ana Menü**: Return to home screen
- **Performans**: Speed, torque, power reports from live data
- **Raporlar**: List of historical reports from Save Reports section
- **Ayarlar**: Language selection, about, support/suggestions

## UI/UX Design
- **Theme**: Dark background with red accents (Strcar brand colors)
- **Icons**: Minimal, Material Icons compatible
- **Mobile Responsive**: Card layout, fixed bottom bar
- **Colors**: 
  - Primary Red: #8B1538
  - Dark Background: #2C2C54
  - Card Background: #1E1E2F

## Technical Implementation

### Architecture
- **Framework**: Flutter with Dart
- **State Management**: Riverpod
- **Navigation**: Named routes with MaterialApp
- **Theme**: Material 3 with custom color scheme
- **Localization**: Turkish and English support

### Key Components
- Modular screen architecture
- Reusable UI components
- Mock data for demonstration
- Responsive design patterns
- Error handling and user feedback

### File Structure
```
lib/
├── core/
│   ├── app_settings.dart          # App configuration and settings
│   ├── connection_manager.dart    # OBD connection management
│   └── permissions.dart           # Device permissions
├── data/
│   ├── app_database.dart          # Local database
│   └── dtc_repository.dart        # DTC code repository
├── elm/                           # ELM327 OBD communication
├── ui/
│   ├── screens/                   # All application screens
│   │   ├── home_screen.dart       # Main menu with bottom navigation
│   │   ├── fault_detection_screen.dart
│   │   ├── live_data_screen.dart
│   │   ├── sensor_info_screen.dart
│   │   ├── ai_analysis_screen.dart
│   │   ├── battery_test_screen.dart
│   │   ├── maintenance_screen.dart
│   │   ├── vin_screen.dart
│   │   ├── save_reports_screen.dart
│   │   └── update_screen.dart
│   ├── theme.dart                 # App theming
│   └── widgets/                   # Reusable widgets
└── main.dart                      # App entry point
```

### Dependencies
- flutter_riverpod: State management
- flutter_reactive_ble: Bluetooth communication
- sqflite: Local database
- pdf: Report generation
- shared_preferences: Settings storage
- permission_handler: Device permissions

## Features Highlights

### Real-time Simulation
- Live data streaming with realistic automotive parameters
- Progressive test simulations (battery test, sensor scanning)
- Dynamic color coding based on parameter ranges

### User Experience
- Intuitive navigation with bottom tab bar
- Contextual help and descriptions
- Confirmation dialogs for destructive actions
- Progress indicators for long-running operations
- Snackbar notifications for user feedback

### Data Management
- Mock diagnostic reports with realistic automotive data
- Historical data tracking and management
- Export functionality (PDF/Excel simulation)
- Service history maintenance

### Accessibility
- Colorblind-friendly theme options
- Clear visual indicators and status badges
- Descriptive text and help information
- Responsive design for different screen sizes

## Getting Started

1. Ensure Flutter is installed and configured
2. Run `flutter pub get` to install dependencies
3. Connect an Android device or start an emulator
4. Run `flutter run` to start the application

## Mock Data
The application uses realistic mock data to demonstrate all features:
- Sample DTC codes (P0300, P0171, P0420, etc.)
- Realistic sensor values and ranges
- Maintenance schedules based on actual automotive intervals
- Vehicle information for Renault Clio 2018

## Future Enhancements
- Real OBD-II hardware integration
- Cloud-based report synchronization
- Advanced AI diagnostics
- Multi-vehicle support
- Mechanic shop integration

---

**Note**: This is a demonstration application with simulated OBD-II functionality. For production use, integrate with actual ELM327 or similar OBD-II adapters.