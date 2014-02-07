//
//  FishDisplayCard.h
//  Spike_CollectionView
//
//  Created by Greg Tarsa on 2/1/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoFishModel.h"

@interface FishCardView : UICollectionViewCell

@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) FishCard *card;

@end
