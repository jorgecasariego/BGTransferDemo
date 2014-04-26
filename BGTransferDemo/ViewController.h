//
//  ViewController.h
//  BGTransferDemo
//
//  Created by Jorge Casariego on 25/04/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

#import <UIKit/UIKit.h>

// Define some constants regarding the tag values of the prototype cell's subviews.
#define CellLabelTagValue               10
#define CellStartPauseButtonTagValue    20
#define CellStopButtonTagValue          30
#define CellProgressBarTagValue         40
#define CellLabelReadyTagValue          50

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblFiles;

- (IBAction)startOrPauseDownloadingSingleFile:(id)sender;

- (IBAction)stopDownloading:(id)sender;

- (IBAction)startAllDownloads:(id)sender;

- (IBAction)stopAllDownloads:(id)sender;

- (IBAction)initializeAll:(id)sender;

- (void)initializeFileDownloadDataArray;

@end
