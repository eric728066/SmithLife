import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '개인정보처리방침',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _PolicyContent(),
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Section(
          title: '개인정보처리방침',
          body:
              'SMITHLIFE(이하 "서비스")는 이용자의 개인정보를 중요하게 생각하며, '
              '「개인정보 보호법」을 준수합니다. 본 방침은 서비스 이용 과정에서 '
              '수집되는 개인정보의 처리에 관한 사항을 안내합니다.',
        ),
        _Section(
          title: '1. 수집하는 개인정보 항목',
          body: '• 필수 항목: 이름, 이메일 주소, 비밀번호, 전화번호\n'
              '• 서비스 이용 중 자동 생성: 출석 기록, 운동 기록, 예약 내역',
        ),
        _Section(
          title: '2. 개인정보 수집 및 이용 목적',
          body: '• 회원 식별 및 서비스 제공\n'
              '• 헬스장 출입 및 출석 관리\n'
              '• 운동 기록 및 루틴 관리\n'
              '• 시설 예약 서비스 제공\n'
              '• 공지사항 및 서비스 안내',
        ),
        _Section(
          title: '3. 개인정보 보유 및 이용 기간',
          body: '• 회원 탈퇴 시까지 보유 후 즉시 파기\n'
              '• 단, 관계 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관\n'
              '  - 계약 또는 청약철회 기록: 5년 (전자상거래법)\n'
              '  - 소비자 불만 또는 분쟁 처리 기록: 3년 (전자상거래법)',
        ),
        _Section(
          title: '4. 개인정보의 제3자 제공',
          body: '서비스는 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. '
              '단, 이용자가 사전에 동의한 경우 또는 법령에 따른 요청이 있는 경우는 예외로 합니다.',
        ),
        _Section(
          title: '5. 개인정보 처리의 위탁',
          body: '현재 개인정보 처리 업무를 외부에 위탁하지 않습니다.',
        ),
        _Section(
          title: '6. 개인정보의 파기',
          body: '보유 기간이 경과하거나 목적이 달성된 개인정보는 지체 없이 파기합니다.\n'
              '• 전자적 파일: 복구 불가능한 방법으로 영구 삭제\n'
              '• 출력물: 분쇄 또는 소각',
        ),
        _Section(
          title: '7. 이용자의 권리',
          body: '이용자는 언제든지 다음 권리를 행사할 수 있습니다.\n'
              '• 개인정보 열람 요청\n'
              '• 오류 정정 요청\n'
              '• 삭제 요청 (회원 탈퇴)\n'
              '• 처리 정지 요청\n\n'
              '앱 내 마이페이지 또는 고객센터를 통해 요청 가능합니다.',
        ),
        _Section(
          title: '8. 개인정보 보호책임자',
          body: '개인정보 처리 관련 문의, 불만, 피해 구제 등은 아래로 연락 바랍니다.\n'
              '• 서비스명: SMITHLIFE\n'
              '• 문의: 앱 내 문의하기',
        ),
        _Section(
          title: '9. 개인정보처리방침 변경',
          body: '본 방침은 법령·정책 변경에 따라 수정될 수 있으며, '
              '변경 시 앱 공지사항을 통해 사전 안내합니다.',
        ),
        SizedBox(height: 8),
        Text(
          '시행일: 2026년 6월 11일',
          style: TextStyle(fontSize: 13, color: AppColors.gray),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444444),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
