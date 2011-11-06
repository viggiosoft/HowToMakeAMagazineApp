//
//  CoverView.h
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 6/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShelfViewController.h"

@interface CoverView : UIView

@property (nonatomic,copy) NSString *issueID;
@property (nonatomic,assign) id<ShelfViewControllerProtocol> delegate;

@property (nonatomic,retain) UIImageView *cover;
@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) UIProgressView *progress;
@property (nonatomic,retain) UILabel *title;

@end
