//
//  ViewController.m
//  firstHomekit
//
//  Created by Project on 10/17/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import "ViewController.h"
#import <HomeKit/HomeKit.h>

@interface ViewController ()
@property HMHomeManager *homeManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
    
    HMHome *primaryHome = self.homeManager.primaryHome;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHomes:) name:@"UpdateHomesNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrimaryHome:) name:@"UpdatePrimaryHomeNotification"  object:nil];
    
//    [self.homeManager addHomeWithName:@"newbie Home" completionHandler:^(HMHome *home, NSError *error) {
//        if (error != nil) {
//            // Failed to add a home
//            NSLog(@"adding home error : %@", error);
//        } else {
//            // Successfully added a home
//            NSLog(@"adding home success : %@", home);
//            
//        }
//    }];
    
    NSString *roomName = @"Living Room";
    [primaryHome addRoomWithName:roomName completionHandler:^(HMRoom *room, NSError *error) {
        if (error != nil) {
            // Failed to add a room to a home
            NSLog(@"adding room error : %@", error);

        } else {
            // Successfully added a room to a home
            NSLog(@"adding room success : %@", room);

        }
    }];

    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
