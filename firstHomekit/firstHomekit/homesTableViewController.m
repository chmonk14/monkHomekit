//
//  homesTableViewController.m
//  firstHomekit
//
//  Created by Project on 10/17/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import "homesTableViewController.h"
#import <HomeKit/HomeKit.h>
#import "roomsTableViewController.h"

@interface homesTableViewController ()

@property HMHomeManager *homeManager;
@property HMHome *selectedHome;

@end

@implementation homesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager{
    [self.tableView reloadData];
    NSLog(@"homes : %lu", (unsigned long)[_homeManager.homes count]);
    
}

- (IBAction)addHome:(id)sender {
    
    NSLog(@"home adding");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Adding new home" message:@"please specify the name" preferredStyle:UIAlertControllerStyleAlert]; // 7
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *homeName = alert.textFields.firstObject.text;
        
        [self.homeManager addHomeWithName:homeName completionHandler:^(HMHome *home, NSError *error) {
            if (error != nil) {
                // Failed to add a room to a home
                NSLog(@"adding home is error : %@",error);
            } else {
                // Successfully added a room to a home
                NSLog(@"home added");
                [self.tableView reloadData];
            }
        }];
        
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"type your home name";
    }];
    
    [self presentViewController:alert animated:YES completion:nil]; // 11
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_homeManager.homes count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_homeManager.homes objectAtIndex:indexPath.row].name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu rooms",[[_homeManager.homes objectAtIndex:indexPath.row].rooms count] ];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did sel row");
    _selectedHome = [_homeManager.homes objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toRoom" sender:nil];

}


/*
// Override to support conditional editing of the table view.
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
    NSLog(@"prepare for segue");
    
    roomsTableViewController *roomVC = [segue destinationViewController];
    roomVC.selectedHome = self.selectedHome;

}


@end
