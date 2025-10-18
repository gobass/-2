import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dailymotion_player.dart';
import '../../services/ad_service.dart';
import '../../services/continuous_watching_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String movieTitle;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.movieTitle,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isLoading = true;
  bool _isYouTubeVideo = false;
  bool _isDailymotionVideo = false;
  final AdService _adService = AdService();
  final ContinuousWatchingService _continuousWatchingService = ContinuousWatchingService.instance;

  Timer? _progressTimer;
  Duration? _savedPosition;
  bool _showResumeDialog = false;

  @override
  void initState() {
    super.initState();
    // Check if it's a YouTube video
    _isYouTubeVideo = widget.videoUrl.contains('youtube.com') || widget.videoUrl.contains('youtu.be');

    // Check if it's a Dailymotion video
    _isDailymotionVideo = widget.videoUrl.contains('dailymotion.com') || widget.videoUrl.contains('dai.ly');

    // Initialize video player
    if (_isYouTubeVideo) {
      _initializeYouTubePlayer();
    } else if (_isDailymotionVideo) {
      // Dailymotion handled in build method
      _isLoading = false;
    } else {
      _initializePlayer();
    }
  }

  Future<String> _resolveShortUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url), headers: {'User-Agent': 'Mozilla/5.0'});
      if (response.isRedirect && response.headers.containsKey('location')) {
        return response.headers['location']!;
      }
      return url;
    } catch (e) {
      print('Error resolving short URL: $e');
      return url;
    }
  }

  Future<void> _initializePlayer() async {
    try {
      // Check if running on unsupported platforms
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        print('🎬 Desktop platform detected - showing fallback message');
        setState(() {
          _isLoading = false;
        });
        _showDesktopFallback();
        return;
      }

      // Validate URL
      if (widget.videoUrl.isEmpty || !Uri.tryParse(widget.videoUrl)!.isAbsolute) {
        throw Exception('رابط الفيديو غير صحيح أو فارغ');
      }

      // Resolve short URLs (e.g., dai.ly)
      String videoUrlToUse = widget.videoUrl;
      if (widget.videoUrl.contains('dai.ly')) {
        videoUrlToUse = await _resolveShortUrl(widget.videoUrl);
        print('Resolved short URL: $videoUrlToUse');
      }

      // Check if URL is a direct video file
      final uri = Uri.parse(videoUrlToUse);
      final path = uri.path.toLowerCase();
      final isVideoFile = path.endsWith('.mp4') || path.endsWith('.webm') || path.endsWith('.ogg') ||
                         path.endsWith('.avi') || path.endsWith('.mov') || path.endsWith('.mkv');

      if (!isVideoFile) {
        throw Exception('تنسيق الفيديو غير مدعوم. يرجى استخدام رابط فيديو مباشر');
      }

      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrlToUse));

      // Set timeout for initialization
      await _videoController!.initialize().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('انتهت مهلة تحميل الفيديو - تحقق من اتصال الإنترنت'),
      );

      // Check if video was initialized successfully
      if (!_videoController!.value.isInitialized) {
        throw Exception('فشل في تهيئة الفيديو');
      }

      // Set volume to maximum with multiple attempts
      await _ensureAudioEnabled();
      print('🔊 Video volume set successfully');

      // Debug audio information
      print('🔊 Video controller initialized: ${_videoController!.value.isInitialized}');
      print('🔊 Video duration: ${_videoController!.value.duration}');
      print('🔊 Video size: ${_videoController!.value.size}');
      print('🔊 Platform: ${Platform.operatingSystem}');

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        aspectRatio: _videoController!.value.aspectRatio,
        autoInitialize: true,
        allowedScreenSleep: false, // Keep screen on during video playback
        useRootNavigator: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'خطأ في تشغيل الفيديو',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _retryVideo(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
      );

      // Show interstitial ad when video starts (with 50% probability)
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      print('🎬 Video player - random number: $random, should show interstitial: ${_adService.shouldShowInterstitial()}');

      if (random < 5 && _adService.shouldShowInterstitial()) { // 50% chance
        print('🎬 Showing interstitial ad before video playback');
        _adService.showInterstitialAd(() {
          print('🎬 Interstitial ad dismissed, continuing video playback');
          _checkForSavedPosition();
          _startProgressTimer();
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        print('🎬 No interstitial ad shown, continuing video playback');
        _checkForSavedPosition();
        _startProgressTimer();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Video initialization error: $e');
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'حدث خطأ في تشغيل الفيديو';
      if (e.toString().contains('timeout')) {
        errorMessage = 'انتهت مهلة تحميل الفيديو - تحقق من اتصال الإنترنت';
      } else if (e.toString().contains('Invalid image data')) {
        errorMessage = 'تنسيق الفيديو غير مدعوم أو رابط الفيديو غير صحيح';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'خطأ في الشبكة - تحقق من اتصال الإنترنت';
      } else if (e.toString().contains('تنسيق الفيديو غير مدعوم')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'خطأ في تشغيل الفيديو',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    }
  }

  void _retryVideo() {
    setState(() {
      _isLoading = true;
      _chewieController?.dispose();
      _chewieController = null;
      _videoController?.dispose();
      _videoController = null;
      _youtubeController?.dispose();
      _youtubeController = null;
    });
    if (_isYouTubeVideo) {
      _initializeYouTubePlayer();
    } else {
      _initializePlayer();
    }
  }

  void _showDesktopFallback() {
    Get.snackbar(
      'تشغيل الفيديو غير مدعوم',
      'مشغل الفيديو لا يعمل على أجهزة سطح المكتب. يرجى استخدام الهاتف أو الجهاز اللوحي.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 10),
    );
  }

  Future<void> _ensureAudioEnabled() async {
    try {
      // Set volume to maximum with multiple attempts
      await _videoController!.setVolume(1.0);
      print('🔊 Volume set to 1.0 on first attempt');

      // Wait a bit and try again
      await Future.delayed(const Duration(milliseconds: 500));
      await _videoController!.setVolume(1.0);
      print('🔊 Volume set to 1.0 on second attempt');

      // Additional attempt for mobile platforms
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _videoController!.setVolume(1.0);
        print('🔊 Volume set to 1.0 on mobile platform');

        // Try to unmute if muted
        if (_videoController!.value.volume == 0) {
          await _videoController!.setVolume(1.0);
          print('🔊 Volume was muted, unmuted to 1.0');
        }
      }

      // Verify volume is set correctly
      final currentVolume = _videoController!.value.volume;
      print('🔊 Final volume check: $currentVolume');

      if (currentVolume < 0.5) {
        print('⚠️ Warning: Volume is still low: $currentVolume');
        // Try one more time
        await _videoController!.setVolume(1.0);
      }

    } catch (e) {
      print('🔊 Error setting volume: $e');
      // Try to set volume even if there's an error
      try {
        await _videoController!.setVolume(1.0);
      } catch (e2) {
        print('🔊 Failed to set volume after error: $e2');
      }
    }
  }

  Future<void> _initializeYouTubePlayer() async {
    try {
      // Extract YouTube video ID
      String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null) {
        throw Exception('رابط يوتيوب غير صحيح');
      }

      print('🎬 Initializing YouTube player for video ID: $videoId');
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: false,
          forceHD: false,
          enableCaption: true,
        ),
      );

      // Wait for controller to be ready
      await Future.delayed(const Duration(seconds: 1));
      print('🎬 YouTube player initialized, mute status: ${_youtubeController!.flags.mute}');

      // Show interstitial ad when YouTube video starts (with 50% probability)
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      if (random < 5 && _adService.shouldShowInterstitial()) { // 50% chance
        print('🎬 Showing interstitial ad before YouTube video playback');
        _adService.showInterstitialAd(() {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('YouTube initialization error: $e');
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'خطأ في تشغيل فيديو يوتيوب',
        'حدث خطأ في تحميل فيديو يوتيوب: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    }
  }

  @override
  void dispose() {
    _stopProgressTimer();
    _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  // Continuous watching functionality
  void _startProgressTimer() {
    if (_isYouTubeVideo || _isDailymotionVideo) return; // Only for regular video player

    _stopProgressTimer(); // Stop any existing timer

    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _saveCurrentProgress();
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _saveCurrentProgress() {
    if (_isYouTubeVideo || _isDailymotionVideo || _videoController == null) return;

    try {
      final position = _videoController!.value.position;
      final duration = _videoController!.value.duration;

      if (duration.inSeconds > 0) {
        _continuousWatchingService.saveWatchingProgress(
          widget.movieTitle, // Using title as movie ID for now
          position,
          duration,
        );
      }
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  void _checkForSavedPosition() {
    if (_isYouTubeVideo || _isDailymotionVideo) return; // Only for regular video player

    try {
      final duration = _videoController?.value.duration;
      if (duration != null && duration.inSeconds > 0) {
        _savedPosition = _continuousWatchingService.getSavedPosition(
          widget.movieTitle,
          duration,
        );

        if (_savedPosition != null && _savedPosition!.inSeconds > 30) {
          setState(() {
            _showResumeDialog = true;
          });
        }
      }
    } catch (e) {
      print('Error checking saved position: $e');
    }
  }

  void _resumeFromSavedPosition() {
    if (_savedPosition != null && _videoController != null) {
      _videoController!.seekTo(_savedPosition!);
    }
    setState(() {
      _showResumeDialog = false;
    });
  }

  void _startFromBeginning() {
    setState(() {
      _showResumeDialog = false;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle Dailymotion videos
    if (_isDailymotionVideo) {
      return DailymotionPlayer(
        videoUrl: widget.videoUrl,
        movieTitle: widget.movieTitle,
      );
    }

    Widget content;

    if (_isLoading) {
      // Show loading indicator
      content = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (_isYouTubeVideo && _youtubeController != null) {
      // YouTube player
      content = YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
        builder: (context, player) {
          return Center(
            child: player,
          );
        },
      );
    } else if (!_isYouTubeVideo && _chewieController != null) {
      // Chewie player
      content = Center(
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    } else {
      // Fallback error screen
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'خطأ في تحميل الفيديو',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'تحقق من صحة الرابط أو اتصال الإنترنت',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _retryVideo(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Wrap content in Container with Stack for back button overlay
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          content,
          // Resume dialog overlay
          if (_showResumeDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_filled,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'استئناف المشاهدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هل تريد الاستمرار من حيث توقفت؟\n${_formatDuration(_savedPosition!)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _resumeFromSavedPosition,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('استئناف'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _startFromBeginning,
                              icon: const Icon(Icons.replay),
                              label: const Text('من البداية'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
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
