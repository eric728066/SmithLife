import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/user_routine_provider.dart';
import 'workout_models.dart';

class CreateRoutinePage extends ConsumerStatefulWidget {
  const CreateRoutinePage({super.key});

  @override
  ConsumerState<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends ConsumerState<CreateRoutinePage> {
  final _nameCtrl = TextEditingController();
  String? _selectedGoal;
  String? _selectedDifficulty;
  String? _selectedFrequency;
  bool _shareEnabled = false;
  final List<ExerciseData> _exercises = [];

  final List<String> _goals = ['근성장', '다이어트', '체력 증진'];
  final List<String> _difficulties = ['입문', '중급', '고급'];
  final List<String> _frequencies = ['주 1회', '주 2회', '주 3회', '주 4회', '주 5회'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Color _goalIconColor(String goal) {
    switch (goal) {
      case '근성장':
        return const Color(0xFFFF6B35);
      case '다이어트':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF34C759);
    }
  }

  Color _goalIconBg(String goal) {
    switch (goal) {
      case '근성장':
        return const Color(0xFFFFEDE5);
      case '다이어트':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE8F8EC);
    }
  }

  IconData _goalIcon(String goal) {
    switch (goal) {
      case '근성장':
        return Icons.fitness_center;
      case '다이어트':
        return Icons.directions_run;
      default:
        return Icons.flash_on;
    }
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExercisePickerSheet(
        alreadyAdded: _exercises.map((e) => e.name).toSet(),
        onPick: (exercise) {
          setState(() => _exercises.add(exercise));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('루틴 이름을 입력해주세요.')),
      );
      return;
    }
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표를 선택해주세요.')),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('운동을 최소 1개 추가해주세요.')),
      );
      return;
    }

    final goal = _selectedGoal!;
    final estimatedMin = (_exercises.length * 12).clamp(20, 120);
    final routine = RoutineData(
      name: _nameCtrl.text.trim(),
      goal: goal,
      difficulty: _selectedDifficulty ?? '중급',
      duration: '$estimatedMin분',
      frequency: _selectedFrequency ?? '주 3회',
      icon: _goalIcon(goal),
      iconColor: _goalIconColor(goal),
      iconBg: _goalIconBg(goal),
      exercises: List.from(_exercises),
    );

    ref.read(userRoutineProvider.notifier).add(routine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\'${routine.name}\' 루틴이 저장되었습니다!'),
        backgroundColor: AppColors.golden,
      ),
    );
    Navigator.pop(context);
  }

  Widget _chipRow(
      List<String> options, String? selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.golden : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected ? null : Border.all(color: AppColors.lightGray),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          '루틴 만들기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 루틴 이름 ───
            const Text('루틴 이름',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: '루틴 이름을 입력하세요',
                hintStyle:
                    const TextStyle(color: AppColors.gray, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // ─── 목표 ───
            const Text('목표',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 10),
            _chipRow(
                _goals, _selectedGoal, (v) => setState(() => _selectedGoal = v)),
            const SizedBox(height: 24),

            // ─── 난이도 ───
            const Text('난이도',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 10),
            _chipRow(_difficulties, _selectedDifficulty,
                (v) => setState(() => _selectedDifficulty = v)),
            const SizedBox(height: 24),

            // ─── 빈도 ───
            const Text('빈도',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 10),
            _chipRow(_frequencies, _selectedFrequency,
                (v) => setState(() => _selectedFrequency = v)),
            const SizedBox(height: 24),

            // ─── 운동 목록 ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('운동 목록',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black)),
                Text('${_exercises.length}개',
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.golden)),
              ],
            ),
            const SizedBox(height: 10),

            if (_exercises.isNotEmpty)
              ...List.generate(_exercises.length, (i) {
                final ex = _exercises[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.golden)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black)),
                            Text(ex.muscle,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.gray)),
                          ],
                        ),
                      ),
                      Text('${ex.defaultSets}세트',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.gray)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _exercises.removeAt(i)),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.gray),
                      ),
                    ],
                  ),
                );
              }),

            GestureDetector(
              onTap: _addExercise,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.golden.withValues(alpha: 0.5)),
                ),
                child: const Center(
                  child: Text(
                    '+ 운동 추가하기',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.golden,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── 공유하기 ───
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.share_outlined,
                      color: AppColors.golden, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('공유하기',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black)),
                        Text('다른 회원들과 루틴을 공유합니다',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.gray)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _shareEnabled,
                    onChanged: (v) => setState(() => _shareEnabled = v),
                    activeColor: AppColors.golden,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── 저장 버튼 ───
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text(
                  '루틴 저장하기',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 운동 선택 바텀시트 (검색 + 카테고리 필터)
// ─────────────────────────────────────────
class _ExercisePickerSheet extends StatefulWidget {
  final Set<String> alreadyAdded;
  final void Function(ExerciseData) onPick;

  const _ExercisePickerSheet({
    required this.alreadyAdded,
    required this.onPick,
  });

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _category = '전체';

  static const List<String> _categories = [
    '전체', '가슴', '등', '어깨', '삼두', '이두', '하체', '코어', '전신',
  ];

  // 80+ 실제 헬스장 운동 목록
  static const List<Map<String, String>> _allExercises = [
    // ── 가슴 ──
    {'name': '바벨 벤치 프레스', 'muscle': '가슴', 'category': '가슴'},
    {'name': '인클라인 바벨 프레스', 'muscle': '가슴 상부', 'category': '가슴'},
    {'name': '디클라인 바벨 프레스', 'muscle': '가슴 하부', 'category': '가슴'},
    {'name': '인클라인 덤벨 프레스', 'muscle': '가슴 상부', 'category': '가슴'},
    {'name': '덤벨 플라이', 'muscle': '가슴', 'category': '가슴'},
    {'name': '인클라인 덤벨 플라이', 'muscle': '가슴 상부', 'category': '가슴'},
    {'name': '케이블 크로스오버', 'muscle': '가슴 내측', 'category': '가슴'},
    {'name': '딥스', 'muscle': '가슴/삼두', 'category': '가슴'},
    {'name': '푸쉬업', 'muscle': '가슴', 'category': '가슴'},
    {'name': '머신 체스트 프레스', 'muscle': '가슴', 'category': '가슴'},
    {'name': '펙덱 플라이', 'muscle': '가슴 내측', 'category': '가슴'},
    {'name': '클로즈그립 벤치 프레스', 'muscle': '가슴/삼두', 'category': '가슴'},
    // ── 등 ──
    {'name': '바벨 로우', 'muscle': '등 중부', 'category': '등'},
    {'name': '덤벨 로우', 'muscle': '등', 'category': '등'},
    {'name': '원암 덤벨 로우', 'muscle': '등 측면', 'category': '등'},
    {'name': '풀업', 'muscle': '광배근', 'category': '등'},
    {'name': '친업', 'muscle': '광배근/이두', 'category': '등'},
    {'name': '랫 풀다운', 'muscle': '광배근', 'category': '등'},
    {'name': '시티드 케이블 로우', 'muscle': '등 하부', 'category': '등'},
    {'name': 'T바 로우', 'muscle': '등 중부', 'category': '등'},
    {'name': '페이스 풀', 'muscle': '후면 삼각근/등', 'category': '등'},
    {'name': '스트레이트암 풀다운', 'muscle': '광배근', 'category': '등'},
    {'name': '하이퍼익스텐션', 'muscle': '척추기립근', 'category': '등'},
    {'name': '슈러그', 'muscle': '승모근', 'category': '등'},
    {'name': '머신 로우', 'muscle': '등 중부', 'category': '등'},
    // ── 어깨 ──
    {'name': '바벨 오버헤드 프레스', 'muscle': '전면 삼각근', 'category': '어깨'},
    {'name': '덤벨 숄더 프레스', 'muscle': '삼각근', 'category': '어깨'},
    {'name': '아놀드 프레스', 'muscle': '삼각근', 'category': '어깨'},
    {'name': '사이드 레터럴 레이즈', 'muscle': '측면 삼각근', 'category': '어깨'},
    {'name': '프론트 레이즈', 'muscle': '전면 삼각근', 'category': '어깨'},
    {'name': '리어 델트 플라이', 'muscle': '후면 삼각근', 'category': '어깨'},
    {'name': '업라이트 로우', 'muscle': '삼각근/승모근', 'category': '어깨'},
    {'name': '케이블 레터럴 레이즈', 'muscle': '측면 삼각근', 'category': '어깨'},
    {'name': '머신 숄더 프레스', 'muscle': '삼각근', 'category': '어깨'},
    {'name': '케이블 페이스 풀', 'muscle': '후면 삼각근', 'category': '어깨'},
    // ── 삼두 ──
    {'name': '케이블 푸쉬다운', 'muscle': '삼두', 'category': '삼두'},
    {'name': '로프 푸쉬다운', 'muscle': '삼두', 'category': '삼두'},
    {'name': '오버헤드 트라이셉스 익스텐션', 'muscle': '삼두 장두', 'category': '삼두'},
    {'name': '스컬크러셔', 'muscle': '삼두', 'category': '삼두'},
    {'name': '킥백', 'muscle': '삼두', 'category': '삼두'},
    {'name': '다이아몬드 푸쉬업', 'muscle': '삼두', 'category': '삼두'},
    {'name': '벤치 딥스', 'muscle': '삼두', 'category': '삼두'},
    // ── 이두 ──
    {'name': '바벨 컬', 'muscle': '이두', 'category': '이두'},
    {'name': '덤벨 컬', 'muscle': '이두', 'category': '이두'},
    {'name': '해머 컬', 'muscle': '이두/완요골근', 'category': '이두'},
    {'name': '인클라인 덤벨 컬', 'muscle': '이두 장두', 'category': '이두'},
    {'name': '케이블 컬', 'muscle': '이두', 'category': '이두'},
    {'name': '컨센트레이션 컬', 'muscle': '이두', 'category': '이두'},
    {'name': '프리처 컬', 'muscle': '이두 단두', 'category': '이두'},
    {'name': '리버스 컬', 'muscle': '완요골근', 'category': '이두'},
    {'name': '머신 컬', 'muscle': '이두', 'category': '이두'},
    // ── 하체 ──
    {'name': '바벨 스쿼트', 'muscle': '대퇴사두/둔근', 'category': '하체'},
    {'name': '레그 프레스', 'muscle': '대퇴사두', 'category': '하체'},
    {'name': '루마니안 데드리프트', 'muscle': '햄스트링/둔근', 'category': '하체'},
    {'name': '레그 컬', 'muscle': '햄스트링', 'category': '하체'},
    {'name': '레그 익스텐션', 'muscle': '대퇴사두', 'category': '하체'},
    {'name': '카프 레이즈', 'muscle': '종아리', 'category': '하체'},
    {'name': '런지', 'muscle': '대퇴사두/둔근', 'category': '하체'},
    {'name': '불가리안 스플릿 스쿼트', 'muscle': '대퇴사두/둔근', 'category': '하체'},
    {'name': '고블릿 스쿼트', 'muscle': '대퇴사두', 'category': '하체'},
    {'name': '핵 스쿼트', 'muscle': '대퇴사두', 'category': '하체'},
    {'name': '힙 스러스트', 'muscle': '둔근', 'category': '하체'},
    {'name': '수모 스쿼트', 'muscle': '내전근/둔근', 'category': '하체'},
    {'name': '스텝업', 'muscle': '대퇴사두/둔근', 'category': '하체'},
    {'name': '시시 스쿼트', 'muscle': '대퇴사두', 'category': '하체'},
    {'name': '씨티드 카프 레이즈', 'muscle': '종아리 가자미근', 'category': '하체'},
    {'name': '힙 어브덕션', 'muscle': '둔근 중부', 'category': '하체'},
    // ── 코어 ──
    {'name': '플랭크', 'muscle': '코어', 'category': '코어'},
    {'name': '크런치', 'muscle': '복직근', 'category': '코어'},
    {'name': '레그 레이즈', 'muscle': '하복부', 'category': '코어'},
    {'name': '러시안 트위스트', 'muscle': '복사근', 'category': '코어'},
    {'name': 'AB 롤아웃', 'muscle': '코어', 'category': '코어'},
    {'name': '케이블 크런치', 'muscle': '복직근', 'category': '코어'},
    {'name': '사이드 플랭크', 'muscle': '복사근', 'category': '코어'},
    {'name': '마운틴 클라이머', 'muscle': '코어/전신', 'category': '코어'},
    {'name': '바이시클 크런치', 'muscle': '복사근', 'category': '코어'},
    {'name': '행잉 레그 레이즈', 'muscle': '하복부', 'category': '코어'},
    {'name': '브이업', 'muscle': '복직근', 'category': '코어'},
    {'name': '드래곤 플래그', 'muscle': '코어', 'category': '코어'},
    // ── 전신 ──
    {'name': '데드리프트', 'muscle': '전신/척추기립근', 'category': '전신'},
    {'name': '파워 클린', 'muscle': '전신', 'category': '전신'},
    {'name': '케틀벨 스윙', 'muscle': '전신/둔근', 'category': '전신'},
    {'name': '박스 점프', 'muscle': '전신', 'category': '전신'},
    {'name': '버피', 'muscle': '전신', 'category': '전신'},
    {'name': '배틀 로프', 'muscle': '전신', 'category': '전신'},
    {'name': '바벨 스내치', 'muscle': '전신', 'category': '전신'},
    {'name': '터키시 겟업', 'muscle': '전신', 'category': '전신'},
    {'name': '메디신볼 슬램', 'muscle': '전신/코어', 'category': '전신'},
  ];

  List<Map<String, String>> get _filtered => _allExercises.where((e) {
        final matchesSearch =
            _query.isEmpty || e['name']!.contains(_query);
        final matchesCategory =
            _category == '전체' || e['category'] == _category;
        return matchesSearch && matchesCategory;
      }).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          // ─── 헤더 (고정) ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '운동 선택',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black),
                ),
                const SizedBox(height: 12),
                // 검색창
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: '운동 이름으로 검색',
                    hintStyle:
                        const TextStyle(color: AppColors.gray, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          // ─── 카테고리 필터 ───
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.golden : AppColors.cream,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : AppColors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),

          // ─── 운동 목록 ───
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.',
                        style: TextStyle(color: AppColors.gray)))
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: AppColors.lightGray),
                    itemBuilder: (_, i) {
                      final ex = _filtered[i];
                      final alreadyAdded =
                          widget.alreadyAdded.contains(ex['name']);
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          ex['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: alreadyAdded
                                ? AppColors.gray
                                : AppColors.black,
                          ),
                        ),
                        subtitle: Text(
                          ex['muscle']!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.gray),
                        ),
                        trailing: alreadyAdded
                            ? const Icon(Icons.check_circle,
                                color: AppColors.green, size: 22)
                            : const Icon(Icons.add_circle_outline,
                                color: AppColors.golden, size: 22),
                        onTap: alreadyAdded
                            ? null
                            : () => widget.onPick(ExerciseData(
                                  name: ex['name']!,
                                  muscle: ex['muscle']!,
                                  defaultSets: 3,
                                )),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
