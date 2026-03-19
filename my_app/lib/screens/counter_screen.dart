import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_theme.dart';
import '../main.dart'; // WHY: AppRoutes lives in main.dart

// ─────────────────────────────────────────────
//  CounterScreen
//  Live camera viewfinder → capture → fake
//  TFLite inference (dummy count = 42) →
//  bottom sheet result → navigate to log form
// ─────────────────────────────────────────────

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with WidgetsBindingObserver {
  // ── camera state ──────────────────────────
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  String? _cameraError;

  // ── capture state ─────────────────────────
  bool _isProcessing = false; // true while "running inference"
  bool _imageCaptured = false; // true after shutter pressed

  // ── dummy result ──────────────────────────
  // TODO(Step 7): replace with real TFLiteService.runInference()
  static const int _dummyCount = 42;
  static const String _dummyMaterial = 'Bolts'; // placeholder label

  // ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // Pause / resume camera with app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ── camera init ───────────────────────────
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _cameraError = 'No cameras found on this device.');
        return;
      }

      final controller = CameraController(
        _cameras.first, // rear camera
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // Guard against widget being disposed before async completes
      if (!mounted) return;

      setState(() {
        _controller = controller;
        _isCameraReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Camera error: ${e.toString()}';
      });
    }
  }

  // ── shutter pressed ───────────────────────
  Future<void> _onCapture() async {
    if (!_isCameraReady || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _imageCaptured = true;
    });

    // Simulate TFLite inference delay (~1.5 s)
    // TODO(Step 7): replace with actual TFLiteService call
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    // Show result bottom sheet
    _showResultSheet();
  }

  // ── retake ────────────────────────────────
  void _onRetake() {
    Navigator.of(context).pop(); // close bottom sheet
    setState(() {
      _imageCaptured = false;
      _isProcessing = false;
    });
  }

  // ─────────────────────────────────────────
  //  Result bottom sheet
  // ─────────────────────────────────────────
  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false, // force user to pick Retake or Save
      enableDrag: false,
      builder: (_) => _ResultSheet(
        count: _dummyCount,
        material: _dummyMaterial,
        onRetake: _onRetake,
        onSaveLog: _navigateToLogForm,
      ),
    );
  }

  // ── navigate to log form ──────────────────
  void _navigateToLogForm() {
    Navigator.of(context).pop(); // close bottom sheet

    // TODO: pass real count + material once TFLite is wired in Step 7
    Navigator.of(context).pushNamed(
      AppRoutes.logForm,
      arguments: {
        'count': _dummyCount,
        'material': _dummyMaterial,
      },
    );

    // Reset state so screen is clean next visit
    setState(() {
      _imageCaptured = false;
    });
  }

  // ─────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. camera preview / error / loading ──
          _buildCameraLayer(),

          // ── 2. dark gradient overlay (top + bottom) ──
          _buildGradientOverlay(),

          // ── 3. top bar ──
          _buildTopBar(),

          // ── 4. processing overlay (while "running inference") ──
          if (_isProcessing) _buildProcessingOverlay(),

          // ── 5. bottom controls ──
          if (!_isProcessing) _buildBottomControls(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Camera layer
  // ─────────────────────────────────────────
  Widget _buildCameraLayer() {
    // Error state
    if (_cameraError != null) {
      return Container(
        color: AppTheme.primaryDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_outlined,
                    color: AppTheme.accent, size: 56),
                const SizedBox(height: 16),
                Text(
                  _cameraError!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Loading state
    if (!_isCameraReady) {
      return Container(
        color: AppTheme.primaryDark,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Live preview — fill screen and maintain aspect ratio
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Gradient overlay (readability)
  // ─────────────────────────────────────────
  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.25, 0.70, 1.0],
          colors: [
            Colors.black.withOpacity(0.65),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.80),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Top bar
  // ─────────────────────────────────────────
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
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
                  'Counter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Spacer to balance back arrow and keep title centred
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Processing overlay (simulated inference)
  // ─────────────────────────────────────────
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing teal ring
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 2.5),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 2.5,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scaleXY(end: 1.08, duration: 700.ms, curve: Curves.easeInOut)
                .then()
                .scaleXY(end: 1.0, duration: 700.ms, curve: Curves.easeInOut),

            const SizedBox(height: 20),

            const Text(
              'Counting items…',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Running detection model',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Bottom controls (shutter button)
  // ─────────────────────────────────────────
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _imageCaptured ? '' : 'Point camera at hardware, then capture',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _isCameraReady && !_isProcessing ? _onCapture : null,
                child: _ShutterButton(
                    enabled: _isCameraReady && !_isProcessing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shutter Button widget
// ─────────────────────────────────────────────
class _ShutterButton extends StatelessWidget {
  final bool enabled;
  const _ShutterButton({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate(target: enabled ? 1 : 0)
        .scaleXY(begin: 0.95, end: 1.0, duration: 150.ms);
  }
}

// ─────────────────────────────────────────────
//  Result Bottom Sheet
// ─────────────────────────────────────────────
class _ResultSheet extends StatelessWidget {
  final int count;
  final String material;
  final VoidCallback onRetake;
  final VoidCallback onSaveLog;

  const _ResultSheet({
    required this.count,
    required this.material,
    required this.onRetake,
    required this.onSaveLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Count Result',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 28),

          // Big count number + material label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              )
                  .animate()
                  .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic)
                  .fadeIn(duration: 350.ms),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  material,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 450.ms,
                        curve: Curves.easeOutCubic)
                    .fadeIn(duration: 400.ms),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Detected by on-device model',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 36),

          // Retake + Save Log buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetake,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retake',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onSaveLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Save Log',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              .animate()
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 150.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic)
              .fadeIn(delay: 150.ms, duration: 350.ms),

          // Dev note — delete this Container once TFLite is wired in Step 7
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.amber, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Dummy count — TFLite wired in Step 7',
                  style: TextStyle(
                    color: Colors.amber.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}