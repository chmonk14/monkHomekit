//
//  searchAccTableViewController.m
//  firstHomekit
//
//  Created by Project on 10/17/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import "searchAccTableViewController.h"
#import <HomeKit/HomeKit.h>

@interface searchAccTableViewController () <HMAccessoryBrowserDelegate, HMAccessoryDelegate, HMHomeManagerDelegate>

@property HMHomeManager *homeManager;
@property HMAccessoryBrowser *accessoryBrowser;
@property NSMutableArray *availableAcessory;


@end

@implementation searchAccTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.accessoryBrowser = [[HMAccessoryBrowser alloc] init];
    self.accessoryBrowser.delegate = self;

    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;

    self.availableAcessory = [[NSMutableArray alloc] init];
    [self.accessoryBrowser startSearchingForNewAccessories];
    [self availableAccessories];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHomes:) name:@"UpdateHomesNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrimaryHome:) name:@"UpdatePrimaryHomeNotification"  object:nil];
    
    
    
}


- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory {
    // Update the UI per the new accessory; for example, reload a picker view.

    [self.availableAcessory addObject:accessory];
    [self.tableView reloadData];

}

- (void)availableAccessories{
    
    [self.availableAcessory addObjectsFromArray:self.accessoryBrowser.discoveredAccessories];
    [self.availableAcessory addObjectsFromArray:self.selectedHome.accessories];
    [self.availableAcessory removeObjectsInArray:self.selectedRoom.accessories];
    
}

- (void) updateHomes:(HMHome*)home{
    NSLog(@"updateHomes");
}

- (void) updatePrimaryHome:(HMHome*)home{
    NSLog(@"updatePrimaryHome");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.accessoryBrowser stopSearchingForNewAccessories];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.availableAcessory count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"foundAcc" forIndexPath:indexPath];
    
    // Configure the cell...
    HMAccessory *accessory = [self.availableAcessory objectAtIndex:indexPath.row];
    cell.textLabel.text = accessory.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    HMAccessory *accessory = [self.availableAcessory objectAtIndex:indexPath.row];
    accessory.delegate = self;
    
    [self accessoryDidUpdateReachability:accessory];
    
}

- (void)accessoryDidUpdateReachability:(HMAccessory *)accessory {
    if (accessory.reachable == YES) {
        
        // Can communicate with the accessory
        NSLog(@"reachable");
        
        // Add an accesory to a home and a room
        // 1. Get the home and room objects for the completion handlers.
        HMHome *home = _selectedHome;
        
        HMRoom *room = _selectedRoom;
        // 2. Add the accessory to the home
        
        if ([home.accessories containsObject:accessory]) {
            [home assignAccessory:accessory toRoom:room completionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error);

                    // Failed to add accessory to room
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Adding Accessory" message:error.userInfo preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    
                    [alert addAction:defaultAction];
                    
                }else{
                    [self.navigationController popViewControllerAnimated:YES];

                }
                
            }];

        }else{
            [home addAccessory:accessory completionHandler:^(NSError *error) {
                if (error) {
                    // Failed to add accessory to home
                    NSLog(@"%@", error);
                    [self.tableView reloadData];
                    
                } else {
                    NSLog(@"add accessory success,");
                    
                    if (accessory.room != room) {
                        // 3. If successfully, add the accessory to the room
                        [home assignAccessory:accessory toRoom:room completionHandler:^(NSError *error) {
                            if (error) {
                                // Failed to add accessory to room
                                NSLog(@"error when adding acc to room \n %@",error);
                                
                            }
                        }];
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];

                }
            }];
        }
        
        

    } else {
        // The accessory is out of range, turned off, etc
        NSLog(@"accessory is unreachable");

    }
}


/*
// Override to support conditional editing of    the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"prepare segue");
}


@end
