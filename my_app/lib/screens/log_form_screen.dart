import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../utils/app_theme.dart';
import '../models/log_entry.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart'; 
import '../services/firebase_service.dart'; 
import '../main.dart'; 

const List<String> _kMaterialOptions = [
  'Bolts',
  'Nuts',
  'Washers',
  'Screws',
  'Clips',
  'Other',
];

class LogFormScreen extends StatefulWidget {
  const LogFormScreen({super.key});

  @override
  State<LogFormScreen> createState() => _LogFormScreenState();
}

class _LogFormScreenState extends State<LogFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── controllers ───────────────────────────
  final _lotNumberCtrl  = TextEditingController();
  final _issuedToCtrl   = TextEditingController();
  final _otherMatCtrl   = TextEditingController(); // shown when 'Other' picked
  late  TextEditingController _quantityCtrl;

  // ── state ─────────────────────────────────
  String  _selectedMaterial = _kMaterialOptions[0]; // default: Bolts
  bool    _showOtherField   = false;
  DateTime _issueDate       = DateTime.now();
  bool    _isSaving         = false;

  // ── user data (auto-filled) ───────────────
  UserModel _user = UserModel.empty();
  bool _userLoaded = false;

  // ── args from CounterScreen ───────────────
  int    _countFromCamera = 0;
  String _materialFromCamera = '';
  bool   _argsRead = false; // only read once

  // ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _quantityCtrl = TextEditingController();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read route args exactly once
    if (!_argsRead) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _countFromCamera    = (args['count'] as int?) ?? 0;
        _materialFromCamera = (args['material'] as String?) ?? '';
      }

      // Pre-fill quantity from camera count
      _quantityCtrl.text = _countFromCamera > 0
          ? _countFromCamera.toString()
          : '';

      // Pre-select material if it matches a known option
      if (_kMaterialOptions.contains(_materialFromCamera)) {
        _selectedMaterial = _materialFromCamera;
      }

      _argsRead = true;
    }
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getUser();
    if (!mounted) return;
    setState(() {
      _user       = user ?? UserModel.empty();
      _userLoaded = true;
    });
  }

  @override
  void dispose() {
    _lotNumberCtrl.dispose();
    _issuedToCtrl.dispose();
    _otherMatCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }
  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

   
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        final darkScheme = Theme.of(ctx).colorScheme.copyWith(
          primary: AppTheme.accent,
          onPrimary: Colors.white,
          surface: AppTheme.primaryDark,
          onSurface: Colors.white,
        );
        return Theme(
          data: Theme.of(ctx).copyWith(colorScheme: darkScheme),
          
          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(viewInsets: EdgeInsets.zero),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _saveLog() async {
    // Validate all fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Resolve final material string
    final String finalMaterial = _selectedMaterial == 'Other'
        ? _otherMatCtrl.text.trim()
        : _selectedMaterial;

    // Build LogEntry
    final entry = LogEntry(
      id:           const Uuid().v4(),
      lotNumber:    _lotNumberCtrl.text.trim(),
      materialType: finalMaterial,
      quantity:     int.parse(_quantityCtrl.text.trim()),
      issuedTo:     _issuedToCtrl.text.trim(),
      countedBy:    _user.name,
      issueDate:    _issueDate,
      site:         _user.site,
      isSynced:     false,
    );
    await DatabaseService().insertLog(entry);
    FirebaseService().syncPendingLogs();

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _SuccessScreen(entry: entry),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
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
            _buildTopBar(),
            Expanded(
              child: _userLoaded
                  ? _buildForm()
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accent,
                        strokeWidth: 2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTopBar() {
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 20),
          ),
          const Expanded(
            child: Text(
              'New Log Entry',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.accentDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          _sectionLabel('Hardware Details'),
          const SizedBox(height: 12),

          _buildTextInput(
            controller: _lotNumberCtrl,
            label: 'Lot Number',
            hint: 'e.g. LOT-2024-001',
            icon: Icons.tag_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Lot number is required' : null,
          ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.15, end: 0, delay: 50.ms, duration: 350.ms),

          const SizedBox(height: 16),

          // Material type dropdown
          _buildMaterialDropdown()
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: 0.15, end: 0, delay: 100.ms, duration: 350.ms),

          // 'Other' text field — animated in/out
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _showOtherField
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildTextInput(
                      controller: _otherMatCtrl,
                      label: 'Specify Material',
                      hint: 'e.g. Anchor bolts',
                      icon: Icons.edit_outlined,
                      validator: (v) => (_showOtherField &&
                              (v == null || v.trim().isEmpty))
                          ? 'Please specify the material'
                          : null,
                    ).animate().fadeIn(duration: 250.ms),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Quantity
          _buildTextInput(
            controller: _quantityCtrl,
            label: 'Quantity',
            hint: 'Number of items counted',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Quantity is required';
              final n = int.tryParse(v.trim());
              if (n == null || n <= 0) return 'Enter a valid quantity';
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 150.ms)
              .slideY(begin: 0.15, end: 0, delay: 150.ms, duration: 350.ms),

          const SizedBox(height: 28),

          // ── section: issue details ──
          _sectionLabel('Issue Details'),
          const SizedBox(height: 12),

          // Issued to
          _buildTextInput(
            controller: _issuedToCtrl,
            label: 'Issued To',
            hint: 'Technician or team name',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Issued to is required' : null,
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.15, end: 0, delay: 200.ms, duration: 350.ms),

          const SizedBox(height: 16),

          // Issue date
          _buildDateField()
              .animate()
              .fadeIn(delay: 250.ms)
              .slideY(begin: 0.15, end: 0, delay: 250.ms, duration: 350.ms),

          const SizedBox(height: 28),

          // ── section: auto-filled ──
          _sectionLabel('Auto-filled from Profile'),
          const SizedBox(height: 12),

          // Counted by (read-only)
          _buildReadOnlyField(
            label: 'Counted By',
            value: _user.name.isNotEmpty ? _user.name : '—',
            icon: Icons.badge_outlined,
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.15, end: 0, delay: 300.ms, duration: 350.ms),

          const SizedBox(height: 16),

          // Site (read-only)
          _buildReadOnlyField(
            label: 'Site',
            value: _user.site.isNotEmpty ? _user.site : '—',
            icon: Icons.location_on_outlined,
          )
              .animate()
              .fadeIn(delay: 350.ms)
              .slideY(begin: 0.15, end: 0, delay: 350.ms, duration: 350.ms),

          const SizedBox(height: 36),

          // ── save button ──
          _buildSaveButton()
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }
  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        hintStyle: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
  Widget _buildMaterialDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedMaterial,
      items: _kMaterialOptions
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (val) {
        if (val == null) return;
        setState(() {
          _selectedMaterial = val;
          _showOtherField   = val == 'Other';
          if (!_showOtherField) _otherMatCtrl.clear();
        });
      },
      style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Material Type',
        prefixIcon: Icon(Icons.category_outlined,
            size: 20, color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
  Widget _buildDateField() {
    final formatted = DateFormat('dd MMM yyyy').format(_issueDate);
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: formatted),
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Issue Date',
            prefixIcon: Icon(Icons.calendar_today_outlined,
                size: 20, color: AppTheme.textSecondary),
            suffixIcon: Icon(Icons.arrow_drop_down_rounded,
                color: AppTheme.textSecondary),
            filled: true,
            fillColor: Colors.white,
            labelStyle:
                TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveLog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.accent.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Save Log Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SuccessScreen extends StatefulWidget {
  final LogEntry entry;
  const _SuccessScreen({required this.entry});

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false, // clear entire back stack
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated check icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent.withOpacity(0.15),
                    border: Border.all(color: AppTheme.accent, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.accent,
                    size: 52,
                  ),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: 28),

                const Text(
                  'Log Saved!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 300.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                // Summary line
                Text(
                  '${widget.entry.quantity} ${widget.entry.materialType} · ${widget.entry.lotNumber}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms),

                const SizedBox(height: 48),

                // Returning to dashboard indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.4),
                        strokeWidth: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Returning to dashboard…',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}