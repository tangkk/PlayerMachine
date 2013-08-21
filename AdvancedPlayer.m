//
//  AdvancedPlayer.m
//  PlayerMachine
//
//  Created by tangkk on 17/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "AdvancedPlayer.h"
#import "Definition.h"
#import "Drawing.h"

@interface AdvancedPlayer ()  {
    BOOL longPressed;
    
    UInt16 Brush;
    CGFloat Red;
    CGFloat Green;
    CGFloat Blue;
    CGFloat Opacity;
    
    CGFloat width;
    CGFloat height;
    CGFloat gridWidth;
    CGFloat gridHeight;
    UInt16 GridIdx;
    
    UIButton *keys[36];
}

@property (strong, nonatomic) IBOutlet UIButton *SimpleButton;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

@property (nonatomic, retain) NSTimer *draw;

@end

@implementation AdvancedPlayer

@synthesize draw;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Variables initialize
    longPressed = false;
    Brush = 2;
    Red = 1;
    Green = 1;
    Blue = 1;
    Opacity = 1;
    width = self.view.frame.size.width;
    height = self.view.frame.size.height;
    gridWidth = width / GridSize;
    gridHeight = height / GridSize;
    GridIdx = 0;
    
    self.SimpleButton.alpha = 0;
    
    [self placeButtons];
    // Draw a grid
    draw = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(drawGrid) userInfo:nil repeats:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Drawing

- (void) drawGrid {
    // Draw a 6 by 6 Grid
    [Drawing drawLineWithPreviousPoint:CGPointMake(gridWidth*GridIdx, 0) CurrentPoint:CGPointMake(gridWidth*GridIdx, height) onImage:self.mainImage withbrush:Brush Red:Red Green:Green Blue:Blue Alpha:Opacity Size:self.view.frame.size];
    [Drawing drawLineWithPreviousPoint:CGPointMake(0, gridHeight*GridIdx) CurrentPoint:CGPointMake(width, gridHeight*GridIdx) onImage:self.mainImage withbrush:Brush Red:Red Green:Green Blue:Blue Alpha:Opacity Size:self.view.frame.size];
    if(GridIdx++ == 6) {
        [draw invalidate];
        GridIdx = 0;
    }
}

- (void) placeLabels {
    for (int i = 0; i < GridSize; i++) {
        for (int j = 0 ; j < GridSize; j++) {
            CGRect Frame = CGRectMake(i*gridWidth, j*gridHeight, gridWidth , gridHeight);
            UILabel *Label = [[UILabel alloc] initWithFrame:Frame];
            Label.center = CGPointMake(i*gridWidth + LabelMargin + gridWidth/2, j*gridHeight + gridHeight/2);
            Label.backgroundColor = [UIColor blackColor];
            Label.textColor = [UIColor whiteColor];
            Label.text = [NSString stringWithFormat:@"%d, %d", i, j];
            Label.font = [UIFont fontWithName:@"Trebuchet MS" size:18];
            Label.tag = i*GridSize + j;
            [self.view addSubview:Label];
            
            // send it to back so as not to cover all other things
            [self.view sendSubviewToBack:Label];
        }
    }
}

- (void) placeButtons {
    for (int i = 0; i < GridSize; i++) {
        for (int j = 0 ; j < GridSize; j++) {
            UIButton *thisButton = keys[i*GridSize + j];
            thisButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [thisButton setTitle:[NSString stringWithFormat:@"%d, %d", i, j] forState:UIControlStateNormal];
            thisButton.titleLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:18];
            thisButton.frame = CGRectMake(i*gridWidth, j*gridHeight, gridWidth , gridHeight);
            [thisButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            thisButton.showsTouchWhenHighlighted = true;
            thisButton.tag = i*GridSize + j;
            [thisButton addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
            [thisButton addTarget:self action:@selector(keyUpPressed:) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:thisButton];
            [self.view sendSubviewToBack:thisButton];
        }
    }
}

#pragma mark - Playing
// mousePressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (longPressed) {
        longPressed = false;
        [UIView animateWithDuration:1 animations:^{self.SimpleButton.alpha = 0.0;}];
    }
    
    UITouch *touch = [touches anyObject];
    // deal with which part of the grid has been tapped
    CGPoint point= [touch locationInView:self.view];
    UInt16 xPos = floorf(point.x / gridWidth);
    UInt16 yPos = floorf(point.y / gridHeight);
    DSLog(@"xPos: %d, yPos: %d", xPos, yPos);
    [self playAtxPos:xPos yPos:yPos];
}

- (void)keyPressed:(id)sender {
    UIButton *thisButton = (UIButton *)sender;
    NSInteger tag = thisButton.tag;
    DSLog(@"keyPressed with button Tag: %d", tag);
    [self playAtTag:tag];
}

- (void)keyUpPressed:(id)sender {
    // Dismiss the simple mode selector
    if (longPressed) {
        longPressed = false;
        [UIView animateWithDuration:1 animations:^{self.SimpleButton.alpha = 0.0;}];
    }
}

- (void)playAtTag:(NSInteger)tag {
    
}

- (void)playAtxPos:(UInt16)xPos yPos:(UInt16)yPos {
    
}

#pragma mark - dismiss Advanced Player

- (IBAction)backToSimple:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIView animateWithDuration:1 animations:^{self.SimpleButton.alpha =0;}];
}

#pragma mark - Gesture Recognizer

- (IBAction)LongPressed:(id)sender {
    DSLog(@"LongPressed");
    longPressed = true;
    [UIView animateWithDuration:1 animations:^{self.SimpleButton.alpha = 1;}];
}

@end
