//
//  AppDelegate.m
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "AppDelegate.h"
#import "Store.h"
#import "ShelfViewController.h"
#import <NewsstandKit/NewsstandKit.h>
#import "Issue.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize store = _store;
@synthesize shelf = _shelf;

@synthesize text;

- (void)dealloc
{
    [_window release];
    [_store release];
    [_shelf release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // here we create the "Store" instance
    _store = [[Store alloc] init];
    [_store startup];
    
    // called when app is terminated and a download finished
     NKLibrary *nkLib = [NKLibrary sharedLibrary];
    for(NKAssetDownload *asset in [nkLib downloadingAssets]) {
        NKIssue *nkIssue = [asset issue];
        Issue *issueInDownload = [[Issue alloc] init];
        issueInDownload.issueID=nkIssue.name;
        NSLog(@"Resuming download for issue %@ (asset ID: %@)",nkIssue.name,asset.identifier);
        [asset downloadWithDelegate:issueInDownload];
    }

    self.shelf = [[[ShelfViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    _shelf.store=_store;

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = _shelf;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
