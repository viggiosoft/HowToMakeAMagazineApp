//
//  AppDelegate.h
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Store;
@class ShelfViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) Store *store;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ShelfViewController *shelf;

@property (nonatomic,copy) NSString *text;

@end
