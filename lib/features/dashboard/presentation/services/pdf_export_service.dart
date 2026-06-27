import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../expense/domain/entities/expense.dart';
import '../bloc/dashboard_state.dart';

class PdfExportService {
  static Future<void> export({
    required List<Expense> expenses,
    required DashboardPeriod period,
  }) async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    final doc = pw.Document();
    final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');
    final now = DateTime.now();
    final sorted = [...expenses]..sort((a, b) => a.date.compareTo(b.date));

    final byCat = <String, int>{};
    for (final e in sorted) {
      byCat[e.category.label] = (byCat[e.category.label] ?? 0) + e.amount;
    }
    final total = sorted.fold<int>(0, (s, e) => s + e.amount);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Laporan Pengeluaran',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      period.label,
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Dibuat: ${dateFmt.format(now)}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (context) => [
          // Total
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Pengeluaran',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  CurrencyFormatter.format(total),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Category breakdown
          pw.Text(
            'Ringkasan Kategori',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FixedColumnWidth(110),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _headerCell('Kategori'),
                  _headerCell('Jumlah'),
                ],
              ),
              ...byCat.entries.map(
                (e) => pw.TableRow(children: [
                  _cell(e.key),
                  _cell(CurrencyFormatter.format(e.value)),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Transactions
          pw.Text(
            'Rincian Transaksi (${sorted.length} entri)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(80),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FixedColumnWidth(100),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _headerCell('Tanggal'),
                  _headerCell('Merchant'),
                  _headerCell('Kategori'),
                  _headerCell('Jumlah'),
                ],
              ),
              ...sorted.map(
                (e) => pw.TableRow(children: [
                  _cell(DateFormat('dd/MM/yy').format(e.date)),
                  _cell(e.merchantName),
                  _cell(e.category.label),
                  _cell(CurrencyFormatter.format(e.amount)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'penny-${period.name}-${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }

  static pw.Widget _headerCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      );

  static pw.Widget _cell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );
}
