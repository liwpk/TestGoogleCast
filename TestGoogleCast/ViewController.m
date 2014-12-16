//
//  ViewController.m
//  TestGoogleCast
//
//  Created by DavidLi on 12/8/14.
//  Copyright (c) 2014 DavidLi. All rights reserved.
//

#import "ViewController.h"
#import "GoogleCast/GoogleCast.h"

static NSString *const kReceiverAppID = @"CC1AD845";

@interface ViewController ()<GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate>
{
    UIImage *_btnImage;
    UIImage *_btnImageConnected;
    
}
/** The device scanner used to detect devices on the network. */
@property(nonatomic, strong) GCKDeviceScanner* deviceScanner;

/** The device manager used to manage conencted chromecast device. */
@property(nonatomic, strong) GCKDeviceManager* deviceManager;

@property GCKMediaControlChannel *mediaControlChannel;

@property(nonatomic, strong) GCKDevice *currentDevice;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _btnImage = [UIImage imageNamed:@"icon_cast_off.png"];
    _btnImageConnected = [UIImage imageNamed:@"icon_cast_on_filled.png"];
    
    UIButton *chromecastButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [chromecastButton addTarget:self
                         action:@selector(chooseDevice:)
               forControlEvents:UIControlEventTouchDown];
    chromecastButton.frame = CGRectMake(270, 60, _btnImage.size.width, _btnImage.size.height);
    [chromecastButton setTag:1212];
    [chromecastButton setImage:_btnImage forState:UIControlStateNormal];
    chromecastButton.hidden = YES;
    
    [self.view addSubview:chromecastButton];
    
    
    self.deviceScanner = [[GCKDeviceScanner alloc] init];
    GCKFilterCriteria *filterCriteria = [[GCKFilterCriteria alloc] init];
    filterCriteria = [GCKFilterCriteria criteriaForAvailableApplicationWithID:kReceiverAppID];
    self.deviceScanner.filterCriteria = filterCriteria;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startScan:(id)sender {
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
}

- (IBAction)stopScan:(id)sender {
    [self.deviceScanner removeListener:self];
    [self.deviceScanner stopScan];
}

- (IBAction)connectDevice:(id)sender {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appIdentifier = [info objectForKey:@"CFBundleIdentifier"];
    self.deviceManager = [[GCKDeviceManager alloc]initWithDevice:self.currentDevice clientPackageName:appIdentifier];
    [self.deviceManager setDelegate:self];
    [self.deviceManager connect];
    
    // Start animating the cast connect images.
    UIButton *chromecastButton = (UIButton *)[self.view viewWithTag:1212];
    chromecastButton.tintColor = [UIColor whiteColor];
    chromecastButton.imageView.animationImages =
    @[ [UIImage imageNamed:@"icon_cast_on0.png"], [UIImage imageNamed:@"icon_cast_on1.png"],
       [UIImage imageNamed:@"icon_cast_on2.png"], [UIImage imageNamed:@"icon_cast_on1.png"] ];
    chromecastButton.imageView.animationDuration = 2;
    [chromecastButton.imageView startAnimating];
}

- (IBAction)disconnectDevice:(id)sender {
    self.mediaControlChannel = nil;
    self.deviceManager = nil;
    self.currentDevice = nil;
}

- (IBAction)loadMedia:(id)sender {
    
    // cast Media
    
//    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
//    [metadata setString:title forKey:kGCKMetadataKeyTitle];
//    [metadata setString:subtitle forKey:kGCKMetadataKeySubtitle];
//    [metadata addImage:[[GCKImage alloc] initWithURL:thumbnailURL width:200 height:100]];
    
    
    NSString *imageURL = @"http://pic.nipic.com/2007-11-09/200711912230489_2.jpg";
    NSString *videoURL = @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    
    // contentType:image/jpg , video/mp4
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:videoURL
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:nil
                                    streamDuration:0
                                        customData:nil];
    
    [self.mediaControlChannel loadMedia:mediaInformation autoplay:YES playPosition:0];
}

- (IBAction)playMedia:(id)sender {
    BOOL res1 = self.mediaControlChannel;
    BOOL res2 = self.mediaControlChannel.mediaStatus;
    
    BOOL res3 = [self.mediaControlChannel play];
    
    NSLog(@"mediaControlChannel:%d, mediaControlChannel.mediaStatus:%d, play:%d",res1,res2,res3);
}

- (IBAction)pauseMedia:(id)sender {
    [self.mediaControlChannel pause];
}

- (IBAction)stopMedia:(id)sender {
    [self.mediaControlChannel stop];
}

- (IBAction)seekPlus:(id)sender {
    int currentDuration = self.mediaControlChannel.mediaStatus.mediaInformation.streamDuration;
    [self.mediaControlChannel seekToTimeInterval:currentDuration+10];
}

- (IBAction)seekMinus:(id)sender {
    int currentDuration = self.mediaControlChannel.mediaStatus.mediaInformation.streamDuration;
    [self.mediaControlChannel seekToTimeInterval:currentDuration-10];
}

- (IBAction)volPlus:(id)sender {
    int currentVol =  self.deviceManager.deviceVolume;
    [self.deviceManager setVolume:currentVol+5];
}

- (IBAction)volMinus:(id)sender {
    int currentVol =  self.deviceManager.deviceVolume;
    [self.deviceManager setVolume:currentVol-5];
}

- (void)chooseDevice:(id)sender{
    
}

- (void)updateCastIconButtonStates {
    // Hide the button if there are no devices found.
    UIButton *chromecastButton = (UIButton *)[self.view viewWithTag:1212];
    if (self.deviceScanner.devices.count == 0) {
//        chromecastButton.hidden = YES;
    } else {
        chromecastButton.hidden = NO;
        if (self.deviceManager && self.deviceManager.isConnectedToApp) {
            [chromecastButton.imageView stopAnimating];
            // Hilight with yellow tint color.
            [chromecastButton setTintColor:[UIColor blackColor]];
            [chromecastButton setImage:_btnImageConnected forState:UIControlStateNormal];
            
        } else {
            // Remove the highlight.
            [chromecastButton setTintColor:nil];
            [chromecastButton setImage:_btnImage forState:UIControlStateNormal];
        }
    }
}

#pragma mark - GCKDeviceScanner Listener

- (void)deviceDidComeOnline:(GCKDevice *)device
{
    NSLog(@"deviceDidComeOnline:%@",device);
    [self.deviceLabel setText:device.friendlyName];
    self.currentDevice = device;
}

- (void)deviceDidGoOffline:(GCKDevice *)device
{
    NSLog(@"deviceDidGoOffline:%@",device);
}

- (void)deviceDidChange:(GCKDevice *)device
{
    NSLog(@"deviceDidChange:%@",device);
}

#pragma mark - GCKDeviceManager Delegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager
{
    NSLog(@"deviceManagerDidConnect,device:%@",deviceManager.device.friendlyName);
    
    [self.deviceManager launchApplication:kReceiverAppID];
    [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication
{
    NSLog(@"deviceManager,didConnectToCastApplication:%@, sessionID:%@, app:%d ",applicationMetadata,sessionID,launchedApplication);
    
    self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    self.mediaControlChannel.delegate = self;
    [self.deviceManager addChannel:self.mediaControlChannel];
    
    [self updateCastIconButtonStates];
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectWithError:(NSError *)error{
    [self updateCastIconButtonStates];
}

#pragma mark - GCKMediaControlChannel Delegate
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
didCompleteLoadWithSessionID:(NSInteger)sessionID{
    
}

/**
 * Called when a request to load media has failed.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
didFailToLoadMediaWithError:(NSError *)error{
    
}

/**
 * Called when updated player status information is received.
 */
- (void)mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel{
    NSLog(@"curr.status:%@, get.status:%@",self.mediaControlChannel.mediaStatus,mediaControlChannel.mediaStatus);
    self.mediaControlChannel = mediaControlChannel;
}

/**
 * Called when updated media metadata is received.
 */
- (void)mediaControlChannelDidUpdateMetadata:(GCKMediaControlChannel *)mediaControlChannel{
    
}

/**
 * Called when a request succeeds.
 *
 * @param requestID The request ID that failed. This is the ID returned when the request was made.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
   requestDidCompleteWithID:(NSInteger)requestID{
    
}

/**
 * Called when a request is no longer being tracked because another request of the same type has
 * been issued by the application.
 *
 * @param requestID The request ID that has been replaced. This is the ID returned when the request
 * was made.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
    didReplaceRequestWithID:(NSInteger)requestID{
    
}

/**
 * Called when a request fails.
 *
 * @param requestID The request ID that failed. This is the ID returned when the request was made.
 * @param error The error. If any custom data was associated with the error, it will be in the
 * error's userInfo dictionary with the key {@code kGCKErrorCustomDataKey}.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
       requestDidFailWithID:(NSInteger)requestID
                      error:(NSError *)error{
    
}

@end
