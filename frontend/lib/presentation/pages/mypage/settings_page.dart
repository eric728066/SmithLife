import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

// ─── 다크 모드 Provider ───────────────────────────────────────────────────────

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>(
  (ref) => DarkModeNotifier(),
);

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dark_mode') ?? false;
  }

  Future<void> toggle(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', v);
  }
}

// ─── SettingsPage ─────────────────────────────────────────────────────────────

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '설정',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 앱 설정
            _SectionHeader(label: '앱 설정'),
            _SettingsCard(children: [
              _NavRow(
                icon: Icons.notifications_outlined,
                label: '알림 설정',
                onTap: () => context.push('/notification'),
              ),
              const _Divider(),
              _ToggleRow(
                icon: Icons.dark_mode_outlined,
                label: '다크 모드',
                subtitle: '준비 중',
                value: isDark,
                onChanged: (v) {
                  ref.read(darkModeProvider.notifier).toggle(v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('다크 모드는 곧 지원될 예정입니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const _Divider(),
              _NavRow(
                icon: Icons.language,
                label: '언어 설정',
                trailing: const Text('한국어',
                    style: TextStyle(fontSize: 13, color: AppColors.gray)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('현재 한국어만 지원합니다.'),
                        duration: Duration(seconds: 2)),
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // ── 계정
            _SectionHeader(label: '계정'),
            _SettingsCard(children: [
              _NavRow(
                icon: Icons.lock_outline,
                label: '비밀번호 변경',
                onTap: () => _showPasswordDialog(context),
              ),
              const _Divider(),
              _NavRow(
                icon: Icons.logout,
                label: '로그아웃',
                iconColor: Colors.red,
                labelColor: Colors.red,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              const _Divider(),
              _NavRow(
                icon: Icons.person_off_outlined,
                label: '회원 탈퇴',
                iconColor: Colors.red,
                labelColor: Colors.red,
                onTap: () => _showDeleteDialog(context, ref),
              ),
            ]),

            const SizedBox(height: 20),

            // ── 정보
            _SectionHeader(label: '정보'),
            _SettingsCard(children: [
              _NavRow(
                icon: Icons.campaign_outlined,
                label: '공지사항',
                onTap: () => context.push('/notification'),
              ),
              const _Divider(),
              _NavRow(
                icon: Icons.description_outlined,
                label: '이용약관',
                onTap: () => _showTermsDialog(context, '이용약관', _termsText),
              ),
              const _Divider(),
              _NavRow(
                icon: Icons.privacy_tip_outlined,
                label: '개인정보 처리방침',
                onTap: () =>
                    _showTermsDialog(context, '개인정보 처리방침', _privacyText),
              ),
              const _Divider(),
              _NavRow(
                icon: Icons.info_outline,
                label: '앱 버전',
                trailing: const Text('1.0.0',
                    style: TextStyle(fontSize: 13, color: AppColors.gray)),
                onTap: null,
              ),
            ]),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── 비밀번호 변경 다이얼로그
  void _showPasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => _PasswordDialog(
        currentCtrl: currentCtrl,
        newCtrl: newCtrl,
        confirmCtrl: confirmCtrl,
        onConfirm: () {
          if (currentCtrl.text.isEmpty ||
              newCtrl.text.isEmpty ||
              confirmCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('모든 항목을 입력해주세요.')),
            );
            return;
          }
          if (newCtrl.text != confirmCtrl.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')),
            );
            return;
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
          );
        },
      ),
    );
  }

  // ── 로그아웃 확인
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('로그아웃',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: const Text('정말 로그아웃 하시겠습니까?',
            style: TextStyle(fontSize: 14, color: AppColors.gray)),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('로그아웃',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── 회원 탈퇴 확인
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.red, size: 44),
        title: const Text('회원 탈퇴',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: const Text(
          '탈퇴 시 모든 운동 기록과\n예약 내역이 삭제됩니다.\n정말 탈퇴하시겠습니까?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.gray),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('취소',
                style: TextStyle(color: AppColors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }

  // ── 약관 다이얼로그
  void _showTermsDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 280,
          child: SingleChildScrollView(
            child: Text(content,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.gray, height: 1.6)),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  static const _termsText = '''
제1조 (목적)
본 약관은 SmithLife(이하 "회사")가 제공하는 피트니스 센터 관리 서비스(이하 "서비스")의 이용 조건 및 절차, 회사와 이용자의 권리·의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (정의)
① "서비스"란 회사가 제공하는 모바일 앱 기반 피트니스 관리 서비스를 의미합니다.
② "이용자"란 본 약관에 따라 서비스를 이용하는 회원을 말합니다.

제3조 (약관의 효력 및 변경)
① 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력이 발생합니다.
② 회사는 합리적인 사유가 있는 경우 약관을 변경할 수 있으며, 변경된 약관은 공지 후 7일이 지난 시점부터 효력이 발생합니다.

제4조 (이용 계약의 성립)
이용 계약은 이용자가 약관에 동의하고 회원가입 신청을 하면 회사가 이를 승낙함으로써 성립됩니다.

제5조 (개인정보 보호)
회사는 이용자의 개인정보를 중요시하며, 개인정보 처리방침에 따라 적절한 보호 조치를 취합니다.

제6조 (서비스 이용)
이용자는 서비스를 이용할 때 관련 법령, 본 약관 및 회사의 정책을 준수해야 합니다.

제7조 (서비스 중단)
회사는 시스템 점검, 긴급 상황 등의 경우 서비스를 일시 중단할 수 있으며, 이를 사전에 공지합니다.
''';

  static const _privacyText = '''
SmithLife는 이용자의 개인정보를 소중히 생각하며, 아래와 같이 개인정보 처리방침을 정하여 이용자의 개인정보 보호에 최선을 다하고 있습니다.

1. 수집하는 개인정보의 항목
· 필수항목: 이름, 이메일, 비밀번호, 전화번호
· 자동 수집: 기기 정보, 서비스 이용 기록

2. 개인정보의 수집 및 이용 목적
· 회원 가입 및 관리
· 서비스 제공 (예약, 출석, 운동 기록 등)
· 고객 지원 및 불만 처리

3. 개인정보의 보유 및 이용 기간
· 회원 탈퇴 시까지 보유
· 단, 관련 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 보관

4. 개인정보의 파기
보유 기간 만료 또는 이용 목적 달성 시 즉시 파기하며, 전자적 파일은 복구 불가능한 방법으로 삭제합니다.

5. 이용자의 권리
이용자는 언제든지 자신의 개인정보를 열람, 수정, 삭제하거나 처리 정지를 요청할 수 있습니다.

문의: support@smithlife.com
''';
}

// ─── 섹션 헤더 ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray,
            letterSpacing: 0.5),
      ),
    );
  }
}

// ─── 설정 카드 ─────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, endIndent: 0);
  }
}

// ─── 네비게이션 행 ──────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _NavRow({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.black,
    this.labelColor = AppColors.black,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor)),
            ),
            trailing ??
                Icon(Icons.chevron_right,
                    size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ─── 토글 행 ───────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.gray)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.orangeBg,
          ),
        ],
      ),
    );
  }
}

// ─── 비밀번호 변경 다이얼로그 ──────────────────────────────────────────────────

class _PasswordDialog extends StatefulWidget {
  final TextEditingController currentCtrl;
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;
  final VoidCallback onConfirm;

  const _PasswordDialog({
    required this.currentCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.onConfirm,
  });

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _obscure3 = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: const Text('비밀번호 변경',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PwField(
              controller: widget.currentCtrl,
              label: '현재 비밀번호',
              obscure: _obscure1,
              onToggle: () => setState(() => _obscure1 = !_obscure1),
            ),
            const SizedBox(height: 12),
            _PwField(
              controller: widget.newCtrl,
              label: '새 비밀번호',
              obscure: _obscure2,
              onToggle: () => setState(() => _obscure2 = !_obscure2),
            ),
            const SizedBox(height: 12),
            _PwField(
              controller: widget.confirmCtrl,
              label: '새 비밀번호 확인',
              obscure: _obscure3,
              onToggle: () => setState(() => _obscure3 = !_obscure3),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('취소', style: TextStyle(color: AppColors.gray)),
        ),
        ElevatedButton(
          onPressed: widget.onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('변경'),
        ),
      ],
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PwField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(fontSize: 13, color: AppColors.gray),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.golden),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              size: 18, color: AppColors.gray),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
