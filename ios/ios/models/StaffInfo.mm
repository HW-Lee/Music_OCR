//
//  StaffInfo.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "StaffInfo.h"

@implementation StaffInfo

- (id)initWithSlope:(double)slope Intercept:(double)intercept LineWidth:(int)width LineSpace:(int)space {
    self = [super init];
    if (self) {
        [self setCenterLineSlope:slope];
        [self setCenterLineIntercept:intercept];
        [self setLineWidth:width];
        [self setLineSpace:space];
    }
    return self;
}

- (void)info {
    NSLog(@"Slope    : %.4f", [self centerLineSlope]);
    NSLog(@"Intercept: %.4f", [self centerLineIntercept]);
    NSLog(@"LineWidth: %d", [self lineWidth]);
    NSLog(@"LineSpace: %d", [self lineSpace]);
}

@end
