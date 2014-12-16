//
//  ViewController.h
//  TestGoogleCast
//
//  Created by DavidLi on 12/8/14.
//  Copyright (c) 2014 DavidLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;

- (IBAction)startScan:(id)sender;
- (IBAction)stopScan:(id)sender;
- (IBAction)connectDevice:(id)sender;
- (IBAction)disconnectDevice:(id)sender;
- (IBAction)loadMedia:(id)sender;
- (IBAction)playMedia:(id)sender;
- (IBAction)pauseMedia:(id)sender;
- (IBAction)stopMedia:(id)sender;

- (IBAction)seekPlus:(id)sender;
- (IBAction)seekMinus:(id)sender;
- (IBAction)volPlus:(id)sender;
- (IBAction)volMinus:(id)sender;

@end

