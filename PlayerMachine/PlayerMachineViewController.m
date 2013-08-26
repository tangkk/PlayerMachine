//
//  PlayerMachineViewController.m
//  PlayerMachine
//
//  Created by tangkk on 14/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "PlayerMachineViewController.h"
#import "Definition.h"
#import "Drawing.h"

@interface PlayerMachineViewController () {
    // Animation
    CGFloat mouseXReg[AnimateArrayLength];
    CGFloat mouseYReg[AnimateArrayLength];
    UInt16 tick[AnimateArrayLength];
    BOOL animate[AnimateArrayLength];
    
    // notePosition
    UInt16 notePos;
    UInt16 notePosReg[AnimateArrayLength];
    
    // the size parameter of the screen
    CGFloat width;
    CGFloat height;
    
    // UIBezierPath
    UIBezierPath *path;
    CGPoint PPoint;
    
    // Trace Stationary Point
    CGFloat yReg[RegLength];
    BOOL RegValid;
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    UInt16 length;
    BOOL mouseSwiped;
    
    BOOL longPressed;
    
    UInt16 counter;
}

@property (strong, nonatomic) IBOutlet UIImageView *mainImage;
@property (strong, nonatomic) IBOutlet UILabel *textLocation;
@property (strong, nonatomic) IBOutlet UIImageView *instImage;
@property (strong, nonatomic) IBOutlet UIButton *IMAdvanced;
@property (strong, nonatomic) IBOutlet UIButton *QUIT;

@property (nonatomic, retain) NSTimer *draw;

// The objects used during segue
@property (nonatomic, retain) NSTimer *makeSureConnected;
@property (strong, nonatomic) IBOutlet UILabel *masterConnectedLabel;


@end

@implementation PlayerMachineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    brush = 1.0;
    opacity = 1.0;
    length = 0;
    notePos = 0;
    width = self.view.frame.size.width;
    height = self.view.frame.size.height;
    _draw = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(processingDraw) userInfo:nil repeats:YES];
    [self.mainImage setAlpha:opacity];
    
    [self clearAnimationArrays];
    [self clearStationCheckReg];
    
    // Show instruction image
    self.instImage.image = [UIImage imageNamed:@"Draw2Play.png"];
    self.instImage.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.IMAdvanced.alpha = 0;
    self.QUIT.alpha = 0;
    
    path = [UIBezierPath bezierPath];
    
    longPressed = false;
}

- (void) viewWillAppear:(BOOL)animated {
    self.instImage.alpha = 1;
    self.masterConnectedLabel.alpha = 0;
    [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionTransitionCurlUp animations:^{self.instImage.alpha = 0;} completion:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    // Initialize objects during segue
    _makeSureConnected = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkIfConnected) userInfo:nil repeats:YES];
    counter = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Make Sure Process After Segue
- (void)checkIfConnected {
    if (counter++ > 3) {
        counter = 0;
        [_makeSureConnected invalidate];
        if (*_masterConnected) {
            [UIView animateWithDuration:1 animations:^{self.masterConnectedLabel.alpha = 1;}];
            [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionTransitionCurlUp animations:^{self.masterConnectedLabel.alpha = 0;} completion:NO];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Drawing

static CGPoint midPoint(CGPoint p0, CGPoint p1) {
    return CGPointMake((p0.x + p1.x)/2, (p0.y + p1.y)/2);
}

// mousePressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (longPressed) {
        longPressed = false;
        [UIView animateWithDuration:1 animations:^{self.IMAdvanced.alpha = 0.0;}];
        [UIView animateWithDuration:1 animations:^{self.QUIT.alpha = 0.0;}];
    }
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:lastPoint];
    
    // Play the note, which is determined by the y position and how many notes are within the screen size
    notePos = lastPoint.y * noteSize / height;
    DSLog(@"notePos = %d", notePos);
    [self playNoteinPos:notePos];
    
    [self tracePressedwithPos:lastPoint.x and:lastPoint.y notePos:notePos];
}

// mouseDragged
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    DSLog(@"length = %d", length);
    if (length ++ == 10) {
        length = 0;
        path = [UIBezierPath bezierPath];
        [path moveToPoint:lastPoint];
    }
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    mouseSwiped = YES;
    
    // Change color according to pos
//    red = currentPoint.x / self.view.frame.size.width;
//    green = currentPoint.y / self.view.frame.size.height;
//    blue = 1;
//    [Drawing drawLineWithPreviousPoint:lastPoint CurrentPoint:currentPoint onImage:self.mainImage withbrush:brush Red:red Green:green Blue:blue Alpha:opacity Size:self.view.frame.size];
    
    CGPoint middlePoint = midPoint(lastPoint, currentPoint);
    [path addQuadCurveToPoint:middlePoint controlPoint:lastPoint];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    [[UIColor whiteColor] setStroke];
    [path setLineWidth:brush];
    [path stroke];
    CGContextAddPath(UIGraphicsGetCurrentContext(), path.CGPath);
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
    // Trace Stationary Point
    [self traceStationarywithPos:currentPoint.y];
    if (RegValid) {
        if ([self isStationary]) {
            RegValid = NO;
            notePos = lastPoint.y * noteSize / height;
            [self playNoteinPos:notePos];
            
            [self tracePressedwithPos:currentPoint.x and:currentPoint.y notePos:notePos];
        }
    }
}

// mouseReleased
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - note Play
- (void)playNoteinPos:(UInt16)Pos {
    
}

#pragma mark - Timer Triggered Function

- (void)processingDraw {
    //Do the waterwave animation
    [self doAnimation];
}

#pragma mark - TraceStationaryPoint
- (BOOL) isStationary{
    //Check the non-stationary condition, if true return false, else, return true
    BOOL ret = true;
    for (int i = 1; i < RegLength; i++) {
        if (yReg[i-1] >= yReg[i]) {
            ret &= true;
        } else {
            ret &= false;
            break;
        }
    }
    // if non-station, return false
    if (ret)
        return false;
    
    ret = true;
    for (int i = 1; i < RegLength; i++) {
        if (yReg[i-1] <= yReg[i]) {
            ret &= true;
        } else {
            ret &= false;
            break;
        }
    }
    // if non-station, return false
    if (ret)
        return false;
    
    // else return true
    return true;
}

- (void) clearStationCheckReg {
    for (int i = 0 ; i < RegLength; i++) {
        yReg[i] = 0;
    }
}

- (void) traceStationarywithPos:(CGFloat)y {
    for (int i = 1; i < RegLength; i++) {
        yReg[i-1] = yReg[i];
    }
    yReg[RegLength - 1] = y;
    if (yReg[0] > 0)
        RegValid = YES;
    else
        RegValid = NO;
}

#pragma mark - Animation
// This is a result of my processing simulation
- (void) doAnimation {
    // do some fading effect
    [self fading];
    
    // do water effect
    for (int i = 0; i < AnimateArrayLength; i++) {
        // Change color according to pos
//        red = mouseXReg[i] / self.view.frame.size.width;
//        green = mouseYReg[i] / self.view.frame.size.height;
//        blue = 1;

        if (animate[i]) {
            tick[i]++;
            if (tick[i] > 45) {
                tick[i] = 0;
                animate[i] = false;
            }
            if (tick[i] > 30 && tick[i] <=45) {
                [Drawing drawCircleWithCenter:CGPointMake(mouseXReg[i], mouseYReg[i]) Radius:2*(notePosReg[i]+2) onImage:self.mainImage withbrush:brush Red:red Green:green Blue:blue Alpha:opacity Size:self.view.frame.size];
            }
            if (tick[i] > 15 && tick[i] <= 30) {
                [Drawing drawCircleWithCenter:CGPointMake(mouseXReg[i], mouseYReg[i]) Radius:1.5*(notePosReg[i]+2) onImage:self.mainImage withbrush:brush Red:red Green:green Blue:blue Alpha:opacity Size:self.view.frame.size];
            }
            if (tick[i] > 1 && tick[i] <= 15) {
                [Drawing drawCircleWithCenter:CGPointMake(mouseXReg[i], mouseYReg[i]) Radius:(notePosReg[i]+2) onImage:self.mainImage withbrush:brush Red:red Green:green Blue:blue Alpha:opacity Size:self.view.frame.size];
            }
        }
    }
}

- (void) fading {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 0.1);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) tracePressedwithPos:(CGFloat)x and:(CGFloat)y notePos:(UInt16)Pos {
    for (int i = 1; i < AnimateArrayLength; i++) {
        mouseXReg[i-1] = mouseXReg[i];
        mouseYReg[i-1] = mouseYReg[i];
        tick[i-1] = tick[i];
        animate[i-1] = animate[i];
        notePosReg[i - 1] = notePosReg[i];
    }
    mouseXReg[AnimateArrayLength - 1] = x;
    mouseYReg[AnimateArrayLength - 1] = y;
    tick[AnimateArrayLength - 1] = 0;
    animate[AnimateArrayLength - 1] = YES;
    notePosReg[AnimateArrayLength - 1] = Pos;
    
    [self clearStationCheckReg];
}

- (void) clearAnimationArrays {
    for (int i = 0; i < AnimateArrayLength; i++) {
        mouseXReg[i] = 0;
        mouseYReg[i] = 0;
        tick[i] = 0;
        animate[i] = NO;
        notePosReg[i] = 0;
    }
}

#pragma mark - Tap Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (IBAction)LongPressed:(id)sender {
    DSLog(@"LongPressed");
    [UIView animateWithDuration:1 animations:^{self.IMAdvanced.alpha = 1;}];
    [UIView animateWithDuration:1 animations:^{self.QUIT.alpha = 1;}];
    longPressed = true;

}
- (IBAction)QUIT:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIView animateWithDuration:1 animations:^{self.IMAdvanced.alpha = 0;}];
    [UIView animateWithDuration:1 animations:^{self.QUIT.alpha = 0;}];
}

- (IBAction)GotoAdvanced:(id)sender {
    [UIView animateWithDuration:1 animations:^{self.IMAdvanced.alpha = 0;}];
    [UIView animateWithDuration:1 animations:^{self.QUIT.alpha = 0;}];
}


@end
