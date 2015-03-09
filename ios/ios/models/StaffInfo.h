//
//  StaffInfo.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaffInfo : NSObject

@property double centerLineSlope;
@property double centerLineIntercept;
@property int lineWidth;
@property int lineSpace;

- (id)initWithSlope:(double)slope Intercept:(double)intercept LineWidth:(int)width LineSpace:(int)space;
- (void)info;

@end
