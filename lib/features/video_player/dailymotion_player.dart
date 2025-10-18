import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

class DailymotionPlayer extends StatefulWidget {
  final String videoUrl;
  final String movieTitle;

  const DailymotionPlayer({
    Key? key,
    required this.videoUrl,
    required this.movieTitle,
  }) : super(key: key);

  @override
  State<DailymotionPlayer> createState() => _DailymotionPlayerState();
}

class _DailymotionPlayerState extends State<DailymotionPlayer> {
  InAppWebViewController? _controller;

  @override
  void initState() {
    super.initState();
  }

  String _getEmbedUrl(String url) {
    // Convert dai.ly short URL or dailymotion URL to embed URL
    // Examples:
    // https://dai.ly/x96m1nw -> https://www.dailymotion.com/embed/video/x96m1nw
    // https://www.dailymotion.com/video/x96m1nw -> https://www.dailymotion.com/embed/video/x96m1nw

    Uri uri = Uri.parse(url);
    String videoId = '';

    if (uri.host.contains('dai.ly')) {
      videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    } else if (uri.host.contains('dailymotion.com')) {
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'video') {
        videoId = uri.pathSegments[1];
      }
    }

    if (videoId.isEmpty) {
      // fallback to original url if parsing fails
      return url;
    }

    // Add parameters to ensure audio is enabled and autoplay works
    return 'https://www.dailymotion.com/embed/video/$videoId?autoplay=1&mute=0&controls=1&ui-logo=0&ui-start-screen-info=0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // WebView takes full screen
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_getEmbedUrl(widget.videoUrl))),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStop: (controller, url) async {
              // Inject JavaScript to unmute the video after loading
              await controller.evaluateJavascript(source: '''
                (function() {
                  // Try to unmute the video
                  var video = document.querySelector('video');
                  if (video) {
                    video.muted = false;
                    video.volume = 1.0;
                  }

                  // Try to click unmute button if it exists
                  setTimeout(function() {
                    var unmuteButton = document.querySelector('[data-testid="unmute-button"]') ||
                                     document.querySelector('.unmute-button') ||
                                     document.querySelector('[aria-label*="Unmute"]') ||
                                     document.querySelector('[title*="Unmute"]');
                    if (unmuteButton) {
                      unmuteButton.click();
                    }
                  }, 2000);
                })();
              ''');
            },
          ),
          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'العودة',
            ),
          ),
          // Title overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 56,
            right: 56,
            child: Text(
              widget.movieTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
