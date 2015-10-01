//
//  MopubBannerSingletone.m
//
//  Created by bruno heitz on 28/09/13.
//  Copyright (c) 2013 bruno heitz. All rights reserved.
//
#define kInterstitialCount @"kInterstitialCount"
#define kInterstitialLastDisplayTime @"kInterstitialLastDisplayTime"

#import "MopubBannerSingleton.h"

#import "AppDelegate.h"

@implementation MopubBannerSingleton

@synthesize adView;
@synthesize isAdsEnabled;
//@synthesize actualBannerController;

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
        isAdsEnabled = AdsEnabled;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:kInterstitialCount];
        [defaults synchronize];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationWillEnterForegroundNotification" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidBecomeActiveNotification" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationWillChangeStatusBarOrientationNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mopubEnterBackground)
                                                     name:@"UIApplicationDidEnterBackgroundNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mopubEnterForeground)
                                                     name:@"UIApplicationWillEnterForegroundNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mopubAppDidFinishLaunching)
                                                     name:@"UIApplicationDidFinishLaunchingNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mopubAppDidBecomeActive)
                                                     name:@"UIApplicationDidBecomeActiveNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bannerMustAdjustAfterScreenRotate)
                                                     name:@"UIApplicationWillChangeStatusBarOrientationNotification"
                                                   object:nil];

    }
    
    return self;
}

- (void)bannerMustAdjustAfterScreenRotate{
    //NSLog(@"bannerMustAdjustAfterScreenRotate");
    if (actualBannerController) {
        [self getMopubBanner:actualBannerController onTop:isOnTopOfTheScreen constraint:constraintControllerPushingOtherViews];
    }
}
-(void)getMopubBanner:(UIViewController *)controller onTop:(BOOL)onTop constraint:(NSLayoutConstraint *)constraint {
    //NSLog(@"getmopub banner");
    
    // check for controller again just to be safe
    if (isAdsEnabled && controller) {
        // Keep some data for later
        actualBannerController = controller;
        isOnTopOfTheScreen = onTop;
        constraintControllerPushingOtherViews = constraint;
        
        // Create a new banner
        if (adView == nil) {
            
            //[self createAdmobBanner];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.adView = [[MPAdView alloc] initWithAdUnitId:kMopubTabletLeaderboard
                                                            size:MOPUB_LEADERBOARD_SIZE];
            }else{
                self.adView = [[MPAdView alloc] initWithAdUnitId:kMopubIphoneBanner
                                                            size:MOPUB_BANNER_SIZE];
            }
            
            [(MPAdView *)self.adView setDelegate:(id)self];
            
            
            [self.adView loadAd];
            
            
        }
        
        [self.adView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        
        if ([adView isKindOfClass:[MPAdView class]]) {
            
            [(MPAdView *)self.adView setDelegate:(id)self];
            
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
            
        }else if ([adView isKindOfClass:[GADBannerView class]]){
            // Search if there is a Admob Ad in the controller
            
            [(GADBannerView *)self.adView setDelegate:(id)self];
            [(GADBannerView *)self.adView setRootViewController:actualBannerController];
            
            BOOL isAdmobFound = false;
            for (UIView *subView in [controller.view subviews]) {
                if ([subView isKindOfClass:[GADBannerView class]]) {
                    isAdmobFound = true;
                    //NSLog(@"(MopubBannerSingleton) Admob banner found into view");
                    //[self.adView removeFromSuperview];
                }
            }
            
            // if no Admob Ad in this controller, add one and setup the frame
            if (!isAdmobFound) {
                //NSLog(@"(MopubBannerSingleton) Admob banner not found into view, adding");
                [controller.view addSubview:adView];
                
                // must be after addsubview
                [self setupAdFrame:controller];
            }
            
        }
        
        [self.adView setHidden:NO];

    
        
    }else{
        [self.adView setHidden:YES];
    }
}

- (void)setupAdFrame:(UIViewController *)controller{
    //NSlog(@"setupAdFrame");

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
            bannerHeight = -MOPUB_LEADERBOARD_SIZE.height + ExtraSpace;

            // top adview and top screen
            constraintAdviewToGuide = [NSLayoutConstraint constraintWithItem:self.adView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:controller.topLayoutGuide
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
        
            
        }else{
            bannerHeight = MOPUB_LEADERBOARD_SIZE.height + ExtraSpace;

            // bottom adview and bottom screen
            constraintAdviewToGuide = [NSLayoutConstraint constraintWithItem:self.adView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:controller.bottomLayoutGuide
                                                                        attribute:NSLayoutAttributeTop
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
            bannerHeight = -MOPUB_BANNER_SIZE.height + ExtraSpace;
            
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
                                                                        attribute:NSLayoutAttributeTop
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

- (BOOL)isInterstitialElapsedTimeOver{
    // Get the last interstitial display time
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastInterstitialTime = [defaults objectForKey:kInterstitialLastDisplayTime];
    
    if(!lastInterstitialTime){
        lastInterstitialTime = [NSNumber numberWithLong:0];
    }
    
    NSNumber *elapsed = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] - [lastInterstitialTime longValue]];
    
    //NSLog(@"elapsed since last interstitial:%li", [elapsed longValue]);
    if ([elapsed longValue] >= ([currentMinimumIntervalTimeInMinutes longValue] * 60.0) ) {
        return YES;
    }
    return NO;
    
}

- (void)getAndShowInterstitialWithMinimumTimeIntervalInMinutes:(NSNumber *)minimumIntervalTimeInMinutes{
    //NSLog(@"++ getAndShowInterstitialWithMinimumTimeIntervalInMinutes ++");
    
    if (isAdsEnabled) {
    
        currentMinimumIntervalTimeInMinutes = minimumIntervalTimeInMinutes;
        
        if ([self isInterstitialElapsedTimeOver]) {
            
            self.interstitial = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                // The device is an iPad running iPhone 3.2 or later.
                if ([self isPortrait]) {
                    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubTabletInterstitialPortrait];
                    currentAdmobInterstitialID = kAdmobTabletInterstitialProtrait;
                }else{
                    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubTabletInterstitialLandscape];
                    currentAdmobInterstitialID = kAdmobTabletInterstitialLandscape;
                }
                
            }else {
                // The device is an iPhone or iPod touch.
                if ([self isPortrait]) {
                    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubIphoneInterstitialPortrait];
                    currentAdmobInterstitialID = kAdmobIphoneInterstitialProtrait;
                }else{
                    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubIphoneInterstitialLandscape];
                    currentAdmobInterstitialID = kAdmobIphoneInterstitialLandscape;
                }
            }
            
            self.interstitial.delegate = self;
            
            // Fetch the interstitial ad.
            
            [self.interstitial loadAd];
            
            
            
        }else{
            // do nothing, just wait
            // TODO: write a timer that check if we are over the time and fire interstitial or not ?
            
        }
        
    }
    
    
}


// use every:1 to display a interstitial every time this method is called
//- (void)getAndShowInterstitial:(UIViewController *)controller every:(NSInteger)interstitialCount{
- (void)getAndShowInterstitialEvery:(NSInteger)interstitialCount{
    
    // Get the interstitial count
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger mopubInterstitialCount = [[defaults objectForKey:kInterstitialCount] integerValue]+1;
    //NSlog(@"getAndShowInterstitial current count:%li every:%li", (long)mopubInterstitialCount, (long)interstitialCount);
    if (mopubInterstitialCount >= interstitialCount) {
        
        //actualInterstitialController = controller;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // The device is an iPad running iPhone 3.2 or later.
            if ([self isPortrait]) {
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubTabletInterstitialPortrait];
                currentAdmobInterstitialID = kAdmobTabletInterstitialProtrait;
            }else{
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubTabletInterstitialLandscape];
                currentAdmobInterstitialID = kAdmobTabletInterstitialLandscape;
            }
            
        }else {
            // The device is an iPhone or iPod touch.
            if ([self isPortrait]) {
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubIphoneInterstitialPortrait];
                currentAdmobInterstitialID = kAdmobIphoneInterstitialProtrait;
            }else{
                self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMopubIphoneInterstitialLandscape];
                currentAdmobInterstitialID = kAdmobIphoneInterstitialLandscape;
            }
        }
        
        self.interstitial.delegate = self;
        
        // Fetch the interstitial ad.
        if (isAdsEnabled) {
            [self.interstitial loadAd];
        }

        
    }else{
        [defaults setObject:[NSNumber numberWithInteger:mopubInterstitialCount] forKey:kInterstitialCount];
        [defaults synchronize];
        
    }
    
    
}

// Do we need this ?
/*
- (void)stopBanner{
    //NSlog(@"banner stoped and removed from superview");
    [self.adView removeFromSuperview];
    self.adView.delegate = nil;
    self.adView = nil;

}
*/

- (void)disableMopubBanner{
    //NSlog(@"banner disabled and removed from superview");
    [self.adView removeFromSuperview];
    [(MPAdView *)self.adView setDelegate:nil];
    self.adView = nil;

}


- (void)disableAdmobBanner{
    [self.adView setHidden:YES];
}


#pragma mark - App delegate Foreground / backbroung

- (void)mopubAppDidBecomeActive{
   // //NSLog(@"** mopubAppDidBecomeActive **");
    if(AutoShowInterstitial && isAdsEnabled){
        [self performSelector:@selector(getAndShowInterstitialWithMinimumTimeIntervalInMinutes:) withObject:[NSNumber numberWithLong:AutoInterstitialTimeBetweenEachInMinutes] afterDelay:AutoInterstitialDelayAfterAppBecomeActive];
    }
}


- (void)mopubAppDidFinishLaunching{
   // //NSLog(@"** mopubAppDidFinishLaunching **");
}

- (void)mopubEnterForeground{
    //NSLog(@"** mopubEnterForeground **");
    if (isAdsEnabled) {
        if (actualBannerController) {
            if ([adView isKindOfClass:[MPAdView class]]) {
                [self.adView startAutomaticallyRefreshingContents];
            }else if ([adView isKindOfClass:[GADBannerView class]]){
                [self getMopubBanner:actualBannerController onTop:isOnTopOfTheScreen constraint:constraintControllerPushingOtherViews];
                if (timer) {
                    [self resumeTimer:timer];
                }else{
                    //NSLog(@"wow no timer to resume ????");
                }
            }
            
        }
    }else{
        if (self.adView) {
            [self.adView setHidden:YES];
        }
    }
    
}
- (void)mopubEnterBackground{
    //NSLog(@"mopubEnterBackground");
    if (self.adView) {
        if ([adView isKindOfClass:[MPAdView class]]) {
            [self.adView stopAutomaticallyRefreshingContents];
        }else if ([adView isKindOfClass:[GADBannerView class]]){
            [self disableAdmobBanner];
            if (timer) {
                [self pauseTimer:timer];
            }else{
                //NSLog(@"wow no timer to pause ????");
            }
        }
    }
}

- (void)mopubBannerShouldDissapear:(UIViewController *)controller{
    //NSLog(@"(MopubBannerSingletone) mopubBannerShouldDissapear");
    if ([adView superview]) {
        [adView removeFromSuperview];
        //NSLog(@"(MopubBannerSingletone) mopubBannerShouldDissapear REMOVED");
    }
    
    if ([adView isKindOfClass:[MPAdView class]]) {
        [self.adView stopAutomaticallyRefreshingContents];
        //[(MPAdView *)self.adView setDelegate:nil];
    }else if ([adView isKindOfClass:[GADBannerView class]]){
        //[(GADBannerView *)self.adView setDelegate:nil];
        [(GADBannerView *)self.adView setRootViewController:nil];
        
    }
    
}

#pragma mark - Mopub Banner Delegate

- (void)adViewDidLoadAd:(MPAdView *)view{
    //NSLog(@"(MopubBannerSingletone) Mopub adViewDidLoadAd");
   
    if (constraintControllerPushingOtherViews.constant == 0) {
        // constraint must give some space to the banner
       // //NSLog(@"call mobeBannerOnScreen");
        if (isAdsEnabled && actualBannerController) {
            [self moveBannerOnScreen];
        }
    }
    
    hadBanner = YES;
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    //NSLog(@"(MopubBannerSingletone) Mopub adViewDidFailToLoadAd - ask admob");
    [self createAdmobBanner];
}

- (UIViewController *)viewControllerForPresentingModalView {
    //NSLog(@"++++ (MopubBannerSingletone) delegate viewControllerForPresentingModalView");
    return actualBannerController;
}

#pragma mark - Mopub Interstitial Delegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial{
    //NSlog(@"----------- mopub interstitialDidLoadAd ----------");
    if (isAdsEnabled) {
        if (self.interstitial.ready){
            if ([self isInterstitialElapsedTimeOver]) {
                
                [self saveLastInterstitialTimestampDisplayed];
                [self.interstitial showFromViewController:[[UIApplication sharedApplication] delegate].window.rootViewController];
            }
            
        }else {
            //NSlog(@"----------- The interstitial wasn't ready ----------");
            // The interstitial wasn't ready, so continue as usual.
        }
    }
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial{
    //NSlog(@"-- error interstitialDidFailToLoadAd - loading admob fallback -");
    if (isAdsEnabled) {
        [self createAndLoadAdmobInterstitial];
    }
}

#pragma mark - Admob init

- (void)createAdmobBanner{
    //NSLog(@"createAdmobBanner");
    [self disableMopubBanner];
    
    if (isAdsEnabled  && actualBannerController) {
        if (adView == nil) {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                self.adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
                [self.adView setAdUnitID:kAdmobTabletLeaderboard];
            }else{
                self.adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
                [self.adView setAdUnitID:kAdmobIphoneBanner];
            }
            
            [(GADBannerView *)self.adView setDelegate:(id)self];
            if (isAdsEnabled) {
                [(GADBannerView *)self.adView setRootViewController:actualBannerController];
                
                GADRequest *request = [GADRequest request];
                // Enable test ads on simulators.
                request.testDevices = @[ kDFPSimulatorID ]; // 7.2 kGADSimulatorID
                [(GADBannerView *)self.adView loadRequest:request];
                
            }
            
        }
        
        [self getMopubBanner:actualBannerController onTop:isOnTopOfTheScreen constraint:constraintControllerPushingOtherViews];
        
    }
    
    
}

- (void)createAndLoadAdmobInterstitial{
    if (isAdsEnabled) {
//        self.admobInterstitial = [[GADInterstitial alloc] init];
        self.admobInterstitial = [[GADInterstitial alloc] initWithAdUnitID:currentAdmobInterstitialID];
        self.admobInterstitial.delegate = (id)self;
  //      self.admobInterstitial.adUnitID = currentAdmobInterstitialID;
        
        GADRequest *request = [GADRequest request];
        
        // Requests test ads on simulators.
        request.testDevices = @[ kDFPSimulatorID ];
        
        [self.admobInterstitial loadRequest:request];
    }

}

#pragma mark - admob Banner delegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    //NSLog(@"admob banner - adViewDidReceiveAd");
    
    if (isAdsEnabled && actualBannerController) {
        if (constraintControllerPushingOtherViews.constant == 0) {
        // //NSLog(@"call mobeBannerOnScreen");
            [self moveBannerOnScreen];
            
        }
        [self startTimer];
    }
    
    hadBanner = YES;
    
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    //NSLog(@"admob banner - didFailToReceiveAdWithError");
}


#pragma mark - admob interstitial delegate

/// Called when an interstitial ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    //NSlog(@"ADMOB - interstitialDidReceiveAd");
    if (isAdsEnabled) {
        if ([self.admobInterstitial isReady]) {
            if ([self isInterstitialElapsedTimeOver]) {
                [self saveLastInterstitialTimestampDisplayed];
                [self.admobInterstitial presentFromRootViewController:[[UIApplication sharedApplication] delegate].window.rootViewController];
                
            }
        }
    }
    
}

/// Called when an interstitial ad request failed.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    //NSlog(@"ADMOB - interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
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
    //NSLog(@"moveBannerOnScreen, banner height:%f", fabs(bannerHeight));
    if (isAdsEnabled && actualBannerController) {
        [actualBannerController.view layoutIfNeeded];
        
        constraintControllerPushingOtherViews.constant = fabs(bannerHeight);
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
}

#pragma mark - Other

- (BOOL)isPortrait{
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

- (void)saveLastInterstitialTimestampDisplayed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:0] forKey:kInterstitialCount];
    [defaults setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:kInterstitialLastDisplayTime];
    [defaults synchronize];
}

#pragma mark - Admob timer

- (void)startTimer{
    //NSLog(@"-- start admob timer --");
    if (isAdsEnabled) {
        [self stopTimer];
        timer = [NSTimer scheduledTimerWithTimeInterval:AdmobRefreshInterval target:self selector:@selector(admobTimerTick) userInfo:nil repeats:NO];
    }
    
}

- (void) stopTimer{
    [timer invalidate];
    timer = nil;
}

- (void)admobTimerTick {
    //NSLog(@"admob tick ask another banner");
    if (actualBannerController) {
        [self.adView setRootViewController:actualBannerController];
        
        GADRequest *request = [GADRequest request];
        // Enable test ads on simulators.
        request.testDevices = @[ kDFPSimulatorID ];
        [(GADBannerView *)self.adView loadRequest:request];
    }
    
}

- (void)pauseTimer:(NSTimer *)mTimer {
    //NSLog(@"-- pause admob timer --");
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    previousFireDate = [mTimer fireDate];
    [mTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer:(NSTimer *)mTimer {
    //NSLog(@"-- resume admob timer --");
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    [mTimer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    
    //[pauseStart release];
    
    //[previousFireDate release];
}

- (void)removeBanners{
    isAdsEnabled = NO;
    if (self.adView) {
        [self.adView setDelegate:nil];
        [self.adView removeFromSuperview];
        self.adView = nil;
        
    }
}


@end
