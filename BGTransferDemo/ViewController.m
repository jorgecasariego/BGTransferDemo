//
//  ViewController.m
//  BGTransferDemo
//
//  Created by Jorge Casariego on 25/04/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

#import "ViewController.h"
#import "FileDownloadInfo.h"

@interface ViewController ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

@property (nonatomic, strong) NSURL *docDirectoryURL;

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
                // The resume of a download task will be done here.
            }
        }
        else{
            //  The pause of a download task will be done here.
        }
        
        //Change the isDownloading property value
        fdi.isDownloading = !fdi.isDownloading;
        
        //Reload the table view
        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
}

@end
