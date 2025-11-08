import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as ex;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportRow {
  final String nome;
  final DateTime dataHora;
  final String categoria;
  final String repeticao;
  final String tempoFormatado; // "7 dias, 7 horas, 52 minutos, 52 segundos" ou "–"
  const ReportRow({
    required this.nome,
    required this.dataHora,
    required this.categoria,
    required this.repeticao,
    required this.tempoFormatado,
  });
}

Future<File> _createTempFile(String basename) async {
  final dir = await getTemporaryDirectory();
  final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final filename = '$basename-$ts';
  return File(p.join(dir.path, filename));
}

Future<File> generateXlsxReport(List<ReportRow> rows) async {
  final excel = ex.Excel.createExcel();
  final sheet = excel['Relatorio'];
  sheet.appendRow([
    'Nome do contador',
    'Data (DD/MM/AAAA)',
    'Hora (HH:MM)',
    'Tempo decorrido ou restante',
    'Categoria',
    'Repetição',
  ]);
  final df = DateFormat('dd/MM/yyyy');
  final tf = DateFormat('HH:mm');
  for (final r in rows) {
    sheet.appendRow([
      r.nome,
      df.format(r.dataHora),
      tf.format(r.dataHora),
      r.tempoFormatado,
      r.categoria,
      r.repeticao,
    ]);
  }
  final bytes = excel.encode()!;
  final f = await _createTempFile('relatorio');
  final xlsx = File('${f.path}.xlsx');
  await xlsx.writeAsBytes(bytes, flush: true);
  return xlsx;
}

Future<File> generatePdfReport(List<ReportRow> rows) async {
  final doc = pw.Document();
  final df = DateFormat('dd/MM/yyyy');
  final tf = DateFormat('HH:mm');
  final headerStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
  final cellStyle = const pw.TextStyle(fontSize: 11);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Row(children: [
            pw.Text('Relatórios', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.SizedBox(height: 8),
          pw.Text('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(width: 0.3, color: PdfColors.grey),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Nome do contador', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Data (DD/MM/AAAA)', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Hora (HH:MM)', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Tempo decorrido ou restante', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Categoria', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Repetição', style: headerStyle)),
              ]),
              ...rows.map((r) => pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.nome, style: cellStyle)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(df.format(r.dataHora), style: cellStyle)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(tf.format(r.dataHora), style: cellStyle)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.tempoFormatado, style: cellStyle)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.categoria, style: cellStyle)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.repeticao, style: cellStyle)),
                  ]))
            ],
          ),
        ];
      },
    ),
  );

  final bytes = await doc.save();
  final f = await _createTempFile('relatorio');
  final pdfFile = File('${f.path}.pdf');
  await pdfFile.writeAsBytes(bytes, flush: true);
  return pdfFile;
}

Future<void> shareFile(File file, {required String mimeType}) async {
  final xfile = XFile(file.path, mimeType: mimeType);
  await Share.shareXFiles([xfile]);
}