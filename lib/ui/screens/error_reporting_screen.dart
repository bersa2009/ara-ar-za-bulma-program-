import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/connection_manager.dart';
import '../../data/dtc_repository.dart';

class ErrorReportingScreen extends ConsumerStatefulWidget {
  const ErrorReportingScreen({super.key});

  @override
  ConsumerState<ErrorReportingScreen> createState() => _ErrorReportingScreenState();
}

class _ErrorReportingScreenState extends ConsumerState<ErrorReportingScreen> {
  final DtcRepository _dtcRepository = DtcRepository();
  List<Map<String, dynamic>> _savedReports = [];
  bool _isGenerating = false;
  bool _isConnected = false;

  // Mock reports for demonstration
  final List<Map<String, dynamic>> _mockReports = [
    {
      'id': '1',
      'title': 'Genel Tanı Raporu - 15.01.2024',
      'date': '2024-01-15',
      'type': 'Genel',
      'faultCount': 3,
      'mileage': 85000,
    },
    {
      'id': '2',
      'title': 'Batarya Test Raporu - 10.01.2024',
      'date': '2024-01-10',
      'type': 'Batarya',
      'faultCount': 0,
      'mileage': 84500,
    },
    {
      'id': '3',
      'title': 'Sensör Kontrolü - 05.01.2024',
      'date': '2024-01-05',
      'type': 'Sensör',
      'faultCount': 1,
      'mileage': 84200,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedReports();
    _checkConnection();
  }

  void _checkConnection() {
    final elmClient = ref.read(elmClientProvider);
    setState(() {
      _isConnected = elmClient != null;
    });
  }

  Future<void> _loadSavedReports() async {
    // Load saved reports from storage
    setState(() {
      _savedReports = _mockReports;
    });
  }

  Future<void> _generateDiagnosticReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Collect comprehensive diagnostic data
      final reportData = await _collectDiagnosticData();

      // Generate PDF report
      final pdfFile = await _createPdfReport(reportData);

      // Save report to history
      await _saveReportToHistory(reportData, pdfFile.path);

      setState(() {
        _isGenerating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapor başarıyla oluşturuldu')),
      );

      // Show sharing options
      _showReportOptions(pdfFile);
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor oluşturma hatası: ${e.toString()}')),
      );
    }
  }

  Future<Map<String, dynamic>> _collectDiagnosticData() async {
    final reportData = {
      'timestamp': DateTime.now(),
      'vehicleInfo': await _getVehicleInfo(),
      'faultCodes': await _getCurrentFaults(),
      'sensorData': await _getSensorData(),
      'batteryInfo': await _getBatteryInfo(),
      'maintenanceInfo': await _getMaintenanceInfo(),
    };

    return reportData;
  }

  Future<Map<String, dynamic>> _getVehicleInfo() async {
    return {
      'make': 'Renault',
      'model': 'Clio',
      'year': '2018',
      'vin': 'VF1RFD00612345678',
      'mileage': 85000,
    };
  }

  Future<List<Map<String, dynamic>>> _getCurrentFaults() async {
    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return [];

      // Read current DTC codes
      final response = await elmClient.sendCommand('03');
      final faultCodes = _parseFaultCodes(response);

      // Get detailed information for each fault
      final faults = <Map<String, dynamic>>[];
      for (final code in faultCodes) {
        final dtcInfo = await _dtcRepository.getDtc(code, lang: 'tr');
        if (dtcInfo != null) {
          faults.add(dtcInfo);
        }
      }

      return faults;
    } catch (e) {
      return [];
    }
  }

  List<String> _parseFaultCodes(String response) {
    // Simplified parsing - actual implementation would be more robust
    return ['P0300', 'P0420']; // Mock data for demonstration
  }

  Future<Map<String, dynamic>> _getSensorData() async {
    return {
      'rpm': '2500',
      'speed': '60',
      'coolant_temp': '85',
      'o2_sensor': '0.45',
      'throttle_pos': '15',
    };
  }

  Future<Map<String, dynamic>> _getBatteryInfo() async {
    return {
      'voltage': '12.6',
      'status': 'İyi',
      'health': '85%',
    };
  }

  Future<Map<String, dynamic>> _getMaintenanceInfo() async {
    return {
      'lastService': '2024-01-01',
      'nextService': '2024-04-01',
      'upcomingItems': ['Yağ değişimi', 'Hava filtresi'],
    };
  }

  Future<File> _createPdfReport(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildReportHeader(reportData),
          _buildVehicleInfoSection(reportData['vehicleInfo']),
          _buildFaultCodesSection(reportData['faultCodes']),
          _buildSensorDataSection(reportData['sensorData']),
          _buildBatteryInfoSection(reportData['batteryInfo']),
          _buildMaintenanceSection(reportData['maintenanceInfo']),
          _buildReportFooter(reportData),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/diagnostic_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildReportHeader(Map<String, dynamic> reportData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'STRCAR TANISAL RAPOR',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Rapor Tarihi: ${reportData['timestamp'].toString()}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Divider(),
        ],
      ),
    );
  }

  pw.Widget _buildVehicleInfoSection(Map<String, dynamic> vehicleInfo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ARAÇ BİLGİLERİ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            children: [
              pw.TableRow(children: [
                pw.Text('Marka:'),
                pw.Text(vehicleInfo['make'] ?? ''),
              ]),
              pw.TableRow(children: [
                pw.Text('Model:'),
                pw.Text(vehicleInfo['model'] ?? ''),
              ]),
              pw.TableRow(children: [
                pw.Text('Yıl:'),
                pw.Text(vehicleInfo['year'] ?? ''),
              ]),
              pw.TableRow(children: [
                pw.Text('VIN:'),
                pw.Text(vehicleInfo['vin'] ?? ''),
              ]),
              pw.TableRow(children: [
                pw.Text('Kilometre:'),
                pw.Text('${vehicleInfo['mileage'] ?? ''} km'),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFaultCodesSection(List<Map<String, dynamic>> faultCodes) {
    if (faultCodes.isEmpty) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Tespit Edilen Arıza Kodu Bulunamadı',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ARIZA KODLARI (${faultCodes.length} adet)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...faultCodes.map((fault) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  fault['code'] ?? '',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.Text(fault['title'] ?? ''),
                if (fault['description'] != null)
                  pw.Text(fault['description']),
              ],
            ),
          )),
        ],
      ),
    );
  }

  pw.Widget _buildSensorDataSection(Map<String, dynamic> sensorData) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SENSÖR VERİLERİ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            children: [
              pw.TableRow(children: [
                pw.Text('Motor Devri:'),
                pw.Text('${sensorData['rpm'] ?? ''} RPM'),
              ]),
              pw.TableRow(children: [
                pw.Text('Hız:'),
                pw.Text('${sensorData['speed'] ?? ''} km/h'),
              ]),
              pw.TableRow(children: [
                pw.Text('Motor Sıcaklığı:'),
                pw.Text('${sensorData['coolant_temp'] ?? ''} °C'),
              ]),
              pw.TableRow(children: [
                pw.Text('O2 Sensörü:'),
                pw.Text('${sensorData['o2_sensor'] ?? ''} V'),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBatteryInfoSection(Map<String, dynamic> batteryInfo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BATARYA BİLGİLERİ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            children: [
              pw.TableRow(children: [
                pw.Text('Voltaj:'),
                pw.Text('${batteryInfo['voltage'] ?? ''} V'),
              ]),
              pw.TableRow(children: [
                pw.Text('Durum:'),
                pw.Text(batteryInfo['status'] ?? ''),
              ]),
              pw.TableRow(children: [
                pw.Text('Sağlık:'),
                pw.Text(batteryInfo['health'] ?? ''),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMaintenanceSection(Map<String, dynamic> maintenanceInfo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BAKIM BİLGİLERİ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            children: [
              pw.TableRow(children: [
                pw.Text('Son Servis:'),
                pw.Text(maintenanceInfo['lastService'] ?? ''),
              ]),
              pw.TableRow(children: [
                pw.Text('Sonraki Servis:'),
                pw.Text(maintenanceInfo['nextService'] ?? ''),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReportFooter(Map<String, dynamic> reportData) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Bu rapor Strcar uygulaması tarafından oluşturulmuştur.',
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Rapor ID: ${reportData['timestamp'].millisecondsSinceEpoch}',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _saveReportToHistory(Map<String, dynamic> reportData, String filePath) async {
    final newReport = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Genel Tanı Raporu - ${DateTime.now().toString().split(' ')[0]}',
      'date': DateTime.now().toString().split(' ')[0],
      'type': 'Genel',
      'faultCount': (reportData['faultCodes'] as List).length,
      'mileage': reportData['vehicleInfo']['mileage'] ?? 0,
      'filePath': filePath,
    };

    setState(() {
      _savedReports.insert(0, newReport);
    });

    // Save to persistent storage
    // await _saveReportsToStorage();
  }

  void _showReportOptions(File pdfFile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print, color: Colors.red),
              title: const Text('Yazdır'),
              onTap: () => _printReport(pdfFile),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.red),
              title: const Text('Paylaş'),
              onTap: () => _shareReport(pdfFile),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('E-posta'),
              onTap: () => _emailReport(pdfFile),
            ),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.red),
              title: const Text('Cihaza Kaydet'),
              onTap: () => _saveReportLocally(pdfFile),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReport(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfFile.readAsBytes(),
    );
  }

  Future<void> _shareReport(File pdfFile) async {
    await Share.shareFiles(
      [pdfFile.path],
      text: 'Strcar Tanı Raporu',
    );
  }

  Future<void> _emailReport(File pdfFile) async {
    // Email functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('E-posta özelliği henüz geliştirilmekte')),
    );
  }

  Future<void> _saveReportLocally(File pdfFile) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapor cihaza kaydedildi')),
    );
  }

  void _deleteReport(String reportId) {
    setState(() {
      _savedReports.removeWhere((report) => report['id'] == reportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hataları Kaydet'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with Generate Report Button
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2D2D3D),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanı Raporu Oluştur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kapsamlı araç durumu raporu',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateDiagnosticReport,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: const Text('Oluştur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: _savedReports.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Kaydedilmiş Rapor Yok',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'İlk raporunuzu oluşturun',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _savedReports.length,
                    itemBuilder: (context, index) {
                      final report = _savedReports[index];
                      return Card(
                        color: const Color(0xFF2D2D3D),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.assignment, color: Colors.red),
                          title: Text(
                            report['title'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${report['date']} - ${report['faultCount']} arıza',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Text('Görüntüle'),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: Text('Paylaş'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Sil'),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'delete':
                                  _deleteReport(report['id']);
                                  break;
                                case 'share':
                                  // Share report
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}