//
//  mainViewController.m
//  PlayerMachine
//
//  Created by tangkk on 19/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "mainViewController.h"
#import "Definition.h"

#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"

@interface mainViewController () {
    UInt16 counter;
    BOOL detectConnectedDeviceEnable;
    BOOL masterConnected;
}
@property (strong, nonatomic) IBOutlet UILabel *WI;
@property (strong, nonatomic) IBOutlet UIButton *JAM;

// Network Service related declaraion
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (readwrite) MIDINetworkSession *Session;
@property (nonatomic, retain) NSTimer *connectTimer;

@property (strong, nonatomic) IBOutlet UILabel *with;
@property (strong, nonatomic) IBOutlet UILabel *masterName;
@property (strong, nonatomic) NSMutableArray *deviceArray;
@property (strong, nonatomic) IBOutlet UIButton *Down;

// master selection declaration
@property (assign, atomic) UInt16 masterIdx;
@property (assign, atomic) UInt16 masterCount;


@end

@implementation mainViewController

- (void)viewWillAppear:(BOOL)animated {
    self.WI.alpha = 0; self.JAM.alpha = 0; self.with.alpha = 0; self.masterName.alpha = 0;  self.Down.alpha = 0;
    [UIView animateWithDuration:2 animations:
     ^{self.WI.alpha = 1; self.JAM.alpha = 1; self.with.alpha = 1; self.masterName.alpha = 1;  self.Down.alpha = 1;}];
}

- (void)viewDidAppear:(BOOL)animated {
    _masterCount = 0;
    _masterIdx = 0;
    _deviceArray = [NSMutableArray arrayWithObjects:@"...", nil];
    _masterName.text = [_deviceArray objectAtIndex:_masterIdx];
    [self removeAllConnections];
    
    [self configureNetworkSessionAndServiceBrowser];
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanServices) userInfo:nil repeats:YES];
    counter = 0;
    detectConnectedDeviceEnable = false;
    masterConnected = false;
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

#pragma mark - network Service

- (void) configureNetworkSessionAndServiceBrowser {
    // configure network session
    _Session = [MIDINetworkSession defaultSession];
    _Session.enabled = true;
    _Session.connectionPolicy = MIDINetworkConnectionPolicy_NoOne;
    
    // configure service browser
    if (self.services == nil) {
        self.services = [[NSMutableArray alloc] init];
    }
    if (self.serviceBrowser == nil) {
        self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
        [self.serviceBrowser setDelegate:self];
        // starting scanning for services (won't stop until stop() is called)
        [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Also add self service, but ensure that service with a same name can also be added
    NSLog(@"didFindService..................................");
    [self.services addObject:service];
    
    
    if ([service.name  isEqualToString:_Session.networkName]) {
        NSLog(@"Self Service!");
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService..................................");
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    if (connection) {
        [_Session removeConnection:connection]; // remove connection automatically
    }
    [self.services removeObject:service];
}

- (void) removeAllConnections {
    for (NSNetService *Service in self.services) {
        MIDINetworkHost *Host = [MIDINetworkHost hostWithName:Service.name netService:Service];
        [_Session removeContact:Host];
        MIDINetworkConnection *Con = [MIDINetworkConnection connectionWithHost:Host];
        if (Con) {
            [_Session removeConnection:Con];
        }
    }
}

#pragma mark - master selection

- (void) detectConnectedDevices {
    if (counter++ >2) {
        counter = 0;
        [_connectTimer invalidate];
        [_serviceBrowser stop];
        detectConnectedDeviceEnable = false;
        NSLog(@"Connected to %u devices:", [_Session.connections count]);
        for (MIDINetworkConnection *conn in _Session.connections) {
            NSLog(@"Connected to: %@", conn.host.name);
            NSLog(@"mainViewController ends here");
            masterConnected = true;
        }
        NSLog(@"\n");
    }
}

- (void) scanServices {
    NSLog(@"scanServices...");
    
    if (detectConnectedDeviceEnable) {
        [self detectConnectedDevices];
    }
    
    [_deviceArray removeAllObjects];
    for (NSNetService *Service in self.services) {
        NSLog(@"name: %@", Service.name);
        [_deviceArray addObject:Service.name];
    }
    [_deviceArray addObject:@"..."];
    _masterName.text = [_deviceArray objectAtIndex:_masterIdx];
    _masterCount = _deviceArray.count;
}

- (IBAction)masterDown:(id)sender {
    if (_masterIdx +1 < _masterCount) {
        _masterIdx++;
        _masterName.text = [_deviceArray objectAtIndex:_masterIdx];
    } else {
        _masterIdx = 0;
        _masterName.text = [_deviceArray objectAtIndex:_masterIdx];
    }
}

#pragma mark - Segue functions
- (IBAction)JAM:(id)sender {
    // Select the connection shown in the masterName label
    detectConnectedDeviceEnable = true;
    for (NSNetService *Service in self.services) {
        MIDINetworkHost *host = [MIDINetworkHost hostWithName:Service.name netService:Service];
        if ([host.name isEqualToString:_masterName.text]) {
            NSLog(@"try to connect to: %@", host.name);
            MIDINetworkConnection *conn = [MIDINetworkConnection connectionWithHost:host];
            [_Session addConnection:conn];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PlayerMachineViewController *playerMachineVC = (PlayerMachineViewController *)segue.destinationViewController;
    playerMachineVC.masterConnected = &masterConnected;
}

@end
