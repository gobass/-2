import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Initialize AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Create banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded = false;
        },
      ),
    );
  }

  // Load banner ad
  Future<void> loadBannerAd() async {
    if (_bannerAd == null) {
      _bannerAd = createBannerAd();
    }
    await _bannerAd!.load();
  }

  // Get banner ad widget
  AdWidget? getBannerAdWidget() {
    if (_bannerAd != null && _isBannerAdLoaded) {
      return AdWidget(ad: _bannerAd!);
    }
    return null;
  }

  // Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // Create interstitial ad
  InterstitialAd? createInterstitialAd() {
    InterstitialAd? interstitialAd;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          interstitialAd = null;
        },
      ),
    );
    return interstitialAd;
  }

  // Show interstitial ad
  void showInterstitialAd() {
    final interstitialAd = createInterstitialAd();
    if (interstitialAd != null) {
      interstitialAd.show();
    }
  }
}
