import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPassword() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    int step = 1;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          Widget stepContent;

          if (step == 1) {
            stepContent = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '가입 시 등록한 이름과 전화번호를 입력하세요.',
                  style: TextStyle(fontSize: 13, color: AppColors.gray),
                ),
                const SizedBox(height: 16),
                _dialogField(nameCtrl, '이름', autofocus: true),
                const SizedBox(height: 10),
                _dialogField(phoneCtrl, '전화번호',
                    keyboardType: TextInputType.phone),
              ],
            );
          } else {
            stepContent = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '사용할 새 비밀번호를 입력하세요.',
                  style: TextStyle(fontSize: 13, color: AppColors.gray),
                ),
                const SizedBox(height: 16),
                _dialogField(newPwCtrl, '새 비밀번호 (8자 이상)',
                    obscureText: true, autofocus: true),
                const SizedBox(height: 10),
                _dialogField(confirmPwCtrl, '비밀번호 확인',
                    obscureText: true),
              ],
            );
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              step == 1 ? '비밀번호 찾기' : '새 비밀번호 설정',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            content: stepContent,
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('취소',
                    style: TextStyle(color: AppColors.gray)),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (step == 1) {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          if (name.isEmpty || phone.isEmpty) return;
                          setS(() => step = 2);
                        } else {
                          final newPw = newPwCtrl.text;
                          final confirmPw = confirmPwCtrl.text;
                          if (newPw.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('비밀번호는 8자 이상이어야 합니다.')),
                            );
                            return;
                          }
                          if (newPw != confirmPw) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('비밀번호가 일치하지 않습니다.')),
                            );
                            return;
                          }
                          setS(() => isLoading = true);
                          try {
                            await AuthRepository().resetPasswordByPhone(
                              name: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              newPassword: newPw,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('비밀번호가 변경되었습니다. 새 비밀번호로 로그인하세요.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (_) {
                            setS(() => isLoading = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('이름 또는 전화번호가 일치하지 않습니다.'),
                                ),
                              );
                            }
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.golden),
                      )
                    : Text(
                        step == 1 ? '다음' : '변경',
                        style: const TextStyle(
                            color: AppColors.golden,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  TextField _dialogField(
    TextEditingController ctrl,
    String hint, {
    bool obscureText = false,
    bool autofocus = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authViewModelProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!success || !mounted) return;
    try {
      final profile = await UserRepository().getMyProfile();
      if (!mounted) return;
      if (profile.role == 'ADMIN') {
        context.go('/admin-home');
      } else {
        context.go('/home');
      }
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.orangeBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                const Text(
                  'SMITHLIFE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.black, fontSize: 15),
                  decoration: _underlineDeco('이메일 주소'),
                  validator: (v) => v == null || v.isEmpty ? '이메일을 입력하세요' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.black, fontSize: 15),
                  decoration: _underlineDeco('비밀번호'),
                  validator: (v) => v == null || v.isEmpty ? '비밀번호를 입력하세요' : null,
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    authState.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 36),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text(
                            '로그인',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.push('/signup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: const BorderSide(color: AppColors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('아이디(이메일) 찾기',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.black.withOpacity(0.6))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('|',
                          style: TextStyle(
                              color: AppColors.black.withOpacity(0.3))),
                    ),
                    GestureDetector(
                      onTap: _showForgotPassword,
                      child: Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.black.withOpacity(0.6),
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.black.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  InputDecoration _underlineDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: AppColors.black.withOpacity(0.45), fontSize: 15),
      enabledBorder: UnderlineInputBorder(
        borderSide:
            BorderSide(color: AppColors.black.withOpacity(0.3), width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.black, width: 1.5),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
