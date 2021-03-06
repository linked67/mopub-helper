New version 4 with Admob fallback (interstitial and banners)

How to use
==========

Intall with pod:

        pod 'Mopub-helper', :git => 'https://github.com/linked67/mopub-helper.git'

Setup
-----

* Make a constraint in Interface Builder between top (or bottom) layout guide and a view you want to move to give the Banner some space.

* Fill the Mopub and Admob keys in MopubKeys.h (Change some params if you want)

* In the App delegate put code like this to enable this helper:


        - (void)viewWillAppear:(BOOL)animated{
           [super viewWillAppear:animated];
           [[MopubBannerSingleton sharedBanners] getMopubBanner:self onTop:NO constraint:_constraintForAdSpace];
        }

        - (void)viewWillDisappear:(BOOL)animated{
           [super viewWillDisappear:animated];
           [[MopubBannerSingleton sharedBanners] mopubBannerShouldDissapear:self];
        }


Display Banner
--------------

To display a banner, put this code in your ViewController:

        - (void)viewWillAppear:(BOOL)animated 
        {
            [[MopubBannerSingleton sharedBanners] getMopubBanner:self onTop:NO constraint:_constraintForAdSpace];
        }

     
The _constraintForAdSpace is the constraint you have make in Interface Builder

Since Version 4, no more need to more lines of code to manage screen rotation. It's internal !


Display Interstitial Automagically on app start
-----------------------------------------------

By default it's enabled, you have to do nothing ! Just don't forget to fill the AdUnitID in MopubKeys.h.
In this same file, you can disable or enable it and change the interval between each interstitial.

By default, it's 60 minutes between each. It means a interstitial will show on the first time the app open and after this, the users can open the app how many time they want into this time without interstitals again.
But after 60 minutes, if the user comes back, he get another interstitial.

Display Interstitial manually
-----------------------------

To display a interstitial, use this single line, a good place could be when the app start:

        - (void)viewDidLoad {
                [super viewDidLoad];
                
                [[MopubBannerSingleton sharedBanners] getAndShowInterstitial:self every:1];
        }

The value every:1 mean it display a interstitial every time this line is called. In this case, every time the view did load a interstitial appear.


