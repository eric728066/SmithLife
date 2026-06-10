import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/viewmodels/workout_session_provider.dart';

class WorkoutSet {
  double kg;
  int reps;
  bool done;
  WorkoutSet({this.kg = 0, this.reps = 0, this.done = false});
}

class WorkoutDetailPage extends ConsumerStatefulWidget {
  final String exerciseName;
  final String muscle;
  final int exerciseIndex; // -1이면 세션 미연동

  const WorkoutDetailPage({
    super.key,
    required this.exerciseName,
    required this.muscle,
    this.exerciseIndex = -1,
  });

  @override
  ConsumerState<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends ConsumerState<WorkoutDetailPage> {
  final List<WorkoutSet> _sets = [
    WorkoutSet(kg: 60, reps: 10),
    WorkoutSet(kg: 65, reps: 8),
    WorkoutSet(kg: 70, reps: 6),
  ];

  // 휴식 타이머
  int _restSeconds = 0;
  Timer? _timer;
  bool _timerRunning = false;

  void _startTimer() {
    setState(() {
      _restSeconds = 90;
      _timerRunning = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_restSeconds > 0) {
          _restSeconds--;
        } else {
          _timerRunning = false;
          t.cancel();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _restSeconds = 0;
      _timerRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addSet() {
    setState(() => _sets.add(WorkoutSet(kg: 0, reps: 0)));
  }

  void _completeSet(int index) {
    setState(() => _sets[index].done = !_sets[index].done);
    if (!_sets[index].done) return;
    _startTimer();
    // 모든 세트 완료 시 → 세션에 자동 반영 + 볼륨 저장
    if (_sets.every((s) => s.done) && widget.exerciseIndex >= 0) {
      final notifier = ref.read(workoutSessionProvider.notifier);
      notifier.completeExercise(widget.exerciseIndex);
      // 완료된 세트 기준 볼륨 계산 (kg × reps)
      final volume =
          _sets.where((s) => s.done).fold(0.0, (sum, s) => sum + s.kg * s.reps);
      notifier.setExerciseVolume(widget.exerciseIndex, volume);
    }
  }

  String _timerLabel() {
    final m = _restSeconds ~/ 60;
    final s = _restSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _sets.where((s) => s.done).length;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            Text(
              widget.muscle,
              style: const TextStyle(fontSize: 12, color: AppColors.gray),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 세트 진행 현황
                  Text(
                    '$completedCount/${_sets.length} 세트 완료',
                    style: const TextStyle(fontSize: 13, color: AppColors.gray),
                  ),
                  const SizedBox(height: 12),

                  // 세트 테이블 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text('세트',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Expanded(
                          child: Text('KG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Expanded(
                          child: Text('횟수',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text('완료',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 세트 리스트
                  ...List.generate(_sets.length, (i) {
                    final s = _sets[i];
                    return _SetRow(
                      index: i,
                      set: s,
                      onChanged: (kg, reps) {
                        setState(() {
                          _sets[i].kg = kg;
                          _sets[i].reps = reps;
                        });
                      },
                      onComplete: () => _completeSet(i),
                    );
                  }),

                  const SizedBox(height: 8),

                  // 세트 추가하기
                  GestureDetector(
                    onTap: _addSet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.golden.withOpacity(0.5),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '+ 세트 추가하기',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.golden,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 휴식 타이머
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 16, color: AppColors.golden),
                            SizedBox(width: 6),
                            Text('휴식 타이머',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _timerLabel(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _timerRunning
                                    ? AppColors.golden
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _TimerButton(
                              icon: Icons.refresh,
                              label: '리셋',
                              onTap: _resetTimer,
                            ),
                            const SizedBox(width: 12),
                            _TimerButton(
                              icon: _timerRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              label: _timerRunning ? '일시정지' : '시작',
                              primary: true,
                              onTap: _timerRunning ? _pauseTimer : _startTimer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final next =
                              _sets.indexWhere((s) => !s.done);
                          if (next == -1) {
                            // 이미 모든 세트 완료 → 다이얼로그로 안내
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.white,
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                  size: 48,
                                ),
                                title: const Text(
                                  '모든 세트 완료!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black),
                                ),
                                content: const Text(
                                  '모든 세트를 완료했습니다.\n아래 "운동 종료" 버튼을 눌러주세요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.gray),
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        elevation: 0,
                                      ),
                                      child: const Text('확인',
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            _completeSet(next);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _sets.every((s) => s.done)
                              ? AppColors.green
                              : AppColors.golden,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: Text(
                          _sets.every((s) => s.done) ? '완료됨 ✓' : '세트 완료',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.exerciseIndex >= 0) {
                            final notifier =
                                ref.read(workoutSessionProvider.notifier);
                            if (_sets.every((s) => s.done)) {
                              notifier.completeExercise(widget.exerciseIndex);
                            }
                            // 완료된 세트 기준 볼륨 저장 (항상)
                            final volume = _sets
                                .where((s) => s.done)
                                .fold(0.0, (sum, s) => sum + s.kg * s.reps);
                            if (volume > 0) {
                              notifier.setExerciseVolume(
                                  widget.exerciseIndex, volume);
                            }
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: const Text('운동 종료',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int index;
  final WorkoutSet set;
  final void Function(double kg, int reps) onChanged;
  final VoidCallback onComplete;

  const _SetRow({
    required this.index,
    required this.set,
    required this.onChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: set.done
            ? AppColors.green.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: set.done
            ? Border.all(color: AppColors.green.withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: set.done ? AppColors.green : AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: _EditableField(
              value: set.kg == 0 ? '' : set.kg.toString(),
              hint: '0',
              suffix: 'kg',
              done: set.done,
              onChanged: (v) {
                final val = double.tryParse(v) ?? 0;
                onChanged(val, set.reps);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _EditableField(
              value: set.reps == 0 ? '' : set.reps.toString(),
              hint: '0',
              suffix: '회',
              done: set.done,
              onChanged: (v) {
                final val = int.tryParse(v) ?? 0;
                onChanged(set.kg, val);
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onComplete,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: set.done ? AppColors.green : AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: set.done ? Colors.white : AppColors.gray,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String value;
  final String hint;
  final String suffix;
  final bool done;
  final void Function(String) onChanged;

  const _EditableField({
    required this.value,
    required this.hint,
    required this.suffix,
    required this.done,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 44,
          child: TextFormField(
            initialValue: value,
            enabled: !done,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: done ? AppColors.green : AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.gray, fontSize: 15),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          ),
        ),
        Text(suffix,
            style: const TextStyle(fontSize: 12, color: AppColors.gray)),
      ],
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: primary ? AppColors.golden : AppColors.cream,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: primary ? Colors.white : AppColors.black),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primary ? Colors.white : AppColors.black)),
          ],
        ),
      ),
    );
  }
}
