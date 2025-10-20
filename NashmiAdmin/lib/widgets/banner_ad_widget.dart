import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nashmi_admin_v2/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdMobService _adMobService = AdMobService();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdMobSupported = true;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    // AdMob is not supported on web platform
    if (kIsWeb) {
      setState(() {
        _isAdMobSupported = false;
      });
      return;
    }

    try {
      await _adMobService.initialize();
      _bannerAd = await _adMobService.createBannerAd();

      setState(() {
        _isAdLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isAdMobSupported = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isAdMobSupported) {
      _adMobService.disposeBannerAd();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdMobSupported) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'الإعلانات غير متاحة على هذا المنصة',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text('تحميل الإعلان...', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      height: 50,
      color: Colors.grey[200],
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
