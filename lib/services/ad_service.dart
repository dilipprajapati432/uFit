import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoaded = false;
  static const int _maxFailedLoadAttempts = 3;
  static int _numRewardedLoadAttempts = 0;

  // Use test ad unit IDs for development
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isLoaded = true;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isLoaded = false;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < _maxFailedLoadAttempts) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  static void showRewardedAd({required VoidCallback onRewardEarned, VoidCallback? onAdClosed}) {
    if (_rewardedAd == null || !_isLoaded) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      // For fallback/failsafe (e.g. no internet or adblocker), grant the reward anyway
      // to not completely block the user from core functionality.
      onRewardEarned();
      loadRewardedAd();
      if (onAdClosed != null) {
        onAdClosed();
      }
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('ad showed.'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        loadRewardedAd();
        if (onAdClosed != null) {
          onAdClosed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        loadRewardedAd();
        // Fallback: grant reward if ad failed to show
        onRewardEarned();
        if (onAdClosed != null) {
          onAdClosed();
        }
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      onRewardEarned();
    });
  }

  // --- Token Management ---
  
  static const String _aiTokensKey = 'ai_chat_tokens';
  
  static Future<int> getAiTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_aiTokensKey) ?? 3; // Start with 3 free tokens
  }
  
  static Future<void> useAiToken() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_aiTokensKey) ?? 3;
    if (current > 0) {
      await prefs.setInt(_aiTokensKey, current - 1);
    }
  }
  
  static Future<void> addAiTokens(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_aiTokensKey) ?? 3;
    await prefs.setInt(_aiTokensKey, current + amount);
  }
}
