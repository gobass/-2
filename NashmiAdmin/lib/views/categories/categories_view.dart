import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/models/category_model.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final AuthService authService = Get.find<AuthService>();
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final ScrollController _scrollController = ScrollController();

  List<CategoryModel> categories = [];
  bool isLoading = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      setState(() => isLoading = true);
      final loadedCategories = await supabaseService.getCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        'Error loading categories: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addNewCategory(String categoryName) async {
    if (categoryName.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Category name is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await supabaseService.addCategory(categoryName.trim());
      await loadCategories(); // Refresh the list

      Get.snackbar(
        'نجح',
        'تم إضافة الفئة بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ في إضافة الفئة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            hintText: 'أدخل اسم الفئة الجديدة',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            Get.back();
            addNewCategory(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              addNewCategory(categoryController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryTypeColor(CategoryType type) {
    switch (type) {
      case CategoryType.regular:
        return Colors.blue;
      case CategoryType.year:
        return Colors.green;
      case CategoryType.seasonal:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryTypeText(CategoryType type) {
    switch (type) {
      case CategoryType.regular:
        return 'عادية';
      case CategoryType.year:
        return 'سنة';
      case CategoryType.seasonal:
        return 'موسمية';
      default:
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCategories,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الفئات',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة فئة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : categories.isEmpty
                  ? const Center(child: Text('لا توجد فئات متاحة'))
                  : RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 8,
                      radius: const Radius.circular(8),
                      trackVisibility: true,
                      interactive: true,
                      scrollbarOrientation: ScrollbarOrientation.right,
                      child: GridView.builder(
                        controller: _scrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                // Handle category tap
                                Get.snackbar(
                                  'تم النقر',
                                  'تم النقر على فئة: ${category.displayName}',
                                  backgroundColor: Colors.teal,
                                  colorText: Colors.white,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      category.displayName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getCategoryTypeColor(category.type),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getCategoryTypeText(category.type),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (category.year != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'سنة: ${category.year}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                    if (category.season != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'موسم: ${category.season}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCategoryDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'إضافة فئة جديدة',
      ),
    );
  }
}
