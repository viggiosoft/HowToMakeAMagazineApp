//
//  CoverView.m
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 6/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "CoverView.h"
#import "Issue.h"

@implementation CoverView

@synthesize cover=_cover;
@synthesize title=_title;
@synthesize button=_button;
@synthesize progress=_progress;
@synthesize issueID=_issueID;

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 200, 307);
        // title label
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)] autorelease];
        _title.font=[UIFont boldSystemFontOfSize:18];
        _title.textColor=[UIColor whiteColor];
        _title.backgroundColor=[UIColor clearColor];
        _title.textAlignment=UITextAlignmentCenter;
        // cover image
        self.cover = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 200, 266)] autorelease];
        _cover.backgroundColor=[UIColor clearColor];
        _cover.contentMode=UIViewContentModeScaleAspectFit;
        // progress
        self.progress = [[[UIProgressView alloc] initWithFrame:CGRectMake(0, 286, 200, 20)] autorelease];
        _progress.alpha=0.0;
        _progress.progressViewStyle=UIProgressViewStyleBar;
        // button
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_button setBackgroundImage:[UIImage imageNamed:@"bottone_leggi"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonCallback:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
        _button.frame=CGRectMake(5, 286, 200, 21);
        
        [self addSubview:_title];
        [self addSubview:_cover];
        [self addSubview:_progress];
        [self addSubview:_button];
                
    }
    return self;
}

-(void)dealloc {
    [_cover release];
    [_title release];
    [_button release];
    [_progress release];
    [_issueID release];
    [super dealloc];
}

#pragma mark - Callbacks

-(void)buttonCallback:(id)sender {
    // notifies delegate of the selection
    [_delegate coverSelected:self];
}

#pragma mark - KVO and Notifications

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //ELog(@"Observed: %@",change);
    float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    _progress.progress=value;
}

-(void)issueDidEndDownload:(NSNotification *)notification {
    id obj = [notification object];
    _progress.alpha=0.0;
    [_button setTitle:@"READ" forState:UIControlStateNormal];
    _button.alpha=1.0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:obj];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:obj];
    [obj removeObserver:self forKeyPath:@"downloadProgress"];
}

-(void)issueDidFailDownload:(NSNotification *)notification {
    id obj = [notification object];
    _progress.alpha=0.0;
    [_button setTitle:@"READ" forState:UIControlStateNormal];
    _button.alpha=1.0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:obj];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:obj];
    [obj removeObserver:self forKeyPath:@"downloadProgress"];
}

@end
