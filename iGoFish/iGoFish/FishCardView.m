//
//  FishDisplayCard.m
//  Spike_CollectionView
//
//  Created by Greg Tarsa on 2/1/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "FishCardView.h"

@implementation FishCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize imageSize = self.cardImageView.image.size;
        
        self.cardImageView = [UIImageView new];
        self.cardImageView.frame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        [self.contentView addSubview:self.cardImageView];
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
