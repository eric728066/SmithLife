import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

// ─── 문의 모델 ─────────────────────────────────────────────────────────────────

class _InquiryRecord {
  final String category;
  final String title;
  final String content;
  final DateTime createdAt;

  const _InquiryRecord({
    required this.category,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

// ─── InquiryPage ──────────────────────────────────────────────────────────────

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<_InquiryRecord> _myInquiries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '문의하기',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.black,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.orangeBg,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: '자주 묻는 질문'),
            Tab(text: '1:1 문의'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewInquiryDialog(context),
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('새 문의',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _FaqTab(),
          _MyInquiryTab(
            inquiries: _myInquiries,
            onNewInquiry: () => _showNewInquiryDialog(context),
          ),
        ],
      ),
    );
  }

  void _showNewInquiryDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedCategory = '예약';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('새 문의 작성',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // 카테고리 선택
                  const Text('카테고리',
                      style: TextStyle(fontSize: 12, color: AppColors.gray)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['예약', '멤버십', '운동', '시설', '기타']
                        .map((cat) => ChoiceChip(
                              label: Text(cat),
                              selected: selectedCategory == cat,
                              selectedColor: AppColors.orangeBg,
                              labelStyle: TextStyle(
                                color: selectedCategory == cat
                                    ? Colors.white
                                    : AppColors.black,
                                fontSize: 13,
                              ),
                              onSelected: (_) =>
                                  setS(() => selectedCategory = cat),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  // 제목
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: '문의 제목',
                      labelStyle: const TextStyle(
                          fontSize: 13, color: AppColors.gray),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.golden),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 내용
                  TextField(
                    controller: contentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: '문의 내용',
                      alignLabelWithHint: true,
                      labelStyle: const TextStyle(
                          fontSize: 13, color: AppColors.gray),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.golden),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.isEmpty ||
                            contentCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('제목과 내용을 입력해주세요.')),
                          );
                          return;
                        }
                        final record = _InquiryRecord(
                          category: selectedCategory,
                          title: titleCtrl.text,
                          content: contentCtrl.text,
                          createdAt: DateTime.now(),
                        );
                        Navigator.pop(ctx);
                        setState(() {
                          _myInquiries.insert(0, record);
                        });
                        // 1:1 문의 탭으로 이동
                        _tabController.animateTo(1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('문의가 접수되었습니다. 1-2 영업일 내로 답변 드립니다.'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('문의 제출',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── FAQ 탭 ───────────────────────────────────────────────────────────────────

class _FaqTab extends StatelessWidget {
  const _FaqTab();

  static const _faqList = [
    _FaqItem(
      question: '예약은 어떻게 하나요?',
      answer:
          '앱 하단 탭의 "예약" 메뉴를 통해 원하는 날짜와 시간대를 선택하여 예약할 수 있습니다. 예약 가능한 시간은 09:00~21:00이며, 시간당 1회 예약이 가능합니다.',
    ),
    _FaqItem(
      question: '예약 취소는 어떻게 하나요?',
      answer:
          '예약 현황 화면에서 취소하고 싶은 예약을 선택 후 "예약 취소" 버튼을 눌러 취소할 수 있습니다. 예약 시간 2시간 전까지 취소 가능합니다.',
    ),
    _FaqItem(
      question: 'QR 출석 방법이 궁금해요.',
      answer:
          '홈 화면 상단의 QR 아이콘을 눌러 QR 코드를 표시한 후, 직원에게 제시하거나 키오스크에 인식시키면 출석이 완료됩니다.',
    ),
    _FaqItem(
      question: '회원권 연장은 어떻게 하나요?',
      answer:
          '회원권 연장은 센터 데스크 또는 고객센터(02-1234-5678)를 통해 진행하실 수 있습니다. 앱 내 온라인 결제 기능은 준비 중입니다.',
    ),
    _FaqItem(
      question: '운동 루틴은 어떻게 만드나요?',
      answer:
          '"운동" 탭 → "루틴 선택" → "내 루틴 만들기" 버튼을 눌러 루틴 이름, 목표, 운동 목록을 설정하여 나만의 루틴을 만들 수 있습니다.',
    ),
    _FaqItem(
      question: '비밀번호를 잊어버렸어요.',
      answer:
          '로그인 화면에서 "비밀번호 찾기"를 통해 가입하신 이메일로 임시 비밀번호를 받으실 수 있습니다. 또는 고객센터로 문의해 주세요.',
    ),
    _FaqItem(
      question: '센터 운영 시간이 어떻게 되나요?',
      answer:
          '평일(월~금) 06:00 ~ 23:00, 주말(토~일) 08:00 ~ 22:00로 운영됩니다. 공휴일은 별도 공지를 확인해주세요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 고객센터 배너
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.orangeBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.headset_mic, color: Colors.white, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('고객센터',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('평일 09:00 - 21:00 · 02-1234-5678',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('자주 묻는 질문',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black)),
        const SizedBox(height: 12),

        // FAQ 아코디언
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: _faqList
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        _FaqTile(item: e.value),
                        if (e.key < _faqList.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqTile extends StatelessWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 14),
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.orangeBg.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text('Q',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeBg)),
        ),
      ),
      title: Text(item.question,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black)),
      iconColor: AppColors.gray,
      collapsedIconColor: AppColors.gray,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.answer,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray,
                      height: 1.6)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── 1:1 문의 탭 ──────────────────────────────────────────────────────────────

class _MyInquiryTab extends StatelessWidget {
  final List<_InquiryRecord> inquiries;
  final VoidCallback onNewInquiry;
  const _MyInquiryTab({required this.inquiries, required this.onNewInquiry});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${dt.month}월 ${dt.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('내 문의 내역',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black)),
        const SizedBox(height: 12),

        if (inquiries.isEmpty)
          // 빈 상태
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('문의 내역이 없습니다',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400])),
                const SizedBox(height: 6),
                Text('궁금한 점이 있으시면 새 문의를 작성해 주세요',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[400])),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onNewInquiry,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('새 문의 작성'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          )
        else
          // 문의 목록
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: inquiries.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카테고리 뱃지
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.orangeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.content,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      height: 1.4),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      _timeAgo(item.createdAt),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400]),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '답변 대기',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (idx < inquiries.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 80),
      ],
    );
  }
}
