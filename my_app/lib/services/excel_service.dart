import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../models/log_entry.dart';

class ExcelService {
  ExcelService._internal();
  static final ExcelService _instance = ExcelService._internal();
  factory ExcelService() => _instance;

  static final List<_Column> _columns = [
    _Column('Lot Number', 18, (e) => e.lotNumber),
    _Column('Material', 14, (e) => e.materialType),
    _Column('Quantity', 10, (e) => e.quantity.toString()),
    _Column('Issued To', 18, (e) => e.issuedTo),
    _Column('Counted By', 16, (e) => e.countedBy),
    _Column('Issue Date', 14, (e) => DateFormat('dd MMM yyyy').format(e.issueDate)),
    _Column('Site', 14, (e) => e.site),
    _Column('Sync Status', 13, (e) => e.isSynced ? 'Synced' : 'Pending'),
  ];

  Future<void> generateAndShare(
    List<LogEntry> logs, {
    String? fileName,
  }) async {
    if (logs.isEmpty) return;

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'NexCount Logs';

    _writeHeaderRow(workbook, sheet);

    for (int i = 0; i < logs.length; i++) {
      _writeDataRow(workbook, sheet, logs[i], i + 2);
    }

    for (int i = 0; i < _columns.length; i++) {
      sheet.getRangeByIndex(1, i + 1).columnWidth = _columns[i].width;
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final name = fileName ?? 'NexCount_Logs_$dateStr.xlsx';
    final filePath = '${directory.path}/$name';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'NexCount Log Report — $dateStr',
      text: 'NexCount hardware log report. ${logs.length} entries.',
    );
  }

  void _writeHeaderRow(Workbook workbook, Worksheet sheet) {
    for (int i = 0; i < _columns.length; i++) {
      final Range cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(_columns[i].header);

      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.backColor = '#1A1F36';
      cell.cellStyle.hAlign = HAlignType.center;
      cell.cellStyle.vAlign = VAlignType.center;
      cell.cellStyle.wrapText = false;

      cell.cellStyle.borders.all.lineStyle = LineStyle.thin;
      cell.cellStyle.borders.all.color = '#2D3350';
    }
  }

  void _writeDataRow(
    Workbook workbook,
    Worksheet sheet,
    LogEntry entry,
    int rowIndex,
  ) {
    final bool isEven = rowIndex % 2 == 0;
    final String bgColor = isEven ? '#F5F6FA' : '#FFFFFF';

    for (int i = 0; i < _columns.length; i++) {
      final Range cell = sheet.getRangeByIndex(rowIndex, i + 1);
      final String value = _columns[i].extractor(entry);

      cell.setText(value);

      cell.cellStyle.fontSize = 10;
      cell.cellStyle.backColor = bgColor;
      cell.cellStyle.hAlign = HAlignType.left;
      cell.cellStyle.vAlign = VAlignType.center;

      if (i == _columns.length - 1) {
        cell.cellStyle.fontColor =
            entry.isSynced ? '#1A7A4A' : '#B45309';
        cell.cellStyle.bold = true;
      }

      cell.cellStyle.borders.all.lineStyle = LineStyle.thin;
      cell.cellStyle.borders.all.color = '#E2E4EA';
    }
  }
}

class _Column {
  final String header;
  final double width;
  final String Function(LogEntry) extractor;

  const _Column(this.header, this.width, this.extractor);
}