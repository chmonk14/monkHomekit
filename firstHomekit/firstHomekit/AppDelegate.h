//
//  AppDelegate.h
//  firstHomekit
//
//  Created by Project on 10/17/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HomeKit/HomeKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, HMHomeManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HMHomeManager *homeManager;

@end

