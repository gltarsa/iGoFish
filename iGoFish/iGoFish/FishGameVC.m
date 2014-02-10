//
//  FishGameViewController.m
//  iGoFish
//
//  Created by Greg Tarsa on 1/31/14.
//  Copyright (c) 2014 Greg Tarsa. All rights reserved.
//

#import "FishGameVC.h"
#import "FishCardCell.h"
#import "GoFishModel.h"
#import "FishHand.h"
#import "PondView.h"
#import "PlayerListView.h"
#import "StatusView.h"

@interface FishGameVC ()

@property (nonatomic, strong) FishGame *game;
@property (nonatomic, strong) NSMutableArray *displayCards;

@property (nonatomic, strong) UICollectionView *handView;
@property (nonatomic, strong) UICollectionViewFlowLayout *handViewLayout;
@property (nonatomic, strong) PondView *pondView;
@property (nonatomic, strong) PlayerListView *playerListView;
@property (nonatomic, strong) StatusView *statusView;

@property (nonatomic, strong) NSMutableDictionary *playerButtonMap;

@end

@implementation FishGameVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    [self initializeGame];
    
    self.handView = [self createAndAttachHandView];
    self.pondView = [self createAndAttachPondView];
    self.playerListView = [self createAndAttachPlayerListView];
    self.statusView = [self createAndAttachStatusView];
    
    NSDictionary *viewList = NSDictionaryOfVariableBindings(_handView,
                                                            _pondView,
                                                            _playerListView,
                                                            _statusView);

    CGSize refCardSize = [self refCardSize];
    NSDictionary *metricList = @{@"handHeight": @(refCardSize.height * 1.3),
                                 @"pondHeight": @(refCardSize.height * .75),
                                 @"pondWidth" : @(refCardSize.width  * .75),
                                 @"playerHeight": @(refCardSize.height * 1.05)
                                 };
    

    // Thewse show all four views, but playerList tap is not working and pond/playerList should be in the same horiontal row
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_handView(handHeight)]-[_pondView(pondHeight)]-[_statusView]" options:0 metrics:metricList views:viewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_handView(handHeight)]-[_playerListView]|" options:0 metrics:metricList views:viewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_handView]|" options:0 metrics:metricList views:viewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_statusView]|" options:0 metrics:metricList views:viewList]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pondView(pondWidth)]-[_playerListView]|" options:0 metrics:metricList views:viewList]];
    
/* These constraints allow all four views to display.  Pond and Player views are not in the same row, however.
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_handView]|" options:0 metrics:metricList views:mapViewList]];
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_statusView]|" options:0 metrics:metricList views:mapViewList]];
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_handView(handHeight)]-[_playerListView(playerHeight)]-[_pondView(pondHeight)]-[_statusView(playerHeight)]" options:0 metrics:metricList views:mapViewList]];
*/


    NSLog(@"Constraints: %@", self.view.constraints);
    NSLog (@"\n----------\nmapViewList\n");
    for (NSDictionary *key in viewList)
        NSLog(@"%@ = %@", key, [viewList objectForKey:key]);
    NSLog (@"\n----------\nmetricList\n");
    for (NSDictionary *key in metricList)
        NSLog(@"%@ = %@", key, [metricList objectForKey:key]);
}


- (UICollectionView *)createAndAttachHandView
{
    // Create a a flow layout sized from a representative card image size
    CGSize cardSize = [self refCardSize];
    self.handViewLayout = [UICollectionViewFlowLayout new];
    self.handViewLayout.itemSize = cardSize;
    
    // Create a Collection view with a default layout and flow.
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.handViewLayout];
    
    // register this VC to be the data source
    view.dataSource = self;
    view.delegate = self;
    [view registerClass:[FishCardCell class] forCellWithReuseIdentifier:@"hand"];
    view.backgroundColor= [UIColor darkGrayColor];


    // set inter-item spacing to overlap cards
    [self makeCardsOverlap];
    
    // Add a pinch gesture recognizer to the hand view
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handWasPinched:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    //    [view addGestureRecognizer:pinchRecognizer];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: view];
    return view;
}

- (PondView *)createAndAttachPondView {

    PondView *view = [[PondView alloc] initWithImage:[self buildRefCard]];
    view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pondWasTapped:)];
    [view addGestureRecognizer:tapRecognizer];
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:view];
    return view;
}


- (StatusView *)createAndAttachStatusView {
    
    StatusView *view = [StatusView new];
    view.frame = (CGRect) {0, 0, self.view.frame.size.width, 250};
    
    UILabel *label = [UILabel new];
    label.frame = (CGRect) {0, 0, self.view.frame.size.width, 20};
    label.backgroundColor = [UIColor yellowColor];
    label.text = @"(Messages in the window below are scrollable)";
    [view addSubview:label];

    UITextView *text = [UITextView new];
    text.editable = NO;
    text.backgroundColor = [UIColor orangeColor];
    text.textColor = [UIColor blackColor];
    text.frame = (CGRect) {0, 25, view.frame.size.width, view.frame.size.height};
    text.text = [[self.game.currentPlayer messages:YES] componentsJoinedByString:@"\n-----"];
    text.font = [UIFont systemFontOfSize:20];
    [view addSubview:text];
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:text];
    [self.view addSubview:view];
    
    return view;
}

- (PlayerListView *)createAndAttachPlayerListView {

    PlayerListView *playerList = [PlayerListView new];
    
    // pick some random cards.  Limiting to 2 players or we need to increase this array
    NSArray *pictures = @[[FishCard newWithRank:@"j" suit:@"r"],
                          [FishCard newWithRank:@"j" suit:@"b"] ];

    // build player-button mapping array
    self.playerButtonMap = [NSMutableDictionary new];

    int index = 0;
    for (FishPlayer *player in self.game.players) {
        if ([player isEqual:self.game.currentPlayer])
            continue;
        UIButton *button = [UIButton new];
        button.frame = (CGRect) {0, index * 80, self.view.frame.size.width - 200, 75};
        [button setImage:[self buildCardImage:pictures[index]] forState:UIControlStateNormal];
        NSString *info = [NSString stringWithFormat:@"%@) %@: Cards: %@ Books: %@",
                          player.number, player.name,
                          [player.hand numberOfCards], [self.game booksDescription:player]];
        [button setTitle:info forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self action:@selector(playerWasTapped:) forControlEvents:UIControlEventTouchDown];
        [playerList addSubview:button];
        
        [self.playerButtonMap setObject:button forKey:player];
        index++;
    }
    playerList.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:playerList];
    return playerList;
}


- (void)initializeGame {
    self.game = [FishGame new];
    
    [self.game addPlayer:@1 name:@"Greg"];
    [self.game addPlayer:@2 name:@"Robo-1"];
    [self.game addPlayer:@3 name:@"Robo-2"];
    
    [self.game startGame];
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
    if (tapInfo.state == UIGestureRecognizerStateRecognized){
        [self.game.currentPlayer.hand receiveCard:[self.game.pond giveCard]];
        [self.game.currentPlayer.hand sort];
        [self.handView reloadData];
        NSLog(@"Tap was recognized: card added to hand from pond");
    }
    else {
        NSLog(@"Tap was aborted (state = %d)", tapInfo.state);
    }
}

- (void) playerWasTapped:(id)sender {
    FishPlayer *player = [[self.playerButtonMap allKeysForObject:sender] objectAtIndex:0];
    
    
    NSLog(@"Player was tapped.  Sender was %@", sender);
    NSLog(@"This is player %@) %@", player.number, player.name);
}



- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.game.currentPlayer.hand numberOfCards] integerValue];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"collectionView: Card %@ at indexPath %@ was selected.",
          self.game.currentPlayer.hand.cards[indexPath.row],
          indexPath);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FishCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hand" forIndexPath:indexPath];
    
    // get the image for this card
    cell.imageView.image = [self buildCardImage:self.game.currentPlayer.hand.cards[indexPath.row]];
    
    // set the image frame to be the same size as the image
    CGSize imageSize = cell.imageView.image.size;
    cell.imageView.frame = (CGRect) {0.0, 0.0, imageSize.width, imageSize.height};

    cell.backgroundColor = [UIColor greenColor];
    
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
