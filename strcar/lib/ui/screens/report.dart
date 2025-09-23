import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/dtc_repository.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportItem {
  final String code;
  final String title;
  final bool severe;
  ReportItem({required this.code, required this.title, this.severe = false});
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.items, this.lang = 'tr'});
  final List<ReportItem> items;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarama Raporu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _exportPdf(context, items);
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (ctx, i) {
          final it = items[i];
          final color = it.severe ? Colors.red : Colors.orange;
          return ListTile(
            leading: Icon(Icons.report, color: color),
            title: Text(it.code),
            subtitle: Text(it.title),
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => FutureBuilder<Map<String, dynamic>?>(
                future: DtcRepository().getDtc(it.code, lang: lang),
                builder: (ctx, snap) {
                  final data = snap.data;
                  final desc = data?['description'] ?? it.title;
                  final causes = (data?['causes'] as List?)?.join(', ') ?? '';
                  final fixes = (data?['fixes'] as List?)?.join(', ') ?? '';
                  return AlertDialog(
                    title: Text(it.code),
                    content: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(desc),
                        const SizedBox(height: 8),
                        if (causes.isNotEmpty) Text('Nedenler: $causes'),
                        if (fixes.isNotEmpty) Text('Çözümler: $fixes'),
                      ]),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
                  );
                },
              ),
            ),
            onLongPress: () async {
              final tts = FlutterTts();
              await tts.setLanguage('tr-TR');
              final data = await DtcRepository().getDtc(it.code, lang: lang);
              final desc = data?['description'] ?? it.title;
              final causes = (data?['causes'] as List?)?.join(', ');
              final fixes = (data?['fixes'] as List?)?.join(', ');
              final text = [it.code, desc, if (causes != null) 'Nedenler: $causes', if (fixes != null) 'Çözümler: $fixes'].join('. ');
              await tts.speak(text);
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: items.length,
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, List<ReportItem> items) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Text('Strcar - DTC Raporu', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Code', 'Title', 'Severity'],
            data: items.map((e) => [e.code, e.title, e.severe ? 'High' : 'Medium']).toList(),
          )
        ],
      ),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/strcar_report.pdf');
    await file.writeAsBytes(await pdf.save());
    // Optionally present share/print
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF kaydedildi: ${file.path}')));
  }
}

