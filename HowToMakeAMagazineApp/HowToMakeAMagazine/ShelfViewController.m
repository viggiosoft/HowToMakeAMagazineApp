//
//  ShelfViewController.m
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 6/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "ShelfViewController.h"
#import "Store.h"
#import "CoverView.h"
#import "Issue.h"
#import <QuickLook/QuickLook.h>

@interface ShelfViewController (Private)

-(void)showShelf;
-(void)updateShelf;
-(void)readIssue:(Issue *)issue;
-(void)downloadIssue:(Issue *)issue updateCover:(CoverView *)cover;
-(CoverView *)coverWithID:(NSString *)issueID;

@end

@implementation ShelfViewController

@synthesize containerView=containerView_;
@synthesize store=_store;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(storeDidChangeStatusNotification:) 
                                                 name:STORE_CHANGED_STATUS_NOTIFICATION
                                               object:nil];
    
    [self updateShelf];
}

- (void)viewDidUnload
{
    [self setContainerView:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:STORE_CHANGED_STATUS_NOTIFICATION object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc {
    [containerView_ release];
    [_store release];
    [super dealloc];
}

#pragma mark - View display

-(void)storeDidChangeStatusNotification:(NSNotification *)not {
    ELog(@"Store changed status to %d",_store.status);
    [self updateShelf];
    [self showShelf];
}

-(void)viewWillAppear:(BOOL)animated {
    ELog(@"Store status: %d",_store.status);
    [self showShelf];
    [super viewWillAppear:animated];
}

-(void)showShelf {
    if([_store isStoreReady]) {
        containerView_.alpha=1.0;
    } else {
        containerView_.alpha=0.0;
    }
    
}

-(void)updateShelf {
    // clean container view
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // regenerate and add all views
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat deltaX = (screenSize.width/3.);
    CGFloat deltaY = ((screenSize.height-20)/3.);
    NSInteger issuesCount = [_store numberOfStoreIssues];
    for(NSInteger i=0;i<issuesCount;i++) {
        Issue *anIssue = [_store issueAtIndex:i];
        CoverView *cover = [[[CoverView alloc] initWithFrame:CGRectZero] autorelease];
        cover.issueID=anIssue.issueID;
        cover.delegate=self;
        cover.title.text=anIssue.title;
        cover.cover.image=[anIssue coverImage];
        if([anIssue isIssueAvailableForRead]) {
            [cover.button setTitle:@"READ" forState:UIControlStateNormal];
        } else {
            [cover.button setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
        }
        NSInteger row = i/3;
        NSInteger col = i%3;
        CGRect coverFrame = cover.frame;
        coverFrame.origin=CGPointMake(deltaX*col+(deltaX-CGRectGetWidth(coverFrame))/2.0, 20+deltaY*row+(deltaY-CGRectGetHeight(coverFrame))/2.0);
        cover.frame=coverFrame;
        [containerView_ addSubview:cover];
    }
    
}

-(CoverView *)coverWithID:(NSString *)issueID {
    for(UIView *aView in containerView_.subviews) {
        if([aView isKindOfClass:[CoverView class]] && [[(CoverView *)aView issueID] isEqualToString:issueID]) {
            return (CoverView *)aView;
        }
    }
    return nil;
}

#pragma mark - ShelfViewControllerProtocol implementation 

-(void)coverSelected:(CoverView *)cover {
    NSString *selectedIssueID = cover.issueID;
    Issue *selectedIssue = [_store issueWithID:selectedIssueID];
    if(!selectedIssue) return;
    if([selectedIssue isIssueAvailableForRead]) {
        [self readIssue:selectedIssue];
    } else {
        [self downloadIssue:selectedIssue updateCover:cover];
    }
}

#pragma mark - Actions

-(void)readIssue:(Issue *)issue {
    QLPreviewController *preview = [[QLPreviewController alloc] initWithNibName:nil bundle:nil];
    preview.delegate=self;
    preview.dataSource=self;
    urlOfReadingIssue=[[issue contentURL] URLByAppendingPathComponent:@"magazine.pdf"];
    [self presentModalViewController:preview animated:YES];
}

-(void)downloadIssue:(Issue *)issue updateCover:(CoverView *)cover {
    cover.progress.alpha=1.0;
    cover.button.alpha=0.0;
    //[cover.button setTitle:@"DOWNLOADING" forState:UIControlStateNormal];
    [issue addObserver:cover forKeyPath:@"downloadProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueDidEndDownload:) name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:issue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueDidFailDownload:) name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:issue];
    [[NSNotificationCenter defaultCenter] addObserver:cover selector:@selector(issueDidEndDownload:) name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:issue];
    [[NSNotificationCenter defaultCenter] addObserver:cover selector:@selector(issueDidFailDownload:) name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:issue];
    [_store scheduleDownloadOfIssue:issue];
}

-(void)issueDidEndDownload:(NSNotification *)notification {
    Issue *issue = (Issue *)[notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:issue];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:issue];
}

-(void)issueDidFailDownload:(NSNotification *)notification {
    Issue *issue = (Issue *)[notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:issue];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:issue];
}

#pragma mark QuickLook

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return urlOfReadingIssue;
}

-(void)previewControllerDidDismiss:(QLPreviewController *)controller {
    [controller autorelease];
}

@end
