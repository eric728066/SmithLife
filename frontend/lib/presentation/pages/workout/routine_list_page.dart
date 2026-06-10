import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/user_routine_provider.dart';
import 'workout_models.dart';

class RoutineListPage extends ConsumerStatefulWidget {
  const RoutineListPage({super.key});

  @override
  ConsumerState<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends ConsumerState<RoutineListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RoutineData> _filterList(List<RoutineData> list) => list
      .where((r) => r.name.contains(_query) || r.goal.contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    final userRoutines = ref.watch(userRoutineProvider);
    final filteredUser = _filterList(userRoutines);
    final filteredPreset = _filterList(kRoutines);

    final hasResults = filteredUser.isNotEmpty || filteredPreset.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '루틴 선택',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── 검색창 ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '루틴 검색',
                hintStyle:
                    const TextStyle(color: AppColors.gray, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.gray),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ─── 루틴 목록 (스크롤) ───
          Expanded(
            child: !hasResults
                ? const Center(
                    child: Text('검색 결과가 없습니다.',
                        style: TextStyle(color: AppColors.gray)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 나만의 루틴 섹션
                        if (filteredUser.isNotEmpty) ...[
                          _SectionHeader(
                              title: '나만의 루틴',
                              count: filteredUser.length),
                          const SizedBox(height: 12),
                          _RoutineGrid(
                            routines: filteredUser,
                            onTap: (r) =>
                                context.push('/routine-detail', extra: r),
                            onDelete: (r) => ref
                                .read(userRoutineProvider.notifier)
                                .removeByName(r.name),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 추천 루틴 섹션
                        if (filteredPreset.isNotEmpty) ...[
                          _SectionHeader(
                              title: '추천 루틴',
                              count: filteredPreset.length),
                          const SizedBox(height: 12),
                          _RoutineGrid(
                            routines: filteredPreset,
                            onTap: (r) =>
                                context.push('/routine-detail', extra: r),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),

          // ─── 나만의 루틴 만들기 버튼 ───
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/create-routine'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    '나만의 루틴 만들기',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 섹션 헤더
// ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

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
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.golden.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.golden,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// 루틴 그리드
// ─────────────────────────────────────────
class _RoutineGrid extends StatelessWidget {
  final List<RoutineData> routines;
  final void Function(RoutineData) onTap;
  final void Function(RoutineData)? onDelete;

  const _RoutineGrid(
      {required this.routines, required this.onTap, this.onDelete});

  void _confirmDelete(
      BuildContext context, String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('루틴 삭제',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('\'$name\' 루틴을 삭제하시겠습니까?',
            style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: routines.length,
      itemBuilder: (ctx, i) {
        final r = routines[i];
        return GestureDetector(
          onTap: () => onTap(r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 컬러 헤더 ──
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: r.iconBg,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(r.icon,
                            color: r.iconColor, size: 40),
                      ),
                      if (onDelete != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _confirmDelete(
                                ctx, r.name, () => onDelete!(r)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_outline,
                                  size: 14, color: AppColors.gray),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // ── 텍스트 영역 ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.frequency,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500]),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: r.iconBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                r.difficulty,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: r.iconColor),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              r.duration,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.gray),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
