//
//  MopubBannerSingletone.h
//
//  Created by bruno heitz on 28/09/13.
//  Copyright (c) 2013 bruno heitz. All rights reserved.
//
//  V 4.0
//
//  --------------------- How to use ------------------------------
//
//  Only need a constraint in Interface Builder between
//  top (or bottom) layout guide and a view
//
//  Fill the MopubKeys file with good settings
//
//  -----------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "MPAdView.h"
#import "MPInterstitialAdController.h"

// header with the keys and params
#import "MopubKeys.h"

// Admob interstitial
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

// Admob banner
#import "GADBannerView.h"
#import "GADRequest.h"




@interface MopubBannerSingleton : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate, GADInterstitialDelegate>{

    UIViewController *actualBannerController;
    NSNumber *currentMinimumIntervalTimeInMinutes;
    NSString *currentAdmobInterstitialID;
    
    BOOL isOnTopOfTheScreen, hadBanner;
    
    NSLayoutConstraint *constraintControllerPushingOtherViews, *constraintAdviewToGuide;
    CGFloat bannerHeight;
    
    //for admob
    NSTimer *timer;
    NSInteger timeCounter;
    NSDate *pauseStart, *previousFireDate;
}

+ (MopubBannerSingleton *)sharedBanners;

- (void)getMopubBanner:(UIViewController *)controller onTop:(BOOL)onTop constraint:(NSLayoutConstraint *)constraint;
- (void)getAndShowInterstitialWithMinimumTimeIntervalInMinutes:(NSNumber *)minimumIntervalTimeInMinutes;
- (void)getAndShowInterstitialEvery:(NSInteger)interstitialCount;


// Mopub and Admob Banner
@property (nonatomic, retain) id adView;

// Mopub Interstitial
@property (nonatomic, retain) MPInterstitialAdController *interstitial;

// Admob interstitial
@property(nonatomic, strong) GADInterstitial *admobInterstitial;

@property (nonatomic) BOOL isAdsEnabled;


@end
