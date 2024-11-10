// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: public_member_api_docs

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

import 'anchored_adaptive_example.dart';
import 'fluid_example.dart';
import 'inline_adaptive_example.dart';
import 'native_template_example.dart';
import 'reusable_inline_example.dart';
import 'webview_example.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String testDevice = 'YOUR_DEVICE_ID';
const int maxFailedLoadAttempts = 3;

class MyApp extends StatefulWidget {
  // @override
  // _MyAppState createState() => _MyAppState();

  @override
  PlatformViewAppState createState() => PlatformViewAppState();
}

class PlatformViewAppState extends State<MyApp> {

  List<BannerAd> _banners = [];

  @override
  void initState() {
    super.initState();
    _banners = [
      _createBannerAd(),
      _createBannerAd(),
      _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
    ];
  }

    BannerAd _createBannerAd() {
    // Test IDs from Admob:
    // https://developers.google.com/admob/ios/test-ads
    // https://developers.google.com/admob/android/test-ads
    final String bannerId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
    final BannerAd bannerAd = BannerAd(
      adUnitId: bannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    );
    return bannerAd;
  }

  AdWidget _getBannerWidget(int index) {
    print('trying to reuse banner for index: $index');
    BannerAd bannerAd = _banners[index % _banners.length];
    print('got banner from list with banner id: ${bannerAd.adId()}');
    if (bannerAd.isAdMounted()) {
      bannerAd = _createBannerAd();
      print('ad banner already mounted, create a new ad banner with banner id: ${bannerAd.adId()}');
    } else {
      print('ad not mounted, safe to reuse');
    }
    bannerAd.load();
    return AdWidget(ad: bannerAd);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      title: 'Advanced Layout',
      home: Scaffold(
        appBar: AppBar(title: const Text('Platform View Ad Banners')),
        body: ListView.builder(
          key: const Key('platform-views-scroll'), // This key is used by the driver test.
          itemCount: 250,
          itemBuilder: (BuildContext context, int index) {
            return index.isEven
            // Use 320x50 Admob standard banner size.
                ? SizedBox(width: 320, height: 50, child: _getBannerWidget(index~/2))
            // Adjust the height to control number of platform views on screen.
            // TODO(hellohuanlin): Having more than 5 banners on screen causes an unknown crash.
            // See: https://github.com/flutter/flutter/issues/144339
                : const SizedBox(height: 150, child: ColoredBox(color: Colors.yellow));
          },
        ),
      ),
    );
  }
}


class _MyAppState extends State<MyApp> {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  static const interstitialButtonText = 'InterstitialAd';
  static const rewardedButtonText = 'RewardedAd';
  static const rewardedInterstitialButtonText = 'RewardedInterstitialAd';
  static const fluidButtonText = 'Fluid';
  static const inlineAdaptiveButtonText = 'Inline adaptive';
  static const anchoredAdaptiveButtonText = 'Anchored adaptive';
  static const nativeTemplateButtonText = 'Native template';
  static const webviewExampleButtonText = 'Register WebView';
  static const adInspectorButtonText = 'Ad Inspector';

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDevice]));
    _createInterstitialAd();
    _createRewardedAd();
    _createRewardedInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5224354917'
            : 'ca-app-pub-3940256099942544/1712485313',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5354046379'
            : 'ca-app-pub-3940256099942544/6978759866',
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AdMob Plugin example app'),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String result) {
                  switch (result) {
                    case interstitialButtonText:
                      _showInterstitialAd();
                      break;
                    case rewardedButtonText:
                      _showRewardedAd();
                      break;
                    case rewardedInterstitialButtonText:
                      _showRewardedInterstitialAd();
                      break;
                    case fluidButtonText:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FluidExample()),
                      );
                      break;
                    case inlineAdaptiveButtonText:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InlineAdaptiveExample()),
                      );
                      break;
                    case anchoredAdaptiveButtonText:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnchoredAdaptiveExample()),
                      );
                      break;
                    case nativeTemplateButtonText:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NativeTemplateExample()),
                      );
                      break;
                    case webviewExampleButtonText:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebViewExample()),
                      );
                      break;
                    case adInspectorButtonText:
                      MobileAds.instance.openAdInspector((error) => log(
                          'Ad Inspector ' +
                              (error == null
                                  ? 'opened.'
                                  : 'error: ' + (error.message ?? ''))));
                      break;
                    default:
                      throw AssertionError('unexpected button: $result');
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: interstitialButtonText,
                    child: Text(interstitialButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: rewardedButtonText,
                    child: Text(rewardedButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: rewardedInterstitialButtonText,
                    child: Text(rewardedInterstitialButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: fluidButtonText,
                    child: Text(fluidButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: inlineAdaptiveButtonText,
                    child: Text(inlineAdaptiveButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: anchoredAdaptiveButtonText,
                    child: Text(anchoredAdaptiveButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: nativeTemplateButtonText,
                    child: Text(nativeTemplateButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: webviewExampleButtonText,
                    child: Text(webviewExampleButtonText),
                  ),
                  PopupMenuItem<String>(
                    value: adInspectorButtonText,
                    child: Text(adInspectorButtonText),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(child: ReusableInlineExample()),
        );
      }),
    );
  }
}
