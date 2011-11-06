//
//  Issue.h
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

#define ISSUE_END_OF_DOWNLOAD_NOTIFICATION @"IssueEndOfDownload"
#define ISSUE_FAILED_DOWNLOAD_NOTIFICATION @"IssueFailedDownload"

@interface Issue : NSObject<NSURLConnectionDelegate,NSURLConnectionDownloadDelegate> {
    NSMutableData *downloadData; // only for iOS4
}

/* 
 issue basic properties; they will be fetched from the Publisher server (store)
 of course a real implamantation can introduce other properties depending on the app specs
*/

/* issueID is the unique identifier of an issue; it cannot be repeated and must be provided by the store;
   any change in the issueID is seen as a completely new issue. Also note that this is the only link
   with Newsstand's NKIssue
*/
@property (nonatomic,copy) NSString *issueID;

/* "title" is the issue title; it is normally displayed on top of the cover;
   please note that a real app can send this title based on the user localization
   so don't use it to identify the issue
*/

@property (nonatomic,copy) NSString *title;

/* "date" is the issue release date; even if not strictly required, it is needed by 
   Newsstand; however maintaining a releaseDate is useful if the user must manage
   subscriptions or just for sorting purposes 
*/
@property (nonatomic,retain) NSDate *releaseDate;

/* "coverURL" (we use a string as it is easier to manipulate than a real NSURL) is a 
   remote path to the URL of the cover image;
*/
@property (nonatomic,copy) NSString *coverURL;

/* "downloadURL" (we use a string as it is easier to manipulate than a real NSURL) is a
   remote path containing the URL of the download asset; note that in some apps you may
   have the need to maintain different URLs if the magazine is split in more assets. Also note
   that for free content you can send this url directly from the store, but in other cases to avoid
   hacking of your content, this URL can be a link to an API that will check for effective purchase
   of an issue before returning the effective URL. In these cases you must override the synthesized getter
   as the returned URL can contain input parameters
*/
@property (nonatomic,copy) NSString *downloadURL;

/* "free" takes note if the issue is free; this can be useful to know if we must get prices from StoreKit
   or to change the downloadURL; this information is taken from the publisher */
@property (nonatomic,assign,getter = isFree) BOOL free;

/* "downloadProgress" keeps the progress value (from 0 to 1) during download; it can be used by the UI
    to display a progress bar */
@property (nonatomic,readonly) float downloadProgress;

/* "downloading" is a flag checking downloading status of the issue */
@property (nonatomic,readonly,getter = isDownloading) BOOL downloading;

/* "contentURL" returns the file URL of where the issue will be installed or it has been
   installed yet; note that the meaning of this URL can be different, as it can refer to a base
   installation directory, or the real path of the pdf file or else. The exact meaning must be
   defined by the application and the convention must be respected
*/
-(NSURL *)contentURL;

/* "coverImage" returns the UIImage of the cover image; if it has not been downloaded yet it will
   return "nil"; in such case it will be care of the app to replace it with a placeholder or other
   UI effect
*/
-(UIImage *)coverImage;

/* "newsstandIssue" returns the NKIssue associated to this issue */
-(NKIssue *)newsstandIssue;

/* "isIssueAvailableForRead" returns YES if the issue has been downloaded and installed and is available in the filesystem */
-(BOOL)isIssueAvailableForRead;

/* "addInNewsstand" adds the issue in Newsstand library (if not added yet); in iOS4 the implementation of this method does nothing */
-(void)addInNewsstand;


@end
