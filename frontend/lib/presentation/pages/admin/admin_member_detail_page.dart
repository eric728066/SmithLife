import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/admin/admin_member.dart';
import '../../../data/models/membership/membership.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminMemberDetailPage extends StatefulWidget {
  final AdminMember member;

  const AdminMemberDetailPage({super.key, required this.member});

  @override
  State<AdminMemberDetailPage> createState() => _AdminMemberDetailPageState();
}

class _AdminMemberDetailPageState extends State<AdminMemberDetailPage> {
  late AdminMember _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await AdminRepository().getMemberDetail(_member.userId);
      if (mounted) setState(() => _member = detail);
    } catch (_) {}
  }

  void _showRegisterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RegisterMembershipSheet(
        userId: _member.userId,
        onSuccess: () {
          Navigator.pop(ctx);
          _loadDetail();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _member;
    final active = profile.activeMembership;
    final history = profile.membershipHistory ?? [];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          '${profile.name}님 상세',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8878A),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0] : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _InfoRow(label: '전화번호', value: profile.phone),
                  const SizedBox(height: 8),
                  _InfoRow(label: '계정 상태', value: profile.isActive ? '활성' : '탈퇴'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 현재 회원권
            _SectionHeader(
              title: '현재 회원권',
              trailing: TextButton.icon(
                onPressed: _showRegisterSheet,
                icon: const Icon(Icons.add, size: 16, color: AppColors.golden),
                label: const Text(
                  '회원권 등록',
                  style: TextStyle(color: AppColors.golden, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            active == null
                ? _EmptyCard(message: '활성 회원권이 없습니다.')
                : _MembershipCard(membership: active, isActive: true),
            const SizedBox(height: 16),

            // 회원권 이력
            _SectionHeader(title: '회원권 이력'),
            const SizedBox(height: 8),
            if (history.isEmpty)
              _EmptyCard(message: '회원권 이력이 없습니다.')
            else
              ...history.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MembershipCard(membership: m, isActive: false),
                  )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.gray)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black)),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(message,
            style: const TextStyle(color: AppColors.gray, fontSize: 14)),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final Membership membership;
  final bool isActive;

  const _MembershipCard({required this.membership, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: AppColors.green.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${membership.startDate} ~ ${membership.endDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(membership.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(membership.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(membership.status),
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                Text(
                  'D-${membership.remainingDays}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeBg,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.green;
      case 'EXPIRED':
        return AppColors.gray;
      case 'PAUSED':
        return AppColors.amber;
      case 'CANCELLED':
        return AppColors.red;
      default:
        return AppColors.gray;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return '활성';
      case 'EXPIRED':
        return '만료';
      case 'PAUSED':
        return '일시정지';
      case 'CANCELLED':
        return '취소';
      default:
        return status;
    }
  }
}

// ─── 회원권 등록 Bottom Sheet ────────────────────────────────────────────────

class _RegisterMembershipSheet extends StatefulWidget {
  final int userId;
  final VoidCallback onSuccess;

  const _RegisterMembershipSheet(
      {required this.userId, required this.onSuccess});

  @override
  State<_RegisterMembershipSheet> createState() =>
      _RegisterMembershipSheetState();
}

class _RegisterMembershipSheetState extends State<_RegisterMembershipSheet> {
  final _typeController = TextEditingController();
  String? _selectedPreset;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<String> _presets = ['1개월', '3개월', '6개월', '12개월'];

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate ?? DateTime.now()));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '날짜 선택';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final type = _selectedPreset ?? _typeController.text.trim();
    if (type.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종류, 시작일, 종료일을 모두 입력해주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AdminRepository().registerMembership(
        userId: widget.userId,
        type: type,
        startDate: _fmt(_startDate),
        endDate: _fmt(_endDate),
      );
      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원권 등록에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '회원권 등록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text('회원권 종류',
                style: TextStyle(fontSize: 13, color: AppColors.gray)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _presets.map((p) {
                final selected = _selectedPreset == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _selectedPreset = selected ? null : p;
                    if (!selected) _typeController.clear();
                  }),
                  selectedColor: AppColors.orangeBg,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.black,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: '직접 입력 (예: 무제한)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() => _selectedPreset = null),
            ),
            const SizedBox(height: 16),
            const Text('기간',
                style: TextStyle(fontSize: 13, color: AppColors.gray)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: '시작일',
                    value: _fmt(_startDate),
                    onTap: () => _pickDate(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~', style: TextStyle(color: AppColors.gray)),
                ),
                Expanded(
                  child: _DateButton(
                    label: '종료일',
                    value: _fmt(_endDate),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateButton(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.gray)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
