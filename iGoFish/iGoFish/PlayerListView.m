//
//  PlayerListView.m
//  iGoFish
//
//  Created by Greg Tarsa on 2/7/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "PlayerListView.h"

@implementation PlayerListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor brownColor];
        // this forces the face to be redrawn whenever bounds change, like when display is rotated.
        self.layer.needsDisplayOnBoundsChange = YES;
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
