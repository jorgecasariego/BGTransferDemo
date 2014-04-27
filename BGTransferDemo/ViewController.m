//
//  ViewController.m
//  BGTransferDemo
//
//  Created by Jorge Casariego on 25/04/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

#import "ViewController.h"
#import "FileDownloadInfo.h"

// Define some constants regarding the tag values of the prototype cell's subviews.
#define CellLabelTagValue               10
#define CellStartPauseButtonTagValue    20
#define CellStopButtonTagValue          30
#define CellProgressBarTagValue         40
#define CellLabelReadyTagValue          50


@interface ViewController ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

@property (nonatomic, strong) NSURL *docDirectoryURL;

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initializeFileDownloadDataArray];
    
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.docDirectoryURL = [URLs objectAtIndex:0];
    
    //Make self the delegate and datasource of the table view
    self.tblFiles.delegate = self;
    self.tblFiles.dataSource = self;
    
    //Disable scrolling in the table view
    self.tblFiles.scrollEnabled = NO;
    
    // backgroundSessionConfiguration class method is used when it’s desirable to perform background tasks
    // The backgroundSessionConfiguration class method accepts one parameter, an identifier, which uniquely
    // identifies the session started by our app in the system.
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.BGTransferDemo"];
    
    //Through this, we will allow five simultaneous downloads to take place at once
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    
    //The next step that must be performed, is to instantiate the session property using the sessionConfiguration object
    //Here a NSURLSession session has been instantiated and is now ready to be used in order to fire background download tasks.
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeFileDownloadDataArray
{
    self.arrFileDownloadData = [[NSMutableArray alloc] init];
    
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iOS Programming Guide" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Human Interface Guidelines" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/MobileHIG.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Networking Overview" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"AV Foundation" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iPhone User Guide" andDownloadSource:@"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"]];
}

// In a loop, we’ll access all FileDownloadInfo objects of the arrFileDownloadData array one by one,
// until we find the task with identifier matching to the parameter’s one.
// When it’s found, we’ll just break the loop and we’ll return the found index value.
-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier
{
    int index = 0;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if(fdi.taskIdentifier == taskIdentifier)
        {
            index = i;
            break;
        }
    }
    
    return index;
}

#pragma mark - UITableView Delegate and Datasource method implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrFileDownloadData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1. We dequeue the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCell"];
    }
    
    //Get the respective FileDownloadInfo object from the arrFileDownloadData array
    FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:indexPath.row];
    
    //Get all cell's subviews
    UILabel *displayedTitle = (UILabel *)[cell viewWithTag:10];
    UIButton *startPauseButton = (UIButton *)[cell viewWithTag:CellStartPauseButtonTagValue];
    UIButton *stopButton = (UIButton *)[cell viewWithTag:CellStopButtonTagValue];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
    UILabel *readyLabel = (UILabel *)[cell viewWithTag:CellLabelReadyTagValue];
    
    NSString *startPauseButtonImageName;
    
    //Set the file title
    displayedTitle.text = fdi.fileTitle;
    
    //Depending on wheter the current file is being downloaded or not, specify the status
    //of the progress bar and the couple of button on the cell
    if(!fdi.isDownloading)
    {
        //Hide the progress view and disable the stop button
        progressView.hidden = YES;
        stopButton.enabled = NO;
        
        // Set a flag value depending on the downloadComplete property of the fdi object.
        // Using it will be shown either the start and stop buttons, or the Ready label
        BOOL hideControls = (fdi.downloadComplete) ? YES : NO;
        startPauseButton.hidden = hideControls;
        stopButton.hidden = hideControls;
        readyLabel.hidden = !hideControls;
        
        startPauseButtonImageName = @"play-25";
    }
    else
    {
        // Show the progress view and update its progress, change the image of the start button so it shows
        // a pause icon, and enable the stop button.
        progressView.hidden = NO;
        progressView.progress = fdi.downloadProgress;
        
        stopButton.enabled = YES;
        
        startPauseButtonImageName = @"pause-25";
    }
    
    //Set the appropiate image to the start button
    [startPauseButton setImage:[UIImage imageNamed:startPauseButtonImageName] forState:UIControlStateNormal];
    
    return cell;
}


#pragma mark - IBAction method implementation

- (IBAction)startOrPauseDownloadingSingleFile:(id)sender
{
    //Check if the parent view of the sender button is a table view cell
    //All the subviews we added to the prototype cells, belong to a view named content view, and this content view is a subview of a scroll view. The scroll view is actually a direct subview of the cell, that’s why we use the superview property so many times.
    if([[[[sender superview] superview]superview] isKindOfClass:[UITableViewCell class]])
    {
        //Get the container cell
        UITableViewCell *containerCell = (UITableViewCell *)[[[sender superview] superview] superview];
        
        //Get the row (index) of the cell. We'll keep the index path as well, we'll need it later
        NSIndexPath *cellIndexPath = [self.tblFiles indexPathForCell:containerCell];
        int cellIndex = cellIndexPath.row;
        
        //Get the FileDownloadInfo object being at the cellIndex position of the array
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
        
        // The isDownloading property of the fdi object defines whether a downloading should be started
        // or be stopped.
        if(!fdi.isDownloading)
        {
            // This is the case where a download task should be started.
            
            // Create a new task, but check whether it should be created using a URL or resume data.
            //When a new download task gets started, this property gets the tasks’s identifier value, so it stops having the −1 value
            if(fdi.taskIdentifier == -1)
            {
                // If the taskIdentifier property of the fdi object has value -1, then create a new task
                // providing the appropriate URL as the download source.
                // The newly created download task is assigned to the downloadTask of the fdi object, so we can have a strong reference to it and access it directly later on.
                fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
                
                //Keep the new task identifier
                fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
                
                //Start the task
                [fdi.downloadTask resume];
            }
            else{
                //  A new download task is created by using the downloadTaskWithResumeData: method of the session object.
                //  This new task is assigned to the downloadTask object for future access, and then it’s resumed.
                //  Finally, the new task identifier is stored to the respective property.
                
                //Create a new download task, which will use the stored resume data
                fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResume];
                [fdi.downloadTask resume];
                
                //Keep the new download task identifier
                fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
            }
        }
        else{
            // The phrase pause a download task is good enough to make us understand the concept of our discussion, however programmatically speaking this is not accurate. The truth is that either we want to pause or stop a download task, we must perform the same action, to cancel the task. The difference is that in the first case the download task produces some data for resuming the download, while in the second case that doesn’t happen. In both cases, the task gets destroyed and if it’s desirable to resume the download, a new task is created using the resume data earlier produced.
            
            // Pause the  task by cancelling it and storing the resume data
            [fdi.downloadTask cancelByProducingResumeData:^(NSData *resumeData){
                if(resumeData != nil)
                {
                    fdi.taskResume = [[NSData alloc] initWithData:resumeData];
                }
            }];
        }
        
        //Change the isDownloading property value
        fdi.isDownloading = !fdi.isDownloading;
        
        //Reload the table view
        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
}

- (IBAction)stopDownloading:(id)sender
{
    if ([[[[sender superview] superview] superview] isKindOfClass:[UITableViewCell class]])
    {
        // Get the container cell.
        UITableViewCell *containerCell = (UITableViewCell *)[[[sender superview] superview] superview];
        
        // Get the row (index) of the cell. We'll keep the index path as well, we'll need it later.
        NSIndexPath *cellIndexPath = [self.tblFiles indexPathForCell:containerCell];
        int cellIndex = cellIndexPath.row;
        
        // Get the FileDownloadInfo object being at the cellIndex position of the array.
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
        
        //Cancel the task
        [fdi.downloadTask cancel];
        
        //Change all related properties
        fdi.isDownloading = NO;
        fdi.taskIdentifier = -1;
        fdi.downloadProgress = 0.0;
        
        //Reload the table view
        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
}

#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{

    //The first thing we have to do, is to check if the system is aware of the size of the file that’s being downloaded.
    if(totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown)
    {
        NSLog(@"Unknown transfer size");
    }
    else    //We will proceed with the progress update if only this data exists.
    {
        //We locate the index of the appropriate FileDownloadInfo object in the arrFileDownloadData array, based on the task description of the downloadTask parameter object, and we use a local pointer to access it.
        

        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];

        //Because the download task works in background threads, any visual upgrades must take place in the main thread of the app
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //Calculate the progress
            fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            // Get the progress view of the appropriate cell and update its progress.
            UITableViewCell *cell = [self.tblFiles cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
            progressView.progress = fdi.downloadProgress;
        }];
        
    }
}

//This method is called by the system every time a download is over, and is our duty to write the appropriate code in order
//to get the file from its temporary location
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //lastPathComponent provide us the actual file name, along with its extension
    NSString *destinationFileName = downloadTask.originalRequest.URL.lastPathComponent;
    //This destination is where the file will be copied permanently
    NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:destinationFileName];
    
    //Check if the file already exists in the Documents directory, using the fileManager object
    //that was instantiated at the beginning of the method, and the destinationURL value
    if([fileManager fileExistsAtPath:[destinationURL path]])
    {
        //If it already exists, then is being removed.
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    //The file copying process takes place here
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&error];
    
    if(success)
    {
        // Change the flag values of the respective FileDownloadInfo object.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        fdi.isDownloading = NO;
        fdi.downloadComplete = YES;
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        fdi.taskIdentifier = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Reload the respective table view row using the main thread.
            [self.tblFiles reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else
    {
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
    }
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
    }
    else{
        NSLog(@"Download finished successfully.");
    }
}


@end
