//
//  FIshCardView.m
//  iGoFish
//
//  Created by Greg Tarsa on 2/1/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "FishCardCell.h"

@implementation FishCardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
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
