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

  final _lotNumberCtrl  = TextEditingController();
  final _issuedToCtrl   = TextEditingController();
  final _otherMatCtrl   = TextEditingController();
  late  TextEditingController _quantityCtrl;

  String  _selectedMaterial = _kMaterialOptions[0];
  bool    _showOtherField   = false;
  DateTime _issueDate       = DateTime.now();
  bool    _isSaving         = false;

  UserModel _user = UserModel.empty();
  bool _userLoaded = false;

  int    _countFromCamera = 0;
  String _materialFromCamera = '';
  bool   _argsRead = false;

  @override
  void initState() {
    super.initState();
    _quantityCtrl = TextEditingController();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsRead) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _countFromCamera    = (args['count'] as int?) ?? 0;
        _materialFromCamera = (args['material'] as String?) ?? '';
      }

      _quantityCtrl.text = _countFromCamera > 0
          ? _countFromCamera.toString()
          : '';

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
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final String finalMaterial = _selectedMaterial == 'Other'
        ? _otherMatCtrl.text.trim()
        : _selectedMaterial;

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
                color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Text(
              'New Log Entry',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
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
          ),

          const SizedBox(height: 16),

          _buildMaterialDropdown(),

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
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

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
          ),

          const SizedBox(height: 28),

          _sectionLabel('Issue Details'),
          const SizedBox(height: 12),

          _buildTextInput(
            controller: _issuedToCtrl,
            label: 'Issued To',
            hint: 'Technician or team name',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Issued to is required' : null,
          ),

          const SizedBox(height: 16),

          _buildDateField(),

          const SizedBox(height: 28),

          _sectionLabel('Auto-filled from Profile'),
          const SizedBox(height: 12),

          _buildReadOnlyField(
            label: 'Counted By',
            value: _user.name.isNotEmpty ? _user.name : '—',
            icon: Icons.badge_outlined,
          ),

          const SizedBox(height: 16),

          _buildReadOnlyField(
            label: 'Site',
            value: _user.site.isNotEmpty ? _user.site : '—',
            icon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 36),

          _buildSaveButton(),
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
        ),
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
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            Text(value),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveLog,
      child: _isSaving
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Save Log Entry'),
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
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: const Center(
        child: Text('Log Saved!', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}