import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/announcement/announcement.dart';
import '../../../data/repositories/announcement_repository.dart';

class AdminAnnouncementFormPage extends StatefulWidget {
  final Announcement? announcement; // null이면 신규, 아니면 수정

  const AdminAnnouncementFormPage({super.key, this.announcement});

  @override
  State<AdminAnnouncementFormPage> createState() =>
      _AdminAnnouncementFormPageState();
}

class _AdminAnnouncementFormPageState
    extends State<AdminAnnouncementFormPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTag = 'NOTICE';
  bool _isLoading = false;

  bool get isEdit => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleController.text = widget.announcement!.title;
      _contentController.text = widget.announcement!.content;
      _selectedTag = widget.announcement!.tag;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (isEdit) {
        await AnnouncementRepository().updateAnnouncement(
          id: widget.announcement!.announcementId,
          title: title,
          content: content,
          tag: _selectedTag,
        );
      } else {
        await AnnouncementRepository().createAnnouncement(
          title: title,
          content: content,
          tag: _selectedTag,
        );
      }
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          isEdit ? '공지사항 수정' : '공지사항 작성',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.golden),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: AppColors.golden,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 태그 선택
            const Text('태그',
                style: TextStyle(fontSize: 13, color: AppColors.gray)),
            const SizedBox(height: 8),
            Row(
              children: [
                _TagChip(
                  label: '안내',
                  value: 'NOTICE',
                  selected: _selectedTag == 'NOTICE',
                  onTap: () => setState(() => _selectedTag = 'NOTICE'),
                ),
                const SizedBox(width: 8),
                _TagChip(
                  label: '이벤트',
                  value: 'EVENT',
                  selected: _selectedTag == 'EVENT',
                  onTap: () => setState(() => _selectedTag = 'EVENT'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 제목
            const Text('제목',
                style: TextStyle(fontSize: 13, color: AppColors.gray)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '공지사항 제목을 입력하세요',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
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
            const SizedBox(height: 20),

            // 내용
            const Text('내용',
                style: TextStyle(fontSize: 13, color: AppColors.gray)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '공지사항 내용을 입력하세요',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEdit ? '수정 완료' : '작성 완료',
                  style: const TextStyle(
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

class _TagChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.orangeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.gray,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
