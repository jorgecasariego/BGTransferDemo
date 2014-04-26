//
//  FileDownloadInfo.h
//  BGTransferDemo
//
//  Created by Jorge Casariego on 26/04/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadInfo : NSObject

@property (nonatomic, strong) NSString *fileTitle;

@property (nonatomic, strong) NSString *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResume;

@property (nonatomic) double downloadProgress;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

//Custom init method
- (id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source;

@end
