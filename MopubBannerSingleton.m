//
//  MopubBannerSingletone.m
//
//  Created by bruno heitz on 28/09/13.
//  Copyright (c) 2013 bruno heitz. All rights reserved.
//
#define kInterstitialCount @"kInterstitialCount"

#import "MopubBannerSingleton.h"

@implementation MopubBannerSingleton

@synthesize adView;

+(MopubBannerSingleton *)sharedBanners{
    static dispatch_once_t pred;
    static MopubBannerSingleton *shared;
    
    // Will only be run once, the first time this is called
    dispatch_once(&pred, ^{
        shared = [[MopubBannerSingleton alloc] init];
    });
    
    return shared;
}

-(id)init {
    if (self = [super init]) {
        hadBanner = FALSE;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:kInterstitialCount];
        [defaults synchronize];
    }
    
    return self;
}

-(void)getMopubBanner:(UIViewController *)controller onTop:(BOOL)onTop constraint:(NSLayoutConstraint *)constraint {
    //NSLog(@"getmopub banner");
    
    
    // Keep some data for later
    actualBannerController = controller;
    isOnTopOfTheScreen = onTop;
    constraintControllerPushingOtherViews = constraint;
    
    // Create a new banner
    if (adView == nil) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.adView = [[MPAdView alloc] initWithAdUnitId:kMopubTabletLeaderboard
                                                        size:MOPUB_LEADERBOARD_SIZE];
        }else{
            self.adView = [[MPAdView alloc] initWithAdUnitId:kMopubIphoneBanner
                                                        size:MOPUB_BANNER_SIZE];
        }
        
        self.adView.delegate = (id)self;
        if (AdsEnabled) {
            [self.adView loadAd];
        }
   
    }
    
    [self.adView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
   
    // Search if there is a Mopub Ad in the controller
    BOOL isMopubFound = false;
    for (UIView *subView in [controller.view subviews]) {
        if ([subView isKindOfClass:[MPAdView class]]) {
            isMopubFound = true;
            //NSLog(@"(MopubBannerSingleton) Mopub banner found into view");
        }
    }
    
    // if no Mopub Ad in this controller, add one and setup the frame
    if (!isMopubFound) {
         //NSLog(@"(MopubBannerSingleton) Mopub banner not found into view, adding");
        [controller.view addSubview:adView];
        
        // must be after addsubview
        [self setupAdFrame:controller];
    }
    
    [self.adView startAutomaticallyRefreshingContents];
    
    
}

- (void)setupAdFrame:(UIViewController *)controller{
    //NSLog(@"setupAdFrame");

    // center X
    [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.adView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        
        // height adview
        [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:MOPUB_LEADERBOARD_SIZE.height]];
        
        // width adview
        [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:MOPUB_LEADERBOARD_SIZE.width]];
        
        
        if (isOnTopOfTheScreen){
            bannerHeight = MOPUB_LEADERBOARD_SIZE.height + ExtraSpace;

            // top adview and top screen
            constraintAdviewToGuide = [NSLayoutConstraint constraintWithItem:self.adView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:controller.topLayoutGuide
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
        
            
        }else{
            bannerHeight = MOPUB_LEADERBOARD_SIZE.height + ExtraSpace;

            // bottom adview and bottom screen
            constraintAdviewToGuide = [NSLayoutConstraint constraintWithItem:self.adView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:controller.bottomLayoutGuide
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];

        }
        
    }else {
        // The device is an iPhone or iPod touch.

        // height adview
        [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:50.0]];
        
        // width adview
        [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:320.0]];
        
        if (isOnTopOfTheScreen){
            bannerHeight = MOPUB_BANNER_SIZE.height + ExtraSpace;
            
            // top adview and top screen
            constraintAdviewToGuide = [NSLayoutConstraint constraintWithItem:self.adView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:controller.topLayoutGuide
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
            
        }else{
            bannerHeight = MOPUB_BANNER_SIZE.height + ExtraSpace;
            
            // bottom adview and bottom screen
            constraintAdviewToGuide = [NSLayoutConstraint constraintWithItem:self.adView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:controller.bottomLayoutGuide
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
            
        }
        
        
    }
    
    // Set AdView off screen if there is none each time a new controller is called
    constraintControllerPushingOtherViews.constant = 0; // Already at 0, no ?
    constraintAdviewToGuide.constant = bannerHeight;
    [controller.view addConstraint:constraintAdviewToGuide];
    
    // In the case we have a ad from another controller, show it
    if(hadBanner){
        [self moveBannerOnScreen];
    }
    
    
    
}

// use every:1 to display a interstitial every time this method is called
- (void)getAndShowInterstitial:(UIViewController *)controller every:(NSInteger)interstitialCount{
    
    // Get the interstitial count
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger mopubInterstitialCount = [[defaults objectForKey:kInterstitialCount] integerValue]+1;
    //NSLog(@"getAndShowInterstitial current count:%li every:%li", (long)mopubInterstitialCount, (long)interstitialCount);
    if (mopubInterstitialCount >= interstitialCount) {
        
        actualInterstitialController = controller;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // The device is an iPad running iPhone 3.2 or later.
            if ([self getIsPortrait]) {
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubTabletInterstitialPortrait];
            }else{
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubTabletInterstitialLandscape];
            }
            
        }else {
            // The device is an iPhone or iPod touch.
            if ([self getIsPortrait]) {
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubIphoneInterstitialPortrait];
            }else{
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubIphoneInterstitialLandscape];
            }
        }
        
        self.interstitial.delegate = self;
        
        // Fetch the interstitial ad.
        [self.interstitial loadAd];

        
    }else{
        [defaults setObject:[NSNumber numberWithInteger:mopubInterstitialCount] forKey:kInterstitialCount];
        [defaults synchronize];
        
    }
    
    
}

// Do we need this ?
/*
- (void)stopBanner{
    //NSLog(@"banner stoped and removed from superview");
    [self.adView removeFromSuperview];
    self.adView.delegate = nil;
    self.adView = nil;

}
*/

- (BOOL)getIsPortrait{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == 0){ //Default orientation
        //UI is in Default (Portrait) -- this is really a just a failsafe.
        return true;
    }else if(orientation == UIInterfaceOrientationPortrait){
        return true;
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }else if(orientation == UIInterfaceOrientationLandscapeLeft){
        return false;
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        return false;
    }
    return true;
    
}


#pragma mark - App delegate Foreground / backbroung

- (void)mopubEnterForeground{
    //NSLog(@"mopubEnterForeground");
    [self.adView startAutomaticallyRefreshingContents];
    
}
- (void)mopubEnterBackground{
    //NSLog(@"mopubEnterBackground");
    
    [self.adView stopAutomaticallyRefreshingContents];
//    [self stopBanner];
}


#pragma mark - Mopub Delegate

- (void)adViewDidLoadAd:(MPAdView *)view{
    //NSLog(@"(MopubBannerSingletone) adViewDidLoadAd");
   
    if (constraintControllerPushingOtherViews.constant == 0) {
        // constraint must give some space to the banner
        //NSLog(@"call mobeBannerOnScreen");
        [self moveBannerOnScreen];
    }
    
    hadBanner = YES;
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    //NSLog(@"(MopubBannerSingletone) adViewDidFailToLoadAd");
}

- (UIViewController *)viewControllerForPresentingModalView {
    //NSLog(@"++++ (MopubBannerSingletone) delegate viewControllerForPresentingModalView");
    return actualBannerController;
}


- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial{
    
    if (self.interstitial.ready){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:kInterstitialCount];
        [defaults synchronize];
        
        [self.interstitial showFromViewController:actualInterstitialController];
        
    }else {
        // The interstitial wasn't ready, so continue as usual.
    }
}

#pragma mark - Animation


// don't need to hide ? we still have the previous ad
/*
- (void)moveBannerOffScreen {
    [actualBannerController.view layoutIfNeeded];
 
    constraintControllerPushingOtherViews.constant = bannerHeight;
    constraintAdviewToGuide.constant = 0.0f;
    [UIView animateWithDuration:AppearAnimationTime
                     animations:^{
                         [actualBannerController.view layoutIfNeeded]; // Called on parent view
                     }];
    //bannerIsVisible = FALSE;
}
*/


- (void)moveBannerOnScreen {
    //NSLog(@"moveBannerOnScreen");
    
    [actualBannerController.view layoutIfNeeded];
    
    constraintControllerPushingOtherViews.constant = bannerHeight;
    constraintAdviewToGuide.constant = 0.0f;
    
    
    // Animate linear
    [UIView animateWithDuration:AppearAnimationTime
                     animations:^{
                         [actualBannerController.view layoutIfNeeded]; // Called on parent view
                     }];
    
    
    /* // Animate bounce
    [UIView animateWithDuration:AppearAnimationTime delay:0
         usingSpringWithDamping:0.3 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            [actualBannerController.view layoutIfNeeded]; // Called on parent view
                            
                        } completion:nil];
    
    */
    //bannerIsVisible = TRUE;
}



@end
