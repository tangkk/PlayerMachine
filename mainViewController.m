//
//  mainViewController.m
//  PlayerMachine
//
//  Created by tangkk on 19/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "mainViewController.h"
#import "Definition.h"

@interface mainViewController ()
@property (strong, nonatomic) IBOutlet UILabel *WI;
@property (strong, nonatomic) IBOutlet UIButton *JAM;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation mainViewController

@synthesize timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.WI.alpha = 0; self.JAM.alpha = 0;
    [UIView animateWithDuration:2 animations:^{self.WI.alpha = 1; self.JAM.alpha = 1;}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
