import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/views/series/add_episode_screen.dart';
import 'package:nashmi_admin_v2/views/series/edit_episode_screen.dart';

class EpisodesManagement extends StatefulWidget {
  final String seriesId;
  final String seriesTitle;

  const EpisodesManagement({
    super.key,
    required this.seriesId,
    required this.seriesTitle,
  });

  @override
  State<EpisodesManagement> createState() => _EpisodesManagementState();
}

class _EpisodesManagementState extends State<EpisodesManagement> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> episodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    try {
      setState(() => isLoading = true);

      // Note: This assumes you have an 'episodes' table in Supabase
      // You may need to create this table first
      final response = await supabaseService.getEpisodes(widget.seriesId);

      setState(() {
        episodes = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الحلقات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة حلقات ${widget.seriesTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Get.to(
                () => AddEpisodeScreen(
                  seriesId: widget.seriesId,
                  seriesTitle: widget.seriesTitle,
                ),
              );
              if (result == true) {
                _loadEpisodes();
              }
            },
            tooltip: 'إضافة حلقة جديدة',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : episodes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tv_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد حلقات',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Get.to(
                        () => AddEpisodeScreen(
                          seriesId: widget.seriesId,
                          seriesTitle: widget.seriesTitle,
                        ),
                      );
                      if (result == true) {
                        _loadEpisodes();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة أول حلقة'),
                  ),
                ],
              ),
            )
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(8),
              trackVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.right,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${episode['episode_number']}'),
                      ),
                      title: Text(episode['title'] ?? 'بدون عنوان'),
                      subtitle: Text(
                        episode['description'] ?? 'بدون وصف',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Get.to(
                                () => EditEpisodeScreen(
                                  episode: episode,
                                  seriesTitle: widget.seriesTitle,
                                ),
                              );
                              if (result == true) {
                                _loadEpisodes();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: const Text(
                                    'هل أنت متأكد من حذف هذه الحلقة؟',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: const Text('إلغاء'),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text('حذف'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await supabaseService.deleteEpisode(
                                    episode['id'],
                                  );

                                  _loadEpisodes();

                                  Get.snackbar(
                                    'نجاح',
                                    'تم حذف الحلقة بنجاح',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'خطأ',
                                    'فشل في حذف الحلقة: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
