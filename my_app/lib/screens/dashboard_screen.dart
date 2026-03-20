import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart'; // WHY: real stats + recent logs
import '../models/user_model.dart';
import '../models/log_entry.dart';
import 'counter_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final Future<UserModel> _userFuture;

  // ── real data replacing dummy ─────────────
  List<LogEntry> _recentLogs = [];
  LogStats       _stats      = LogStats.empty();
  bool           _isLoading  = true;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService().getUser();
    _loadDashboardData();
  }

  // Called on first load AND when returning from
  // counter/log form so stats stay fresh
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    // Run both DB calls in parallel — no need to wait
    // for one before starting the other
    final results = await Future.wait([
      DatabaseService().getRecentLogs(limit: 5),
      DatabaseService().getStats(),
    ]);

    if (!mounted) return;
    setState(() {
      _recentLogs = results[0] as List<LogEntry>;
      _stats      = results[1] as LogStats;
      _isLoading  = false;
    });
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CounterScreen()))
          // Refresh stats when returning from counter/log form
          .then((_) {
            setState(() => _selectedIndex = 0);
            _loadDashboardData();
          });
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ReportsScreen()))
          .then((_) => setState(() => _selectedIndex = 0));
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          final user = snapshot.data ?? UserModel.empty();
          return Column(
            children: [
              _TopBar(greeting: _getGreeting(), user: user),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppTheme.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spaceSM),

                      _StartCountingCard(onTap: () => _onNavTap(1))
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 100.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: AppTheme.spaceMD),

                      // Pass real stats — shows live numbers not '—'
                      _StatsRow(stats: _stats, isLoading: _isLoading)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 200.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: AppTheme.spaceXL),

                      _SectionHeader(
                        title: 'Recent logs',
                        actionLabel: 'View all',
                        onAction: () => _onNavTap(2),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms),

                      const SizedBox(height: AppTheme.spaceMD),

                      // Show spinner while loading, empty state if no logs
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(
                                  color: AppTheme.accent,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _recentLogs.isEmpty
                              ? _buildEmptyLogsState()
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentLogs.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppTheme.spaceSM),
                                  itemBuilder: (context, index) {
                                    return _LogTile(entry: _recentLogs[index])
                                        .animate()
                                        .fadeIn(
                                          duration: 400.ms,
                                          delay: (350 + index * 80).ms,
                                        )
                                        .slideX(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOut,
                                        );
                                  },
                                ),

                      const SizedBox(height: AppTheme.spaceXL),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildEmptyLogsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppTheme.textSecondary.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          Text(
            'No logs yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Top bar — unchanged
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String greeting;
  final UserModel user;

  const _TopBar({required this.greeting, required this.user});

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spaceMD,
        bottom: AppTheme.spaceLG,
        left: AppTheme.screenPadding,
        right: AppTheme.screenPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.name.isNotEmpty ? '${user.name} 👋' : 'Welcome 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────
//  Start counting card — unchanged
// ─────────────────────────────────────────────
class _StartCountingCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StartCountingCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: AppTheme.borderRadiusLG,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'READY TO COUNT?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Start Counting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Point camera at hardware items',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(
                  color: AppTheme.accent.withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppTheme.accent,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Stats row — now receives real LogStats
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final LogStats stats;
  final bool isLoading;

  const _StatsRow({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          // Show '—' while loading, real number once ready
          value: isLoading ? '—' : '${stats.logsToday}',
          label: "Today's counts",
          icon: Icons.today_rounded,
          iconColor: AppTheme.accent,
        ),
        const SizedBox(width: AppTheme.spaceMD),
        _StatCard(
          value: isLoading ? '—' : '${stats.itemsThisWeek}',
          label: 'Items this week',
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Stat card — unchanged
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusSM,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppTheme.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Section header — unchanged
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        GestureDetector(
          onTap: onAction,
          child: const Text(
            'View all →',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Log tile — unchanged
// ─────────────────────────────────────────────
class _LogTile extends StatelessWidget {
  final LogEntry entry;
  const _LogTile({required this.entry});

  Color _getColor(String material) {
    final m = material.toLowerCase();
    if (m.contains('bolt'))  return AppTheme.accent;
    if (m.contains('wash'))  return const Color(0xFF6366F1);
    if (m.contains('nut'))   return const Color(0xFFF97316);
    return AppTheme.info;
  }

  String _formatDate(DateTime date) {
    final now  = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24 && now.day == date.day) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day} ${_month(date.month)}';
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(entry.materialType);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.borderRadiusLG,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppTheme.borderRadiusSM,
            ),
            child: Icon(Icons.hardware_rounded, color: color, size: 20),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.materialType} — Lot #${entry.lotNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Issued to: ${entry.issuedTo} · ${_formatDate(entry.issueDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.quantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'items',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
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
//  Bottom nav — unchanged
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 10,
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.camera_alt_rounded,
            label: 'Counter',
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.description_rounded,
            label: 'Reports',
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceXS,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: AppTheme.borderRadiusFull,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? AppTheme.accent : AppTheme.textHint,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.accent : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}