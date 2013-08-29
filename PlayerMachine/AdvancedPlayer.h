//
//  AdvancedPlayer.h
//  PlayerMachine
//
//  Created by tangkk on 17/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteNumDict.h"
#import "Communicator.h"

@interface AdvancedPlayer : UIViewController <UIGestureRecognizerDelegate>

// Communication infrastructures
@property (strong, nonatomic) Communicator *CMU;

@property (assign) UInt8 *playerChannel;
@property (assign) UInt8 *playerID;
@property (assign) BOOL *playerEnabled;

- (void) feebackAnimatewithString:(NSString *)feedback;

@end
