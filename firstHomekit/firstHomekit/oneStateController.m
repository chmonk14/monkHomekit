//
//  oneStateController.m
//  firstHomekit
//
//  Created by Project on 10/19/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import "oneStateController.h"

@interface oneStateController () <HMAccessoryDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishTempLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@property (weak, nonatomic) IBOutlet UISwitch *triggleSwitch;

@property HMCharacteristic *oncCharacter;
@property HMCharacteristic *temperature;
@property Boolean softState;

@end

@implementation oneStateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"services: %@", self.accessory.services);

    self.titleLabel.text = self.accessory.name;
    self.accessory.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated{
    [self checkStatus];

}

- (void) checkStatus{
    NSArray *services = self.accessory.services;
    
    for (HMService *service in services) {
        
        for (HMCharacteristic *character in service.characteristics) {
            [character readValueWithCompletionHandler:^(NSError *error) {
                
                if (error == nil) {
                    // Successfully read the value
                    id value = character.value;
                    NSLog(@"%@ is %@", character.metadata.manufacturerDescription, value);
                    
                    if([character.metadata.manufacturerDescription isEqualToString:@"Power State"]){
                        self.oncCharacter = character;
                        self.softState = [value boolValue] ;
                        [self.triggleSwitch setOn:self.softState];
                        NSLog(@"softState : %d, switchState : %ld", self.softState,self.triggleSwitch.state);
                        
                    }else if ([character.metadata.manufacturerDescription isEqualToString:@"Current Temperature"]){
                        
                        CGFloat roundedTemp = [value floatValue] < 0.5f ? 0.5f : floorf([value floatValue] * 2) / 2;
                        self.statusLabel.text = [NSString stringWithFormat:@"Current Temperature %.1f °C", roundedTemp];
                        
                    }else if ([character.metadata.manufacturerDescription isEqualToString:@"Target Temperature"]){
                        
                        CGFloat roundedTemp = [value floatValue] < 0.5f ? 0.5f : floorf([value floatValue] * 2) / 2;
                        self.temperature = character;
                        self.wishTempLabel.text = [NSString stringWithFormat:@"%.1f", roundedTemp];

                    }
                }
                else {
                    // Unable to read the value
                }
            }];
            
        }
    }
}

- (IBAction)plusButtonTapped:(id)sender {
    CGFloat currentTemp = [self.wishTempLabel.text floatValue];
    currentTemp += 0.5f;
    self.wishTempLabel.text = [NSString stringWithFormat:@"%.1f",currentTemp];
    
    [self adjustTemperature:currentTemp];
}

- (IBAction)minusButtonTapped:(id)sender {
    CGFloat currentTemp = [self.wishTempLabel.text floatValue];
    currentTemp -= 0.5f;
    self.wishTempLabel.text = [NSString stringWithFormat:@"%.1f",currentTemp];
    [self adjustTemperature:currentTemp];

}

- (void)adjustTemperature:(CGFloat)adjTemp{
    
    NSNumber *sentTemp = @(adjTemp);
    
    [self.temperature writeValue:sentTemp completionHandler:^(NSError *error){
        
        if (error == nil) {
            // Successfully wrote the value
            [self checkStatus];
            NSLog(@"%@ is %@", self.temperature.metadata.manufacturerDescription, self.temperature.value);
            
        }
        else {
            // Unable to write the value
        }

    }];
}


- (IBAction)triggleSwitch:(id)sender {
    self.softState ^= YES;
    id write = self.softState ? @1:@0;
    
    [self.oncCharacter writeValue:write completionHandler:^(NSError *error) {
        if (error == nil) {
            // Successfully wrote the value
            NSLog(@"%@ is %@", self.oncCharacter.metadata.manufacturerDescription, self.oncCharacter.value);

        }
        else {
            // Unable to write the value
        }
    }];
    
    [self checkStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
