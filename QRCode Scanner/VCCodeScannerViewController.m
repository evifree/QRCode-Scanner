//
//  ViewController.m
//  AVCapture
//
//  Created by Venj Chu on 13-11-11.
//  Copyright (c) 2013年 Venj Chu. All rights reserved.
//

#import "VCCodeScannerViewController.h"
#import "VCCodeScannerView.h"
#import "UIDevice+iOS7.h"
#import <ZBarSDK/ZBarSDK.h>
#import <AudioToolbox/AudioToolbox.h>

@interface VCCodeScannerViewController () <VCCodeScanViewDelegate>
@property (nonatomic, strong) UIView *captureParentView;
@property (nonatomic, strong) VCCodeScannerView *captureView;
@end

@implementation VCCodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (!self.title) self.title = NSLocalizedString(@"QR Code Scanner", @"QR Code Scanner");
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat height;
    if ([[UIDevice currentDevice] deviceSystemMajorVersion] > 6) {
        height = [UIScreen mainScreen].bounds.size.height;
    }
    else {
        height = [UIScreen mainScreen].bounds.size.height - 44. - 20.;
    }
    CGRect visibleFrame = CGRectMake(0., 0., [UIScreen mainScreen].bounds.size.width, height);
    [self.captureParentView setFrame:visibleFrame];
    [self.captureView setFrame:visibleFrame];
    
    if (!self.captureParentView) {
        self.captureParentView = [[UIView alloc] initWithFrame:visibleFrame];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.captureView)  {
            self.captureView = [[VCCodeScannerView alloc] initWithFrame:visibleFrame];
        }
        [self.captureParentView addSubview:self.captureView];
        self.captureView.delegate = self;
    });
    [self.view addSubview:self.captureParentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self restartScanner];
}

- (void)codeScanViewDidFinishScanning:(NSString *)resultString {
    [self playBeep];
    if (self.completionBlock) {
        (self.completionBlock)(resultString);
    }
}

- (void)playBeep {
    SystemSoundID mBeep;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL* url = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &mBeep);
        AudioServicesPlaySystemSound(mBeep);
        [NSTimer scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
            AudioServicesDisposeSystemSoundID(mBeep);
        } repeats:NO];
    }
}

- (void)restartScanner {
    if (![self.captureView.captureSession isRunning]) {
        [self.captureView.captureSession startRunning];
    }
}

@end
