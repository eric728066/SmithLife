import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/workout/workout_models.dart';

class UserRoutineNotifier extends StateNotifier<List<RoutineData>> {
  static const _key = 'user_routines_v1';

  UserRoutineNotifier() : super([]) {
    _load();
  }

  // ─── 로컬 스토리지 로드 ───
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // 파싱 실패 시 무시 (빈 상태 유지)
    }
  }

  // ─── 로컬 스토리지 저장 ───
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.map(_toJson).toList()));
  }

  // ─── CRUD ───
  void add(RoutineData routine) {
    state = [...state, routine];
    _save();
  }

  void remove(int index) {
    final list = [...state];
    list.removeAt(index);
    state = list;
    _save();
  }

  void removeByName(String name) {
    state = state.where((r) => r.name != name).toList();
    _save();
  }

  // ─── 직렬화 ───
  Map<String, dynamic> _toJson(RoutineData r) => {
        'name': r.name,
        'goal': r.goal,
        'difficulty': r.difficulty,
        'duration': r.duration,
        'frequency': r.frequency,
        'exercises': r.exercises
            .map((e) => {
                  'name': e.name,
                  'muscle': e.muscle,
                  'defaultSets': e.defaultSets,
                })
            .toList(),
      };

  RoutineData _fromJson(Map<String, dynamic> json) {
    final goal = json['goal'] as String? ?? '근성장';
    return RoutineData(
      name: json['name'] as String,
      goal: goal,
      difficulty: json['difficulty'] as String? ?? '중급',
      duration: json['duration'] as String? ?? '30분',
      frequency: json['frequency'] as String? ?? '주 3회',
      icon: _iconForGoal(goal),
      iconColor: _iconColorForGoal(goal),
      iconBg: _iconBgForGoal(goal),
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseData(
                name: e['name'] as String,
                muscle: e['muscle'] as String,
                defaultSets: e['defaultSets'] as int? ?? 3,
              ))
          .toList(),
    );
  }

  // ─── 목표 → 아이콘/색상 매핑 ───
  IconData _iconForGoal(String goal) {
    switch (goal) {
      case '근성장':
        return Icons.fitness_center;
      case '다이어트':
        return Icons.directions_run;
      default:
        return Icons.flash_on;
    }
  }

  Color _iconColorForGoal(String goal) {
    switch (goal) {
      case '근성장':
        return const Color(0xFFFF6B35);
      case '다이어트':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF34C759);
    }
  }

  Color _iconBgForGoal(String goal) {
    switch (goal) {
      case '근성장':
        return const Color(0xFFFFEDE5);
      case '다이어트':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE8F8EC);
    }
  }
}

final userRoutineProvider =
    StateNotifierProvider<UserRoutineNotifier, List<RoutineData>>(
  (ref) => UserRoutineNotifier(),
);
