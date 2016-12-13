//
//  accTableViewController.m
//  firstHomekit
//
//  Created by Project on 10/17/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import "accTableViewController.h"
#import "searchAccTableViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "oneStateController.h"

@interface accTableViewController () <EAAccessoryDelegate>

@property HMAccessory *selectedAccessory;

@end

@implementation accTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.selectedRoom.name;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EAAccessoryDidConnectNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)accessoryDidDisconnect:(EAAccessory *)accessory{
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) searchAcc {
    NSLog(@"searched ");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([_selectedRoom.accessories count] == 0) {
        return 1;
    }

    return [_selectedRoom.accessories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if ([_selectedRoom.accessories count] == 0) {
        cell.textLabel.text = @"there is no accessory";
    }else{
        cell.textLabel.text = [[_selectedRoom.accessories objectAtIndex:indexPath.row] name];
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_selectedRoom.accessories count] == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        self.selectedAccessory = [self.selectedRoom.accessories objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"selectedAcc" sender:nil];

    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Editing accessory name" message:@"please specify the name" preferredStyle:UIAlertControllerStyleAlert]; // 7
    
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            NSLog(@"accessory editing name");
            
            HMAccessory *accessory = [self.selectedRoom.accessories objectAtIndex:indexPath.row];
            NSString *accNewName = alert.textFields.firstObject.text;

            //changing name
            [accessory updateName:accNewName completionHandler:^(NSError *error) {
                NSLog(@"editing error : %@",error);

                if (error) {
                    // Failed to change the name
                } else {
                    // Successfully changed the name
                    
                    [self.tableView reloadData];
                }
            }];

            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancelAction];
        [alert addAction:defaultAction];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"type your new accessory name";
        }];
        
        [self presentViewController:alert animated:YES completion:nil]; // 11

        
        
        

    }];
    editAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        HMAccessory *accessory = [self.selectedRoom.accessories objectAtIndex:indexPath.row];
        
        [self.selectedHome removeAccessory:accessory completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"deleting error : %@",error);

                //alert error
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Accessory Error" message:error preferredStyle:UIAlertControllerStyleAlert]; // 7
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [alert addAction:defaultAction];

                
            }else{
                [tableView reloadData];

            }
            
        }];
        

        

    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,editAction];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

    if([segue.identifier isEqualToString:@"searching"]){
        
        searchAccTableViewController *searchVC = segue.destinationViewController;
        searchVC.selectedHome = self.selectedHome;
        searchVC.selectedRoom = self.selectedRoom;
        
    }else if ([segue.identifier isEqualToString:@"selectedAcc"]){
        oneStateController *oscVC = segue.destinationViewController;
        oscVC.accessory = self.selectedAccessory;
        
    }
    
    
    
    
}


@end
