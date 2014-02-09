//
//  StatusView.m
//  iGoFish
//
//  Created by Greg Tarsa on 2/8/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        self.layer.needsDisplayOnBoundsChange = YES; // force view to redraw when screen is rotated
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
