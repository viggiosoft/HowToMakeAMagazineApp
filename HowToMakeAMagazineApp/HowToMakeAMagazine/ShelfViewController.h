//
//  ShelfViewController.h
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 6/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@class Store;
@class CoverView;

/* delegate protocol to pass actions from the CoverView to the Shelf controller */

@protocol ShelfViewControllerProtocol

-(void)coverSelected:(CoverView *)cover;

@end

@interface ShelfViewController : UIViewController<ShelfViewControllerProtocol,QLPreviewControllerDelegate,QLPreviewControllerDataSource> {
    
    NSURL *urlOfReadingIssue;
    
}

@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) Store *store;

@end

