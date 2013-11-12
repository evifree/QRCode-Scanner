//
//  ViewController.h
//  AVCapture
//
//  Created by Venj Chu on 13-11-11.
//  Copyright (c) 2013年 Venj Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VCCodeScannerCompletionBlock)(NSString *);

@interface VCCodeScannerViewController : UIViewController
@property (nonatomic, strong) VCCodeScannerCompletionBlock completionBlock;
- (void)restartScanner;
@end
