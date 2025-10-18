import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/loading_service.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? progress;
  final bool showProgressBar;
  final Color? color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.progress,
    this.showProgressBar = false,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.teal,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showProgressBar && progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.teal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Section loading widget for specific parts of the UI
class SectionLoadingWidget extends StatelessWidget {
  final String section;
  final bool showProgressBar;
  final Color? color;
  final double size;

  const SectionLoadingWidget({
    super.key,
    required this.section,
    this.showProgressBar = false,
    this.color,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final loadingService = Get.find<LoadingService>();

    return Obx(() {
      if (!loadingService.isSectionLoading(section)) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (color ?? Colors.teal).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: loadingService.getSectionProgress(section),
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loadingService.getSectionMessage(section),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (showProgressBar) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: loadingService.getSectionProgress(section),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Colors.teal,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// Loading overlay for the entire screen
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showOverlay)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingWidget(
                message: 'جاري التحميل...',
                size: 32,
              ),
            ),
          ),
      ],
    );
  }
}

// Loading button widget
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final IconData? icon;
  final double? width;
  final double height;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
      ),
    );
  }
}

// Loading card widget
class LoadingCard extends StatelessWidget {
  final String title;
  final bool isLoading;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const LoadingCard({
    super.key,
    required this.title,
    this.isLoading = false,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            isLoading
              ? const Center(
                  child: LoadingWidget(
                    message: 'جاري تحميل البيانات...',
                  ),
                )
              : child,
          ],
        ),
      ),
    );
  }
}

// Loading list item widget
class LoadingListItem extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double height;

  const LoadingListItem({
    super.key,
    this.isLoading = false,
    required this.child,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.teal.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
