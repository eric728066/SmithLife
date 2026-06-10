import 'package:flutter/material.dart';

class ExerciseData {
  final String name;
  final String muscle;
  final int defaultSets;

  const ExerciseData({
    required this.name,
    required this.muscle,
    required this.defaultSets,
  });
}

class RoutineData {
  final String name;
  final String goal;
  final String difficulty;
  final String duration;
  final String frequency;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final List<ExerciseData> exercises;

  const RoutineData({
    required this.name,
    required this.goal,
    required this.difficulty,
    required this.duration,
    required this.frequency,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.exercises,
  });
}

// ─── 실제 보디빌딩 루틴 (PPL + 스트렝스 기반) ───
const List<RoutineData> kRoutines = [

  // 1. 가슴 & 삼두 (Push Day — PPL)
  RoutineData(
    name: '가슴 & 삼두',
    goal: '근성장',
    difficulty: '중급',
    duration: '60분',
    frequency: '주 2회',
    icon: Icons.fitness_center,
    iconColor: Color(0xFFFF6B35),
    iconBg: Color(0xFFFFEDE5),
    exercises: [
      ExerciseData(name: '바벨 벤치 프레스', muscle: '가슴', defaultSets: 4),
      ExerciseData(name: '인클라인 덤벨 프레스', muscle: '가슴 상부', defaultSets: 4),
      ExerciseData(name: '딥스', muscle: '가슴/삼두', defaultSets: 3),
      ExerciseData(name: '케이블 크로스오버', muscle: '가슴 내측', defaultSets: 3),
      ExerciseData(name: '케이블 푸쉬다운', muscle: '삼두', defaultSets: 4),
      ExerciseData(name: '오버헤드 트라이셉스 익스텐션', muscle: '삼두 장두', defaultSets: 3),
    ],
  ),

  // 2. 등 & 이두 (Pull Day — PPL)
  RoutineData(
    name: '등 & 이두',
    goal: '근성장',
    difficulty: '중급',
    duration: '65분',
    frequency: '주 2회',
    icon: Icons.accessibility_new,
    iconColor: Color(0xFF2196F3),
    iconBg: Color(0xFFE3F2FD),
    exercises: [
      ExerciseData(name: '바벨 로우', muscle: '등 중부', defaultSets: 4),
      ExerciseData(name: '풀업', muscle: '광배근', defaultSets: 4),
      ExerciseData(name: '랫 풀다운', muscle: '광배근', defaultSets: 4),
      ExerciseData(name: '시티드 케이블 로우', muscle: '등 하부', defaultSets: 3),
      ExerciseData(name: '바벨 컬', muscle: '이두', defaultSets: 4),
      ExerciseData(name: '해머 컬', muscle: '이두/완요골근', defaultSets: 3),
    ],
  ),

  // 3. 하체 (Leg Day — PPL)
  RoutineData(
    name: '하체 데이',
    goal: '근성장',
    difficulty: '고급',
    duration: '70분',
    frequency: '주 2회',
    icon: Icons.directions_run,
    iconColor: Color(0xFFE91E8C),
    iconBg: Color(0xFFFFE5F3),
    exercises: [
      ExerciseData(name: '바벨 스쿼트', muscle: '대퇴사두/둔근', defaultSets: 5),
      ExerciseData(name: '레그 프레스', muscle: '대퇴사두', defaultSets: 4),
      ExerciseData(name: '루마니안 데드리프트', muscle: '햄스트링/둔근', defaultSets: 4),
      ExerciseData(name: '레그 컬', muscle: '햄스트링', defaultSets: 4),
      ExerciseData(name: '레그 익스텐션', muscle: '대퇴사두', defaultSets: 3),
      ExerciseData(name: '카프 레이즈', muscle: '종아리', defaultSets: 5),
    ],
  ),

  // 4. 어깨 & 코어 (Shoulder + Core)
  RoutineData(
    name: '어깨 & 코어',
    goal: '근성장',
    difficulty: '중급',
    duration: '55분',
    frequency: '주 2회',
    icon: Icons.self_improvement,
    iconColor: Color(0xFF7B61FF),
    iconBg: Color(0xFFEDE9FF),
    exercises: [
      ExerciseData(name: '바벨 오버헤드 프레스', muscle: '전면 삼각근', defaultSets: 4),
      ExerciseData(name: '덤벨 숄더 프레스', muscle: '삼각근 전체', defaultSets: 4),
      ExerciseData(name: '사이드 레터럴 레이즈', muscle: '측면 삼각근', defaultSets: 4),
      ExerciseData(name: '리어 델트 플라이', muscle: '후면 삼각근', defaultSets: 4),
      ExerciseData(name: '페이스 풀', muscle: '후면 삼각근/회전근개', defaultSets: 3),
      ExerciseData(name: '플랭크', muscle: '코어', defaultSets: 3),
    ],
  ),

  // 5. 전신 스트렝스 (Full Body — 초보자/3분할)
  RoutineData(
    name: '전신 스트렝스',
    goal: '체력 증진',
    difficulty: '입문',
    duration: '60분',
    frequency: '주 3회',
    icon: Icons.flash_on,
    iconColor: Color(0xFF34C759),
    iconBg: Color(0xFFE8F8EC),
    exercises: [
      ExerciseData(name: '바벨 스쿼트', muscle: '하체/전신', defaultSets: 4),
      ExerciseData(name: '바벨 벤치 프레스', muscle: '가슴', defaultSets: 4),
      ExerciseData(name: '바벨 로우', muscle: '등', defaultSets: 4),
      ExerciseData(name: '오버헤드 프레스', muscle: '어깨', defaultSets: 3),
      ExerciseData(name: '풀업', muscle: '등/이두', defaultSets: 3),
      ExerciseData(name: '루마니안 데드리프트', muscle: '햄스트링', defaultSets: 3),
    ],
  ),

  // 6. 파워리프팅 3대 (Powerlifting Big 3)
  RoutineData(
    name: '파워리프팅 3대',
    goal: '근력 향상',
    difficulty: '고급',
    duration: '75분',
    frequency: '주 3회',
    icon: Icons.sports_gymnastics,
    iconColor: Color(0xFFFF9500),
    iconBg: Color(0xFFFFF3E0),
    exercises: [
      ExerciseData(name: '바벨 스쿼트', muscle: '하체/전신', defaultSets: 5),
      ExerciseData(name: '바벨 벤치 프레스', muscle: '가슴/삼두/전면어깨', defaultSets: 5),
      ExerciseData(name: '데드리프트', muscle: '전신/척추기립근', defaultSets: 3),
      ExerciseData(name: '오버헤드 프레스', muscle: '어깨', defaultSets: 4),
      ExerciseData(name: '바벨 로우', muscle: '등', defaultSets: 4),
    ],
  ),
];
