import 'package:flutter/material.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text('루틴', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: '내 루틴'),
            Tab(text: '추천 루틴'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyRoutinesTab(),
          _RecommendedRoutinesTab(),
        ],
      ),
    );
  }
}

class _MyRoutinesTab extends StatelessWidget {
  final List<Map<String, dynamic>> _routines = const [
    {
      'name': '상체 집중 루틴',
      'exercises': 6,
      'duration': '45분',
      'days': '월·수·금',
      'color': Color(0xFF9C27B0),
      'icon': Icons.fitness_center,
    },
    {
      'name': '하체 강화 루틴',
      'exercises': 5,
      'duration': '40분',
      'days': '화·목',
      'color': Color(0xFF2196F3),
      'icon': Icons.directions_run,
    },
    {
      'name': '전신 유산소',
      'exercises': 4,
      'duration': '30분',
      'days': '토',
      'color': Color(0xFFFF9800),
      'icon': Icons.favorite_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (routine['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                routine['icon'] as IconData,
                color: routine['color'] as Color,
                size: 24,
              ),
            ),
            title: Text(
              routine['name'] as String,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.list, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${routine['exercises']}가지',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.schedule, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    routine['duration'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    routine['days'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF1E3A5F),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _RecommendedRoutinesTab extends StatelessWidget {
  final List<Map<String, dynamic>> _routines = const [
    {
      'name': '초보자 전신 루틴',
      'level': '초급',
      'exercises': 8,
      'duration': '60분',
      'likes': 124,
      'color': Color(0xFF4CAF50),
    },
    {
      'name': '중급 상체 분할',
      'level': '중급',
      'exercises': 10,
      'duration': '75분',
      'likes': 89,
      'color': Color(0xFF2196F3),
    },
    {
      'name': '코어 강화 루틴',
      'level': '초급',
      'exercises': 6,
      'duration': '30분',
      'likes': 210,
      'color': Color(0xFFFF9800),
    },
    {
      'name': '고강도 인터벌',
      'level': '고급',
      'exercises': 12,
      'duration': '90분',
      'likes': 67,
      'color': Color(0xFFE91E63),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        final color = routine['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          routine['name'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            routine['level'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${routine['exercises']}가지 · ${routine['duration']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.favorite_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(height: 2),
                  Text(
                    '${routine['likes']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
