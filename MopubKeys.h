//
//  MopubKeys.h
//  AppReviewMonitor
//
//  Created by bruno heitz on 07/10/2014.
//  Copyright (c) 2014 Heitz Bruno. All rights reserved.
//

#define ExtraSpace 0.0f           // some more space between ad and other view
#define AppearAnimationTime 0.0f  // seconds
#define AdsEnabled YES            // YES or NO

#define AutoShowInterstitial YES                        // Show an interstitial when app become active AND after the time below
#define AutoInterstitialTimeBetweenEachInMinutes 60     // Time between each interstitial
#define AutoInterstitialDelayAfterAppBecomeActive 5.0   // Give some time to the app until the first controller display

#define AdmobRefreshInterval 60   // (in seconds) You must set refresh to NO on Admob website and use this value instead


// Mopub AdUnit ID

#define kMopubIphoneBanner                  @""
#define kMopubIphoneInterstitialPortrait 	@""
#define kMopubIphoneInterstitialLandscape 	@""

#define kMopubTabletLeaderboard 			@""
#define kMopubTabletInterstitialPortrait 	@""
#define kMopubTabletInterstitialLandscape 	@""

// Admob fallback banner
#define kAdmobIphoneBanner                  @""
#define kAdmobTabletLeaderboard 			@""

// Admob fallback interstitial
#define kAdmobIphoneInterstitialProtrait    @""
#define kAdmobIphoneInterstitialLandscape   @""

#define kAdmobTabletInterstitialProtrait    @""
#define kAdmobTabletInterstitialLandscape   @""
