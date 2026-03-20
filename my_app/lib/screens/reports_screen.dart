import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../utils/app_theme.dart';
import '../models/log_entry.dart';
import '../services/database_service.dart';
import '../services/excel_service.dart';
import '../main.dart';

// ── material colors ───────────────────────────
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

// ─────────────────────────────────────────────
//  ReportsScreen
// ─────────────────────────────────────────────
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _activeFilter = 'All';
  bool   _newestFirst  = true;
  bool   _isLoading    = true;

  final List<String> _filters = ['All', ..._kMaterialColors.keys];
  List<LogEntry> _allLogs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await DatabaseService().getAllLogs();
    if (!mounted) return;
    setState(() {
      _allLogs   = logs;
      _isLoading = false;
    });
  }

  List<LogEntry> get _filteredLogs {
    var logs = List<LogEntry>.from(_allLogs);
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

  Future<void> _onExportConfirmed() async {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Generating Excel report…'),
          ],
        ),
        backgroundColor: AppTheme.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
    await ExcelService().generateAndShare(_filteredLogs);
  }

  void _showDetailSheet(LogEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterRow(),
            const SizedBox(height: 8),
            Expanded(child: _buildLogList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
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
                    color: AppTheme.accent,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: _newestFirst
                ? 'Sorted by date: newest first'
                : 'Sorted by date: oldest first',
            child: InkWell(
              onTap: () => setState(() => _newestFirst = !_newestFirst),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        _newestFirst
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        key: ValueKey(_newestFirst),
                        color: AppTheme.accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _newestFirst ? 'Newest' : 'Oldest',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _showExportSheet,
            icon: const Icon(Icons.ios_share_rounded, color: AppTheme.accent, size: 22),
            tooltip: 'Export to Excel',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.only(bottom: 14, left: 16, right: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final isActive = _activeFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.accent
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.accent
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.65),
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
      );
    }
    final logs = _filteredLogs;
    if (logs.isEmpty) return _buildEmptyState();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _LogTile(
        entry: logs[i],
        onTap: () => _showDetailSheet(logs[i]),
      )
          .animate()
          .fadeIn(delay: (i * 60).ms, duration: 300.ms)
          .slideY(begin: 0.1, end: 0, delay: (i * 60).ms, duration: 300.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64,
                color: AppTheme.textSecondary.withOpacity(0.4))
                .animate().fadeIn(duration: 400.ms)
                .scaleXY(begin: 0.8, end: 1.0, duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              _activeFilter == 'All' ? 'No logs yet' : 'No $_activeFilter logs',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Start counting hardware to\ncreate your first log entry.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.counter),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Start Counting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: false,
                onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
              ),
              _NavItem(
                icon: Icons.camera_alt_outlined,
                activeIcon: Icons.camera_alt_rounded,
                label: 'Counter',
                isActive: false,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.counter),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Reports',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
} // ← _ReportsScreenState ends here

// ─────────────────────────────────────────────
//  _LogTile
// ─────────────────────────────────────────────
class _LogTile extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback onTap;
  const _LogTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color   = _colorFor(entry.materialType);
    final dateStr = DateFormat('dd MMM yyyy').format(entry.issueDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hardware_outlined, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(entry.materialType,
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: entry.isSynced
                                ? Colors.green.withOpacity(0.12)
                                : Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.isSynced
                                    ? Icons.cloud_done_outlined
                                    : Icons.cloud_upload_outlined,
                                size: 11,
                                color: entry.isSynced ? Colors.green : Colors.amber.shade700,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                entry.isSynced ? 'Synced' : 'Pending',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: entry.isSynced ? Colors.green : Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.lotNumber} · ${entry.issuedTo}',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${entry.quantity}',
                      style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800, height: 1.0)),
                  Text('items',
                      style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _DetailSheet
// ─────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final LogEntry entry;
  const _DetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color   = _colorFor(entry.materialType);
    final dateStr = DateFormat('dd MMM yyyy').format(entry.issueDate);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.hardware_outlined, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.materialType,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('${entry.quantity} items counted',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.tag_rounded,             label: 'Lot Number', value: entry.lotNumber),
          _DetailRow(icon: Icons.person_outline_rounded,  label: 'Issued To',  value: entry.issuedTo),
          _DetailRow(icon: Icons.badge_outlined,          label: 'Counted By', value: entry.countedBy),
          _DetailRow(icon: Icons.location_on_outlined,    label: 'Site',       value: entry.site),
          _DetailRow(icon: Icons.calendar_today_outlined, label: 'Issue Date', value: dateStr),
          _DetailRow(
            icon: entry.isSynced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
            label: 'Sync Status',
            value: entry.isSynced ? 'Synced to Firebase' : 'Pending sync',
            valueColor: entry.isSynced ? Colors.green : Colors.amber.shade700,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _DetailRow
// ─────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;

  const _DetailRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _ExportSheet
// ─────────────────────────────────────────────
class _ExportSheet extends StatelessWidget {
  final int      logCount;
  final String   filterLabel;
  final VoidCallback onConfirm;

  const _ExportSheet({required this.logCount, required this.filterLabel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.table_chart_outlined, color: AppTheme.accent, size: 32),
          ).animate().scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), duration: 350.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          const Text('Export to Excel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'This will export $logCount ${filterLabel == 'All' ? '' : '$filterLabel '}log entries as an .xlsx file.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _NavItem
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  final bool     isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.black : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
