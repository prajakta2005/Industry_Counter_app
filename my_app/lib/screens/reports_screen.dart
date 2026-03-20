import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../utils/app_theme.dart';
import '../models/log_entry.dart';
import '../main.dart';

const Map<String, Color> _kMaterialColors = {
  'Bolts':   Color(0xFF4A90D9),
  'Nuts':    Color(0xFFE8A838),
  'Washers': Color(0xFF7B68EE),
  'Screws':  Color(0xFF50C878),
  'Clips':   Color(0xFFFF6B6B),
  'Other':   Color(0xFF9E9E9E),
};

Color _colorFor(String material) =>
    _kMaterialColors[material] ?? _kMaterialColors['Other']!;

final List<LogEntry> _dummyLogs = [
  LogEntry(
    id: 'dummy-1',
    lotNumber: 'LOT-2024-001',
    materialType: 'Bolts',
    quantity: 42,
    issuedTo: 'Ravi Kumar',
    countedBy: 'Prajakta',
    issueDate: DateTime.now(),
    site: 'Site A',
    isSynced: false,
  ),
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _activeFilter = 'All';
  bool _newestFirst = true;

  final List<String> _filters = ['All', ..._kMaterialColors.keys];

  List<LogEntry> get _filteredLogs {
    var logs = List<LogEntry>.from(_dummyLogs);

    if (_activeFilter != 'All') {
      logs = logs.where((e) => e.materialType == _activeFilter).toList();
    }

    logs.sort((a, b) => _newestFirst
        ? b.issueDate.compareTo(a.issueDate)
        : a.issueDate.compareTo(b.issueDate));

    return logs;
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(
        logCount: _filteredLogs.length,
        filterLabel: _activeFilter,
        onConfirm: _onExportConfirmed,
      ),
    );
  }

  void _onExportConfirmed() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Excel export coming soon'),
        backgroundColor: AppTheme.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildLogList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_filteredLogs.length} entries',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          InkWell(
            onTap: () => setState(() => _newestFirst = !_newestFirst),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _newestFirst
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: AppTheme.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _newestFirst ? 'Newest' : 'Oldest',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          IconButton(
            onPressed: _showExportSheet,
            icon: const Icon(Icons.share, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    final logs = _filteredLogs;

    if (logs.isEmpty) {
      return const Center(child: Text('No logs'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final entry = logs[i];
        return Card(
          child: ListTile(
            title: Text(entry.materialType),
            subtitle: Text(entry.lotNumber),
            trailing: Text('${entry.quantity}'),
          ),
        );
      },
    );
  }
}

class _ExportSheet extends StatelessWidget {
  final int logCount;
  final String filterLabel;
  final VoidCallback onConfirm;

  const _ExportSheet({
    required this.logCount,
    required this.filterLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Export $logCount logs'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}