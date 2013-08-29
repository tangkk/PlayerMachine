//
//  PlayerMachineViewController.h
//  PlayerMachine
//
//  Created by tangkk on 14/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "Communicator.h"

@interface PlayerMachineViewController : UIViewController <UIGestureRecognizerDelegate, MIDIAssignmentHandle>

// The objects used during segue
@property BOOL *masterConnected;

@end
