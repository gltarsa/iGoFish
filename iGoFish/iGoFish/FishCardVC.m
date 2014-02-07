//
//  DemoCollectionViewController.m
//  Spike_CollectionView
//
//  Created by Greg Tarsa on 1/31/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "FishCardVC.h"
#import "FishCardView.h"
#import "GoFishModel.h"
#import "FishPondView.h"
#import "SmileyFaceView.h"

@interface FishCardVC ()

@property (nonatomic, strong) GoFishModel *game;
@property (nonatomic, strong) NSMutableArray *displayCards;
@property (nonatomic, strong) UICollectionViewFlowLayout *handViewLayout;
//@property (nonatomic, strong) UICollectionViewFlowLayout *pondViewLayout;
@end

@implementation FishCardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void) handWasPinched:(UIPinchGestureRecognizer *)pinchInfo {
    NSLog(@"handWasPinched Called by %@.", pinchInfo);
    
    if (pinchInfo.state == UIGestureRecognizerStateRecognized){
        CGFloat velocity = pinchInfo.velocity;

        if (velocity > 0)
            [self makeCardsSpread];
        else
            [self makeCardsOverlap];
    }
}

- (void) pondWasTapped:(UITapGestureRecognizer *)tapInfo {
    // Ultimately, we may want to have a delegate registered to do the action required by this tap.
    
    NSLog(@"Pond was tapped");
    if (tapInfo.state == UIGestureRecognizerStateRecognized){
        NSLog(@"Tap was recognized");
    }
    else {
        NSLog(@"Tap was aborted (state = %d)", tapInfo.state);
    }
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
	// Create a game and load the hand for display
    [self loadHandIntoDisplay];
    
    UICollectionView *handView;
    handView = [self createAndAttachHandView];
    
    UIImageView *pondView;
    pondView = [self createAndAttachPondView];
    
    SmileyFaceView *smiley;
    smiley = [self createAndAttachSmileyView];
    
    //    Auto Layout for Hand and Smiley Face views
    handView.translatesAutoresizingMaskIntoConstraints = NO;
    smiley.translatesAutoresizingMaskIntoConstraints = NO;
    pondView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *mapViewList = @{@"handView": handView,
                                  @"pondView": pondView,
                                  @"smiley": smiley
                                  };
    CGSize refCardSize = [self refCardSize];
    NSDictionary *metricList = @{@"pondHeight": @(refCardSize.height * 1.1),
                                 @"handHeight": @(refCardSize.height * 2.1),
                                 @"pondWidth" : @(refCardSize.width)
                                 };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[handView(handHeight)]-[pondView(pondHeight)]"
                                                                      options:0 metrics:metricList views:mapViewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[handView]-[smiley]|"
                                                                      options:0 metrics:metricList views:mapViewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[handView]|"
                                                                      options:0 metrics: metricList views:mapViewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[pondView(pondWidth)]-[smiley]|"
                                                                      options:0 metrics: metricList views:mapViewList]];
    
    NSLog(@"Constraints: %@", self.view.constraints);
}

- (UICollectionView *)createAndAttachHandView
{
    /*
     First view Code
     */
    // Create a a flow layout sized from a representative card image size
    CGSize cardSize = [self refCardSize];
    self.handViewLayout = [UICollectionViewFlowLayout new];
    self.handViewLayout.itemSize = cardSize;
    
    // Create a Collection view with a default layout and flow.
    UICollectionView *handView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.handViewLayout];
    
    // register this VC to be the data source
    handView.dataSource = self;
    handView.delegate = self;
    [handView registerClass:[FishCardView class] forCellWithReuseIdentifier:@"tbd"];
    handView.backgroundColor= [UIColor darkGrayColor];
    [self.view addSubview: handView];
    
    // set inter-item spacing to overlap cards
    [self makeCardsOverlap];
    
    // Add a pinch gesture recognizer
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handWasPinched:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    return handView;
}

- (UIImageView *)createAndAttachPondView {
    UIImageView *pondView = [[UIImageView alloc] initWithImage:[self buildRefCard]];
    pondView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pondWasTapped:)];
    [pondView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:pondView];

    return pondView;
}

- (SmileyFaceView *)createAndAttachSmileyView {
    // Add a second view to this controller
    SmileyFaceView *smiley = [SmileyFaceView new];
    [self.view addSubview:smiley];
//    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/12);
//    [smiley setTransform:transform];
    return smiley;
}


- (void)loadHandIntoDisplay {
    self.displayCards = [NSMutableArray new];
    self.game = [GoFishModel new];
    self.game.pond = [FishDeck newWithCards];
    [self.game.pond shuffle];
    self.game.hand = [FishHand new];

    // create a hand
    for (NSInteger i = 0; i < 7; i++) {
        FishCard *card = [self.game.pond giveCard];
        [self.game.hand receiveCard:card];
        
        FishCardView *displayCard = [FishCardView new];

        displayCard.card = card;
        [self.displayCards addObject:displayCard];
    }
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.displayCards count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FishCardView *displayCard = self.displayCards[indexPath.row];
    
    NSLog(@"collectionView: didSelectItemAtIndexPath: %@.", indexPath);
    
    NSLog(@"Card: %@ was selected.", displayCard.card);

}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FishCardView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tbd" forIndexPath:indexPath];
    
    FishCardView *displayItem = self.displayCards[indexPath.row];

    cell.card = displayItem.card;
    cell.cardImageView.image = [self buildCardImage:displayItem.card];
    
    CGSize imageSize = cell.cardImageView.image.size;
    cell.cardImageView.frame = (CGRect) {0.0, 0.0, imageSize.width, imageSize.height};

    cell.backgroundColor = [UIColor greenColor];

   
   
    //    cell.contentView.transform =co
//    UICollectionViewLayoutAttributes *layout = [UICollectionViewLayoutAttributes]
    
    return cell;
}

- (BOOL) isFancy {
    return YES;
}

- (UIImage *)buildCardImage:(FishCard *)card {
    NSString *name;
    
    if ([self isFancy])
        name =[card FancyFileBaseName];
    else
        name =[card BasicFileBaseName];
    
    return [UIImage imageNamed:name];
}

- (CGSize)refCardSize {
    UIImage *refCard = [self buildRefCard];
    return refCard.size;
}

- (UIImage *)buildRefCard {
    NSString *refName, *typeName;
    NSNumber *subtypeNumber = @2;  // Type 2 is typically
    
    if ([self isFancy])
        typeName = @"fancy";
    else
        typeName = @"basic";
    
    refName = [NSString stringWithFormat:@"_%@backs%@", typeName, subtypeNumber];
    UIImage *refCard = [self buildCardImage:[FishCard newWithRank:refName suit:@""]];
    
    return refCard;
  
}

- (void)setCardsOverlapFactor:(CGFloat)factor {
    CGSize cardSize = [self refCardSize];
    self.handViewLayout.minimumInteritemSpacing = factor * cardSize.width;
}

- (void)makeCardsOverlap {
    [self setCardsOverlapFactor:-0.50];
}

- (void)makeCardsSpread {
    [self setCardsOverlapFactor: +0.1];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
