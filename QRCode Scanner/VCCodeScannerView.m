//
//  VCCodeScanView.m
//  AVCapture
//
//  Created by Venj Chu on 13-11-11.
//  Copyright (c) 2013年 Venj Chu. All rights reserved.
//

#import "VCCodeScannerView.h"
#import <AVFoundation/AVFoundation.h>
#import <ZBarSDK/ZBarSDK.h>

@interface VCCodeScannerView () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@end

@implementation VCCodeScannerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
        
        AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([videoCaptureDevice lockForConfiguration:&error]) {
            if ([videoCaptureDevice respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)] && videoCaptureDevice.isAutoFocusRangeRestrictionSupported) {
                [videoCaptureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
            }
            if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [videoCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            [videoCaptureDevice unlockForConfiguration];
        }
        else {
            NSLog(@"Could not configure video capture device: %@", error);
        }
        
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
        if (videoInput) {
            [self.captureSession addInput:videoInput];
        }
        else {
            NSLog(@"Could not create video input: %@", error);
        }
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:self.previewLayer];
        
        self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        //dispatch_queue_t queue = dispatch_queue_create("myqueue", NULL);
        dispatch_queue_t queue = dispatch_get_main_queue();
        [self.videoOutput setSampleBufferDelegate:self queue:queue];
        [self.captureSession addOutput:self.videoOutput];
        
        self.videoOutput.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        [self.captureSession startRunning];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewLayer.frame = self.bounds;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([connection isVideoOrientationSupported]) {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        [connection setVideoOrientation:orientation];
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFRetain(imageBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CFRelease(imageBuffer);
    
    ZBarImage *zImage = [[ZBarImage alloc] initWithCGImage:cgImage];
    CFRelease(cgImage);
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology:0 config:ZBAR_CFG_X_DENSITY to:2];
    [scanner setSymbology:0 config:ZBAR_CFG_Y_DENSITY to:2];
    [scanner scanImage:zImage];
    
    ZBarSymbol *sym = nil;
    ZBarSymbolSet *results = scanner.results;
    results.filterSymbols = YES;
    for(ZBarSymbol *s in results) {
        if(!sym || sym.quality < s.quality) {
            sym = s;
        }
    }
    
    if (sym.data != nil && [self.delegate respondsToSelector:@selector(codeScanViewDidFinishScanning:)]) {
        [self.captureSession stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate codeScanViewDidFinishScanning:sym.data];
        });
    }
}

@end
