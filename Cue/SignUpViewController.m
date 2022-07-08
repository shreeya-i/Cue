//
//  SignUpViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "SignUpViewController.h"
#import "SceneDelegate.h"
@import Parse;

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapSignUp:(id)sender {
    PFUser *newUser = [PFUser user];
    
    newUser[@"name"] = self.nameField.text;
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    if([self.nameField.text isEqual:@""] ||
       [self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
    }
    else{
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"User registered successfully");
                SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            }
        }];
    }
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
