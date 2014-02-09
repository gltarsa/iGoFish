//
//  FishPondView.m
//  iGoFish
//
//  Created by Greg Tarsa on 2/5/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "PondView.h"

@implementation PondView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
