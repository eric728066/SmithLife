import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/reservation_repository.dart';

class ShellPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({super.key, required this.navigationShell});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  void _showQRDialog(BuildContext context) async {
    // QR 내용 생성 요청
    String qrContent = '';
    try {
      final repo = ReservationRepository();
      qrContent = await repo.generateQr();
    } catch (_) {
      // 실패 시 로컬 fallback
      qrContent = 'SMITHLIFE:unknown:${DateTime.now().millisecondsSinceEpoch}';
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => _QRDialog(qrContent: qrContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBtn(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: '홈',
              isActive: currentIndex == 0,
              onTap: () => widget.navigationShell.goBranch(0,
                  initialLocation: currentIndex == 0),
            ),
            _NavBtn(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: '예약',
              isActive: currentIndex == 1,
              onTap: () => widget.navigationShell.goBranch(1,
                  initialLocation: currentIndex == 1),
            ),
            // FAB 공간
            const SizedBox(width: 60),
            _NavBtn(
              icon: Icons.fitness_center_outlined,
              activeIcon: Icons.fitness_center,
              label: '워크아웃',
              isActive: currentIndex == 2,
              onTap: () => widget.navigationShell.goBranch(2,
                  initialLocation: currentIndex == 2),
            ),
            _NavBtn(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: '내정보',
              isActive: currentIndex == 3,
              onTap: () => widget.navigationShell.goBranch(3,
                  initialLocation: currentIndex == 3),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: AppColors.orangeBg,
          elevation: 4,
          onPressed: () => _showQRDialog(context),
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.orangeBg : AppColors.gray;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// 실제 QR 코드 다이얼로그
class _QRDialog extends StatelessWidget {
  final String qrContent;

  const _QRDialog({required this.qrContent});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '입장 QR 코드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'QR 코드를 스캐너에 인식시켜 주세요',
              style: TextStyle(fontSize: 13, color: AppColors.gray),
            ),
            const SizedBox(height: 24),
            // 실제 QR 코드 렌더링
            QrImageView(
              data: qrContent,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '5분 후 만료됩니다',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '닫기',
                style: TextStyle(
                    color: AppColors.golden, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
