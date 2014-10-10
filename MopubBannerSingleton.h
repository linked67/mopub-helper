//
//  MopubBannerSingletone.h
//
//  Created by bruno heitz on 28/09/13.
//  Copyright (c) 2013 bruno heitz. All rights reserved.
//
//
//  --------------------- How to use ------------------------------
//
//  Only need a constraint in Interface Builder between
//  top (or bottom) layout guide and a view
//
//  And put this somewhere, here or in a special header you import
//
//  #define kMopubIphoneBanner                  @"PutYourKeyHere"
//  #define kMopubIphoneInterstitialPortrait    @"PutYourKeyHere"
//  #define kMopubIphoneInterstitialLandscape   @"PutYourKeyHere"
//
//  #define kMopubTabletLeaderboard             @"PutYourKeyHere"
//  #define kMopubTabletInterstitialPortrait    @"PutYourKeyHere"
//  #define kMopubTabletInterstitialLandscape   @"PutYourKeyHere"
//
//  -----------------------------------------------------------------
//

// -- Params to adjust if need --

#define ExtraSpace 0.0f           // some more space between ad and other view
#define AppearAnimationTime 0.5f  // seconds

// -------------------------------

#import <Foundation/Foundation.h>

#import "MPAdView.h"
#import "MPInterstitialAdController.h"

// header with the keys
#import "MopubKeys.h"


@interface MopubBannerSingleton : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate>{

    UIViewController *actualBannerController, *actualInterstitialController;
    BOOL isOnTopOfTheScreen, hadBanner;
    
    NSLayoutConstraint *constraintControllerPushingOtherViews, *constraintAdviewToGuide;
    CGFloat bannerHeight;
}

+ (MopubBannerSingleton *)sharedBanners;
- (void)getMopubBanner:(UIViewController *)controller onTop:(BOOL)onTop constraint:(NSLayoutConstraint *)constraint;
- (void)getAndShowInterstitial:(UIViewController *)controller every:(NSInteger)interstitialCount;
- (void)setupAdFrame:(UIViewController *)controller;
- (void)stopBanner;

- (void)mopubEnterForeground;
- (void)mopubEnterBackground;

// Banner
@property (nonatomic, retain) MPAdView *adView;

// Interstitial
@property (nonatomic, retain) MPInterstitialAdController *interstitial;


@end
