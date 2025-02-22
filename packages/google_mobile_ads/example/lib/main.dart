

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
import 'package:collection/collection.dart';

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
    // _banners = [
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
      // _createBannerAd(),
    // ];
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

  AdWidget _getBannerWidget() {
    BannerAd? bannerAd = _banners.firstWhereOrNull((banner) => banner.isReadyForReuse());
    if (bannerAd != null) {
      print('found a reusable banner ad');
    } else {
      print('create a new banner ad');
      bannerAd = _createBannerAd();
      // Delaying is required by Android
      Future.delayed(const Duration(milliseconds: 1), () {
        bannerAd!.load();
      });
      _banners.add(bannerAd!);
    }
    return AdWidget(ad: bannerAd!);

    // print('trying to reuse banner for index: $index');
    // BannerAd bannerAd = _banners[index % _banners.length];
    // print('got banner from list with banner id: ${bannerAd.adId()}');
    // if (bannerAd.isReadyForReuse()) {
    //   print('ad not mounted, safe to reuse');
    // } else {
    //   bannerAd = _createBannerAd();
    //   print('ad banner already mounted, create a new ad banner with banner id: ${bannerAd.adId()}');
    // }
    // bannerAd.load();
    // return AdWidget(ad: bannerAd);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      title: 'Advanced Layout',
      home: Scaffold(
        appBar: AppBar(title: const Text('Platform View Ad Banners')),
        body: 
          ListView.builder(
            key: const Key('platform-views-scroll'), // This key is used by the driver test.
            itemCount: 250,
            itemBuilder: (BuildContext context, int index) {
              return index.isEven
              // Use 320x50 Admob standard banner size.
                  ? const SizedBox(height: 150, child: ColoredBox(color: Colors.red))
                  : SizedBox(width: 320, height: 50, child: _getBannerWidget());
              // Adjust the height to control number of platform views on screen.
              // TODO(hellohuanlin): Having more than 5 banners on screen causes an unknown crash.
              // See: https://github.com/flutter/flutter/issues/144339
                  // : const SizedBox(height: 150, child: ColoredBox(color: Colors.yellow));
            },
          ),



      ),
  
    );
  }
}




