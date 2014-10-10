
How to use:

1. Make a constraint in Interface Builder between top (or bottom) layout guide and a view you want to move to give the Banner some space.

2. Fill the Mopub keys in MopubKeys.h

3. In the App delegate put code like this:

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[MopubBannerSingleton sharedBanners] mopubEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[MopubBannerSingleton sharedBanners] mopubEnterForeground];
}

4. To display a banner, put this code in your ViewController:

- (void)viewWillAppear:(BOOL)animated{
    [[MopubBannerSingleton sharedBanners] getMopubBanner:self onTop:NO constraint:_constraintForAdSpace];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[MopubBannerSingleton sharedBanners] mopubEnterBackground];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)  interfaceOrientation duration:(NSTimeInterval)duration {
    [[MopubBannerSingleton sharedBanners] getMopubBanner:self onTop:NO constraint:_constraintForAdSpace];
}

The _constraintForAdSpace is the constraint you have make in Interface Builder(1)

5. To display a interstitial, use this single line, a good place can be when the app start:

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MopubBannerSingleton sharedBanners] getAndShowInterstitial:self every:1];

}

The value every:1 mean it display a interstitial every time this line is called. In this case, every time the view did load a interstitial appear.





