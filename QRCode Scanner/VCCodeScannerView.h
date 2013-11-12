//
//  VCCodeScanView.h
//  AVCapture
//
//  Created by Venj Chu on 13-11-11.
//  Copyright (c) 2013年 Venj Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCCodeScanViewDelegate <NSObject>
@optional
- (void)codeScanViewDidFinishScanning:(NSString *)resultString;
@end

@class AVCaptureSession;
@interface VCCodeScannerView : UIView
@property (nonatomic, weak) id<VCCodeScanViewDelegate>delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@end
