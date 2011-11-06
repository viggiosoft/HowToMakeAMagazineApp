//
//  Store.h
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Issue;

#define STORE_CHANGED_STATUS_NOTIFICATION @"StoreChangedStatus"

typedef enum {
    StoreStatusNotInizialized,
    StoreStatusDownloading,
    StoreStatusReady,
    StoreStatusError
} StoreStatusType ;

@interface Store : NSObject {
    
    /* we will store here all issues taken from the store; this is the list of issues that the publisher want
     to be available for purchase and download */
    NSMutableArray *storeIssues;
    
    /* we will store here the list of issues that have been purchased and/or downloaded by the user; note that this list can include
     items not in the store, as they may have been removed by the publisher */
    NSMutableDictionary *userIssues;
    
    dispatch_queue_t DOWNLOAD_GCD_QUEUE;
    NSOperationQueue *downloadQueue;
    
    
}

/* takes note of the current store status; this can be used by the view controllers to update their UI according to the status */
@property (nonatomic,assign) StoreStatusType status;

/* startup
   this begins the Store startup sequence, which must be run immediately after the Store has been initialized;
   main purpose of startup is to connect with the publisher server to fetch the list of currently available magazines;
   besides the store will load the current status of user issues
*/
-(void)startup;

/* returns YES if the store information is ready */
-(BOOL)isStoreReady;

/* "scheduleDownloadOfIssue:" will schedule content download (effective download will start depending on the system status or the
 download queue implementation) */
-(void)scheduleDownloadOfIssue:(Issue *)issueToDownload;

/* "numberOfIssues" is used to retrieve the number of issues in the store */
-(NSInteger)numberOfStoreIssues;

/* "issueAtIndex:" retrieves the issue at the given index */
-(Issue *)issueAtIndex:(NSInteger)index;

/* "issueWithID:" retrieves the issue with the given ID */
-(Issue *)issueWithID:(NSString *)issueID;

@end
