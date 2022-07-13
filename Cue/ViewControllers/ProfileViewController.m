//
//  ProfileViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "ProfileViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchDetails];
}

- (void) fetchDetails {
    self.currentName.text = [PFUser currentUser][@"name"];
    self.currentUsername.text = [PFUser currentUser].username;
    
    self.profilePicture.layer.cornerRadius  = self.profilePicture.frame.size.width/2;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.layer.borderWidth = 0.5f;
    self.profilePicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (IBAction)didTapSave:(id)sender {
    
    NSString *nameData;
    NSString *usernameData;
    NSString *passwordData;
    
    PFUser *user = [PFUser currentUser];
    if(![self.nameField.text isEqual: @""]){
        nameData = self.nameField.text;
        user[@"name"] = nameData;
    } else{
        nameData = user[@"name"];
    }
    if(![self.usernameField.text isEqual: @""]){
        usernameData = self.usernameField.text;
        user[@"username"] = usernameData;
    } else{
        usernameData = user[@"username"];
    }
    if(![self.passwordField.text isEqual: @""]){
        passwordData = self.passwordField.text;
        user[@"password"] = passwordData;
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error saving: %@", error.localizedDescription);
        }
        else{
            [self.delegate didSaveEdits: nameData :usernameData :passwordData];

            self.nameField.text = @"";
            self.usernameField.text = @"";
            self.passwordField.text = @"";
            [self fetchDetails];
            NSLog(@"Successfully saved");
        }
    }];
}


- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
           if (error) {
               NSLog(@"Cannot log out");
           } else {
               // Success
               NSLog(@"User logged out successfully.");
               SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
               UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
               LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
               sceneDelegate.window.rootViewController = loginViewController;
           }
       }];
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
