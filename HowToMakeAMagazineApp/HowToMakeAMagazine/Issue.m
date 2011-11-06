//
//  Issue.m
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "Issue.h"

@interface Issue (Private) {
    
}

-(void)sendEndOfDownloadNotification;
-(void)sendFailedDownloadNotification;

@end

@implementation Issue

@synthesize title=_title;
@synthesize issueID=_issueID;
@synthesize releaseDate=_releaseDate;
@synthesize coverURL=_coverURL;
@synthesize downloadURL=_downloadURL;
@synthesize free=_free;
@synthesize downloadProgress=_downloadProgress;
@synthesize downloading=_downloading;

#pragma mark - Object lifecycle

-(id)init {
    self = [super init];
    if(self) {
        // you can set here all default inits
        _title=nil;
        _issueID=nil;
        _releaseDate=nil;
        _coverURL=nil;
        _downloadURL=nil;
        _downloading=NO;
    }
    return self;
}

-(void)dealloc {
    [_title release];
    [_issueID release];
    [_releaseDate release];
    [_coverURL release];
    [_downloadURL release];
    [downloadData release];
    [super dealloc];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ : ID=%@ Title=%@ Released=%@ Free=%@",
            [super description],
            _issueID,
            _title,
            _releaseDate,
            _free?@"YES":@"NO"
            ];
}

#pragma mark - Public methods

/* contentURL returns the effective URL where we'll store the magazine content and data;
   if Newsstand is supported, we'll return the NKIssue URL, if not will provide a sub-directory
   of the Caches directory whose name is the issue ID
*/
-(NSURL *)contentURL {
    NSURL *theURL;
    if(isOS5()) {
        theURL = [[self newsstandIssue] contentURL];
    } else {
        theURL = [NSURL fileURLWithPath:[CacheDirectory stringByAppendingPathComponent:_issueID]];
    }
    ELog(@"Content URL: %@",theURL);
    // creates it if not existing
    if([[NSFileManager defaultManager] fileExistsAtPath:[theURL path]]==NO) {
        NSLog(@"Creating content directory: %@",[theURL path]);
        NSError *error=nil;
        if([[NSFileManager defaultManager] createDirectoryAtPath:[theURL path] withIntermediateDirectories:NO attributes:nil error:&error]==NO) {
            NSLog(@"There was an error in creating the directory: %@",error);   
        }
        
    }
    // returns the url
    return theURL;
}

/* in our implementation the cover image is saved in the content URL with a file name called "cover.png" 
   if the image is found, nil will be returned
 */
-(UIImage *)coverImage {
    // get the image path
    NSString *imagePath = [[[self contentURL] URLByAppendingPathComponent:@"cover.png"] path];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    return theImage;
}

/* returns the NKIssue whose ID is the same as the issue ID */
-(NKIssue *)newsstandIssue {
    return [[NKLibrary sharedLibrary] issueWithName:_issueID];
}

/* "isIssueAvailableForRead" returns YES if the issue has been downloaded and installed and is available in the filesystem;
 the implementation is different according to the structure of the file; in our case we simply suppose the issue is made of
 a file called magazine.pdf */
-(BOOL)isIssueAvailableForRead {
    // get the magazine content path
    NSString *contentPath = [[[self contentURL] URLByAppendingPathComponent:@"magazine.pdf"] path];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:contentPath];
    ELog(@"Checking for path: %@ ==> %d",contentPath,fileExists);
    return(fileExists);
}


/* returns YES if the issue is currently in download */
-(BOOL)isDownloading {
    if(isOS5()) {
        // in Newsstand gets the info from NKIssue
        NKIssue *nkIssue = [self newsstandIssue];
        return(nkIssue.status==NKIssueContentStatusDownloading);
    } else {
        return _downloading;
    }
}

/* "addInNewsstand" adds the issue in Newsstand library (if not added yet); in iOS4 the implementation of this method does nothing */
-(void)addInNewsstand {
    if(isOS5()) {
        if(![self newsstandIssue]) {
            [[NKLibrary sharedLibrary] addIssueWithName:_issueID date:_releaseDate];
        }
    }
}

#pragma mark - Private methods

-(void)setDownloadProgress:(float)newDownloadProgress {
    _downloadProgress=newDownloadProgress;
    ELog(@"Download progress: %.0f%%",_downloadProgress*100);
}

#pragma mark - NSURLConnectionDelegate/NSURLConnectionDownloadDelegate (only for Newsstand)

// this message allows us to update the download progress
-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self setDownloadProgress:1.*totalBytesWritten/expectedTotalBytes];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self setDownloadProgress:1.*totalBytesWritten/expectedTotalBytes];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy the file to the destination directory
    NSURL *finalURL = [[self contentURL] URLByAppendingPathComponent:@"magazine.pdf"];
    ELog(@"Copying item from %@ to %@",destinationURL,finalURL);
    [[NSFileManager defaultManager] copyItemAtURL:destinationURL toURL:finalURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:NULL];
    // update Newsstand icon
    [[UIApplication sharedApplication] setNewsstandIconImage:[self coverImage]];
    // post notification
    [self sendEndOfDownloadNotification];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"There was an error downloading this issue %@ with connection %@ . Error is: %@",self,connection,error);
    _downloading=NO;
    [self setDownloadProgress:0.0];
    [downloadData release];
    // post notification
    [self sendFailedDownloadNotification];
}

#pragma mark - NSURLDataConnectionDelegate (iOS4)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(!downloadData) {
        downloadData = [[NSMutableData alloc] init];
    }
    [downloadData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [downloadData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"End of download");
    NSURL *finalURL = [[self contentURL] URLByAppendingPathComponent:@"magazine.pdf"];
    ELog(@"Saving downloaded magazine to %@",finalURL);
    [downloadData writeToURL:finalURL atomically:YES];
    [downloadData release];
    [self sendEndOfDownloadNotification];
}

#pragma mark - Notifications

-(void)sendEndOfDownloadNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:self];
}

-(void)sendFailedDownloadNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:self];    
}

@end
