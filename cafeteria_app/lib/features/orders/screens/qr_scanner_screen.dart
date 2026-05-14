import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/order_service.dart';
import '../../../core/constants/app_colors.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isScanning = false);
    await _verify(code);
  }

  Future<void> _verify(String qrToken) async {
    final token = ref.read(authProvider).token;
    if (token == null) return;
    final service = OrderService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await service.verifyQR(qrToken, token);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        await _showVerifiedSheet(data);
      } else {
        _showError(res['message'] ?? 'Verification failed');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showError('Connection error');
    }
  }

  Future<void> _showVerifiedSheet(Map<String, dynamic> order) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: AppColors.successDark, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Verified',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Order #${order['id']}',
                          style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                      const SizedBox(height: 2),
                      const Text('Serve Food',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/cashier/order-detail', extra: order).then((_) {
                      setState(() => _isScanning = true);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Open',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isScanning = true);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Next Scan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: CustomPaint(painter: _CornerPainter()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan student QR receipt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Position the QR code within the frame to\nconfirm payment',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circleAction(
                  Icons.flash_on,
                  onTap: () {
                    _controller.toggleTorch();
                    setState(() => _torchOn = !_torchOn);
                  },
                  background: Colors.white,
                  fg: AppColors.navyBlue,
                  highlighted: _torchOn,
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
                _circleAction(
                  Icons.image_outlined,
                  onTap: () {},
                  background: Colors.white,
                  fg: AppColors.navyBlue,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _circleAction(IconData icon,
      {required VoidCallback onTap,
      required Color background,
      required Color fg,
      bool highlighted = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: highlighted ? AppColors.orange : background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: highlighted ? Colors.white : fg),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navyBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 28.0;

    // top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLen, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLen), paint);
    // top-right
    canvas.drawLine(Offset(size.width - cornerLen, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLen), paint);
    // bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLen), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLen, size.height), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width, size.height - cornerLen), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - cornerLen, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}
