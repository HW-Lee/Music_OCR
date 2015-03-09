//
//  CustomizeTableView.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "CustomizeTableView.h"

@implementation CustomizeTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setFrame:(CGRect)frame {
    float inset = frame.origin.x;
    frame.origin.x += inset;
    frame.size.width -= 2*inset;
    [super setFrame:frame];
}

@end
