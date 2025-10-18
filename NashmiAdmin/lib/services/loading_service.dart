import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingService extends GetxService {
  static LoadingService get to => Get.find<LoadingService>();

  final RxBool isLoading = false.obs;
  final RxString loadingMessage = 'جاري التحميل...'.obs;
  final RxDouble loadingProgress = 0.0.obs;

  final RxMap<String, bool> _sectionLoading = <String, bool>{}.obs;
  final RxMap<String, String> _loadingMessages = <String, String>{}.obs;
  final RxMap<String, double> _loadingProgress = <String, double>{}.obs;

  // Global loading overlay
  OverlayEntry? _overlayEntry;

  @override
  void onInit() {
    super.onInit();
  }

  // Global loading methods
  void showLoading({String? message, double? progress}) {
    isLoading.value = true;
    loadingMessage.value = message ?? 'جاري التحميل...';
    loadingProgress.value = progress ?? 0.0;
    _showLoadingOverlay();
  }

  void hideLoading() {
    isLoading.value = false;
    loadingMessage.value = 'جاري التحميل...';
    loadingProgress.value = 0.0;
    _hideLoadingOverlay();
  }

  void updateLoadingProgress(double progress, {String? message}) {
    loadingProgress.value = progress;
    if (message != null) {
      loadingMessage.value = message;
    }
  }

  // Section-specific loading methods
  void showSectionLoading(String section, {String? message}) {
    _sectionLoading[section] = true;
    _loadingMessages[section] = message ?? 'جاري التحميل...';
    _loadingProgress[section] = 0.0;
  }

  void hideSectionLoading(String section) {
    _sectionLoading.remove(section);
    _loadingMessages.remove(section);
    _loadingProgress.remove(section);
  }

  void updateSectionProgress(String section, double progress, {String? message}) {
    _loadingProgress[section] = progress;
    if (message != null) {
      _loadingMessages[section] = message;
    }
  }

  bool isSectionLoading(String section) => _sectionLoading[section] ?? false;
  String getSectionMessage(String section) => _loadingMessages[section] ?? 'جاري التحميل...';
  double getSectionProgress(String section) => _loadingProgress[section] ?? 0.0;

  // Error handling methods
  void showError(String message, {String? title, VoidCallback? onRetry}) {
    hideLoading();
    Get.snackbar(
      title ?? 'خطأ',
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 5),
      mainButton: onRetry != null
        ? TextButton(
            onPressed: () {
              Get.back();
              onRetry();
            },
            child: const Text('إعادة المحاولة'),
          )
        : null,
    );
  }

  void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'نجح',
      message,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 3),
    );
  }

  void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? 'تحذير',
      message,
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[900],
      icon: const Icon(Icons.warning, color: Colors.orange),
      duration: const Duration(seconds: 4),
    );
  }

  void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? 'معلومة',
      message,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      icon: const Icon(Icons.info, color: Colors.blue),
      duration: const Duration(seconds: 3),
    );
  }

  // Loading overlay methods
  void _showLoadingOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                    loadingMessage.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                  const SizedBox(height: 8),
                  Obx(() => loadingProgress.value > 0
                    ? LinearProgressIndicator(
                        value: loadingProgress.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      )
                    : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Add to overlay
    if (Get.context != null) {
      Overlay.of(Get.context!).insert(_overlayEntry!);
    }
  }

  void _hideLoadingOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Async operation wrapper
  Future<T> withLoading<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    bool showProgress = false,
  }) async {
    try {
      showLoading(message: loadingMessage);
      final result = await operation();
      hideLoading();
      return result;
    } catch (e) {
      hideLoading();
      showError(e.toString());
      rethrow;
    }
  }

  // Section-specific async operation wrapper
  Future<T> withSectionLoading<T>(
    String section,
    Future<T> Function() operation, {
    String? loadingMessage,
    bool showProgress = false,
  }) async {
    try {
      showSectionLoading(section, message: loadingMessage);
      final result = await operation();
      hideSectionLoading(section);
      return result;
    } catch (e) {
      hideSectionLoading(section);
      showError(e.toString());
      rethrow;
    }
  }
}

// Extension for easy access
extension LoadingServiceExtension on GetInterface {
  LoadingService get loading => LoadingService.to;
}
