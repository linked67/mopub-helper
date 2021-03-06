//
//  MopubBannerSingletone.h
//
//  Created by bruno heitz on 28/09/13.
//  Copyright (c) 2013 bruno heitz. All rights reserved.
//
//  V 4.9
//
//  --------------------- How to use ------------------------------
//
//  Only need a constraint in Interface Builder between
//  top (or bottom) layout guide and a view
//
//  Fill the MopubKeys.plist file with your mopub/admob keys
//
//  -----------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "MPAdView.h"
#import "MPInterstitialAdController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>


@interface MopubBannerSingleton : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate, GADInterstitialDelegate>{

    __weak UIViewController *actualBannerController;
    NSNumber *currentMinimumIntervalTimeInMinutes;
    NSString *currentAdmobInterstitialID;
    
    BOOL isOnTopOfTheScreen, hadBanner;
    
    __weak NSLayoutConstraint *constraintControllerPushingOtherViews, *constraintAdviewToGuide;
    CGFloat bannerHeight;
    
    //for admob
    NSTimer *timer;
    NSInteger timeCounter;
    NSDate *pauseStart, *previousFireDate;
}

+ (MopubBannerSingleton *)sharedBanners;
+ (id)configValueForKey:(NSString *)key;

- (void)getMopubBanner:(UIViewController *)controller onTop:(BOOL)onTop constraint:(NSLayoutConstraint *)constraint;
- (void)getAndShowInterstitialWithMinimumTimeIntervalInMinutes:(NSNumber *)minimumIntervalTimeInMinutes;
- (void)getAndShowInterstitialEvery:(NSInteger)interstitialCount;
- (void)mopubBannerShouldDissapear:(UIViewController *)controller;

- (void)removeBanners;

// Mopub and Admob Banner
@property (nonatomic, strong) id adView;

// Mopub Interstitial
@property (nonatomic, retain) MPInterstitialAdController *interstitial;

// Admob interstitial
@property(nonatomic, strong) GADInterstitial *admobInterstitial;

@property (nonatomic) BOOL isAdsEnabled;

@end
