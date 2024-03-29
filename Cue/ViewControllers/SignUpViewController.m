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
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIButton *proceedButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proceedButton.layer.cornerRadius = 15.0;
}

- (IBAction)didTapSignUp:(id)sender {
    PFUser *newUser = [PFUser user];
    newUser[@"name"] = self.nameField.text;
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser[@"address"] = self.addressField.text;
    
    if([self.nameField.text isEqual:@""] ||
       [self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""] || [self.addressField.text isEqual:@""]) {
        [self _emptyFieldAlert];
    }
    else{
        __weak typeof(self) weakSelf = self;
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                __strong typeof(self) strongSelf = weakSelf;
                NSLog(@"Error: %@", error.localizedDescription);
                [strongSelf _signUpError];
            } else {
                __strong typeof(self) strongSelf = weakSelf;
                SceneDelegate *sceneDelegate = (SceneDelegate *)strongSelf.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            }
        }];
    }
}

- (void) _emptyFieldAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"All fields are required" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void) _signUpError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to sign up" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
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
