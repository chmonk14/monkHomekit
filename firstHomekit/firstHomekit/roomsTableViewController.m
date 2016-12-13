//
//  roomsTableViewController.m
//  firstHomekit
//
//  Created by Project on 10/17/16.
//  Copyright © 2016 Ananta Solution. All rights reserved.
//

#import "roomsTableViewController.h"
#import "accTableViewController.h"


@interface roomsTableViewController ()

@property HMRoom *selectedRoom;


@end

@implementation roomsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _selectedHome.delegate = self;
    
    self.navigationItem.title = _selectedHome.name;
    NSLog(@"default room : %@", self.selectedHome.roomForEntireHome.accessories);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addRoom:(id)sender {
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Adding new room" message:@"please specify the name" preferredStyle:UIAlertControllerStyleAlert]; // 7
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"room adding");
        NSString *roomName = alert.textFields.firstObject.text;

        [_selectedHome addRoomWithName:roomName completionHandler:^(HMRoom *room, NSError *error) {
            if (error != nil) {
                // Failed to add a room to a home
                NSLog(@"adding room is error : %@",error);
            } else {
                // Successfully added a room to a home
                NSLog(@"room added");
                [self home:self.selectedHome didAddRoom:room];
            }
        }];

        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"type your room name";
    }];
    
    [self presentViewController:alert animated:YES completion:nil]; // 11
    

}

- (void)home:(HMHome *)home didAddRoom:(HMRoom *)room{
    [self.tableView reloadData];
}

- (IBAction)shareToUser:(id)sender {
    HMUser *user = self.selectedHome.currentUser;
    NSLog(@"Users : %@",user);
    [self.selectedHome homeAccessControlForUser:user];
    [self.selectedHome manageUsersWithCompletionHandler:^(NSError *error){
        NSLog(@"manage user error, %@", error);
        
    }];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_selectedHome.rooms count] == 0) {
        return 1;
    }
    
    return [_selectedHome.rooms count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if ([_selectedHome.rooms count] == 0) {
        cell.textLabel.text = @"there is no room";
    }else{
        cell.textLabel.text = [[_selectedHome.rooms objectAtIndex:indexPath.row] name];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did sel row");
    _selectedRoom = [_selectedHome.rooms objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toAcc" sender:nil];
    
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
    
    accTableViewController *accVC = [segue destinationViewController];
    accVC.selectedRoom = self.selectedRoom;
    accVC.selectedHome = self.selectedHome;

}


@end
