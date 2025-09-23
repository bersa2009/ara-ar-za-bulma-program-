import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class SaveReportsScreen extends ConsumerStatefulWidget {
  const SaveReportsScreen({super.key});

  @override
  ConsumerState<SaveReportsScreen> createState() => _SaveReportsScreenState();
}

class DiagnosticReport {
  final String id;
  final DateTime date;
  final String vehicleVin;
  final String vehicleName;
  final int mileage;
  final List<String> dtcCodes;
  final Map<String, dynamic> sensorData;
  final String reportType;
  final bool isExported;

  DiagnosticReport({
    required this.id,
    required this.date,
    required this.vehicleVin,
    required this.vehicleName,
    required this.mileage,
    required this.dtcCodes,
    required this.sensorData,
    required this.reportType,
    this.isExported = false,
  });
}

class _SaveReportsScreenState extends ConsumerState<SaveReportsScreen> {
  List<DiagnosticReport> reports = [];
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    // Mock diagnostic reports
    reports = [
      DiagnosticReport(
        id: 'RPT001',
        date: DateTime.now().subtract(const Duration(days: 2)),
        vehicleVin: 'VF1RJ000554123456',
        vehicleName: 'Renault Clio 2018',
        mileage: 85420,
        dtcCodes: ['P0300', 'P0171'],
        sensorData: {
          'rpm': 850,
          'speed': 0,
          'engineTemp': 92,
          'batteryVoltage': 12.4,
        },
        reportType: 'Arıza Tespiti',
        isExported: true,
      ),
      DiagnosticReport(
        id: 'RPT002',
        date: DateTime.now().subtract(const Duration(days: 7)),
        vehicleVin: 'VF1RJ000554123456',
        vehicleName: 'Renault Clio 2018',
        mileage: 85200,
        dtcCodes: ['P0420'],
        sensorData: {
          'rpm': 900,
          'speed': 0,
          'engineTemp': 88,
          'batteryVoltage': 12.6,
        },
        reportType: 'Periyodik Kontrol',
        isExported: false,
      ),
      DiagnosticReport(
        id: 'RPT003',
        date: DateTime.now().subtract(const Duration(days: 15)),
        vehicleVin: 'VF1RJ000554123456',
        vehicleName: 'Renault Clio 2018',
        mileage: 84950,
        dtcCodes: [],
        sensorData: {
          'rpm': 800,
          'speed': 0,
          'engineTemp': 90,
          'batteryVoltage': 12.8,
        },
        reportType: 'Bakım Sonrası',
        isExported: true,
      ),
      DiagnosticReport(
        id: 'RPT004',
        date: DateTime.now().subtract(const Duration(days: 30)),
        vehicleVin: 'VF1RJ000554123456',
        vehicleName: 'Renault Clio 2018',
        mileage: 84500,
        dtcCodes: ['P0128', 'P0442'],
        sensorData: {
          'rpm': 750,
          'speed': 0,
          'engineTemp': 85,
          'batteryVoltage': 12.2,
        },
        reportType: 'Arıza Tespiti',
        isExported: false,
      ),
    ];
  }

  Future<void> _generateNewReport() async {
    setState(() {
      isGenerating = true;
    });

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final newReport = DiagnosticReport(
      id: 'RPT${(reports.length + 1).toString().padLeft(3, '0')}',
      date: DateTime.now(),
      vehicleVin: 'VF1RJ000554123456',
      vehicleName: 'Renault Clio 2018',
      mileage: 85420 + random.nextInt(100),
      dtcCodes: random.nextBool() 
          ? ['P030${random.nextInt(9)}', 'P017${random.nextInt(9)}']
          : [],
      sensorData: {
        'rpm': 800 + random.nextInt(200),
        'speed': 0,
        'engineTemp': 85 + random.nextInt(15),
        'batteryVoltage': 12.0 + random.nextDouble() * 1.0,
      },
      reportType: 'Yeni Tarama',
      isExported: false,
    );

    setState(() {
      reports.insert(0, newReport);
      isGenerating = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni rapor oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportReport(DiagnosticReport report, String format) async {
    // Simulate export process
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      final index = reports.indexOf(report);
      reports[index] = DiagnosticReport(
        id: report.id,
        date: report.date,
        vehicleVin: report.vehicleVin,
        vehicleName: report.vehicleName,
        mileage: report.mileage,
        dtcCodes: report.dtcCodes,
        sensorData: report.sensorData,
        reportType: report.reportType,
        isExported: true,
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapor $format formatında dışa aktarıldı'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteReport(DiagnosticReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: const Text(
          'Raporu Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bu raporu silmek istediğinizden emin misiniz?\n\nRapor ID: ${report.id}\nTarih: ${_formatDate(report.date)}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                reports.remove(report);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rapor silindi'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportedReports = reports.where((r) => r.isExported).length;
    final totalReports = reports.length;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Hataları Kaydet'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
            onPressed: isGenerating ? null : _generateNewReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              color: const Color(0xFF8B1538),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.save, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Tanı Raporları',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Okunan DTC ve sensör verilerini rapor olarak saklar. Geçmiş raporlar PDF/Excel olarak dışa aktarılabilir.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatChip('Toplam', totalReports, Colors.blue),
                        const SizedBox(width: 8),
                        _buildStatChip('Dışa Aktarılan', exportedReports, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatChip('Bekleyen', totalReports - exportedReports, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // New report button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isGenerating ? null : _generateNewReport,
                icon: isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_circle),
                label: Text(isGenerating ? 'Rapor Oluşturuluyor...' : 'Yeni Rapor Oluştur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1538),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reports list
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Geçmiş Raporlar (${reports.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: reports.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Henüz Rapor Yok',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'İlk raporunuzu oluşturmak için yukarıdaki butona basın',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Card(
                          color: const Color(0xFF1E1E2F),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: report.dtcCodes.isEmpty 
                                  ? Colors.green.shade700 
                                  : Colors.red.shade700,
                              child: Icon(
                                report.dtcCodes.isEmpty ? Icons.check : Icons.warning,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  report.id,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (report.isExported)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade800,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'EXPORT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${report.reportType} - ${_formatDate(report.date)}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  '${report.vehicleName} - ${report.mileage} km',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                if (report.dtcCodes.isNotEmpty)
                                  Text(
                                    'DTC: ${report.dtcCodes.join(', ')}',
                                    style: const TextStyle(color: Colors.red, fontSize: 11),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert, color: Colors.white54),
                              color: const Color(0xFF1E1E2F),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'view',
                                  child: const Row(
                                    children: [
                                      Icon(Icons.visibility, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('Görüntüle', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'export_pdf',
                                  child: const Row(
                                    children: [
                                      Icon(Icons.picture_as_pdf, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('PDF Dışa Aktar', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'export_excel',
                                  child: const Row(
                                    children: [
                                      Icon(Icons.table_chart, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('Excel Dışa Aktar', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 16),
                                      SizedBox(width: 8),
                                      Text('Sil', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
                                    _showReportDetails(context, report);
                                    break;
                                  case 'export_pdf':
                                    _exportReport(report, 'PDF');
                                    break;
                                  case 'export_excel':
                                    _exportReport(report, 'Excel');
                                    break;
                                  case 'delete':
                                    _deleteReport(report);
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
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showReportDetails(BuildContext context, DiagnosticReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: Text(
          'Rapor Detayları - ${report.id}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tarih', _formatDate(report.date)),
              _buildDetailRow('Araç', report.vehicleName),
              _buildDetailRow('VIN', report.vehicleVin),
              _buildDetailRow('Kilometre', '${report.mileage} km'),
              _buildDetailRow('Rapor Tipi', report.reportType),
              const SizedBox(height: 12),
              
              if (report.dtcCodes.isNotEmpty) ...[
                const Text(
                  'DTC Kodları:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                ...report.dtcCodes.map((code) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Text('• $code', style: const TextStyle(color: Colors.red)),
                )),
                const SizedBox(height: 12),
              ],
              
              const Text(
                'Sensör Verileri:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              ...report.sensorData.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Text(
                  '• ${entry.key}: ${entry.value}',
                  style: const TextStyle(color: Colors.white70),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}