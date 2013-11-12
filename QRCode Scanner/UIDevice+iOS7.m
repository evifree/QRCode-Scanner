//
//  UIDevice_iOS7.m
//  Procedure Logger
//
//  Created by Venj Chu on 13-11-11.
//  Copyright (c) 2013年 Venj Chu. All rights reserved.
//

#import "UIDevice+iOS7.h"

@implementation UIDevice (iOS7)

- (NSUInteger)deviceSystemMajorVersion {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[self systemVersion] componentsSeparatedByString:@"."][0] intValue];
    });
    return _deviceSystemMajorVersion;
}

@end