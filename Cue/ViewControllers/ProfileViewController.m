//
//  ProfileViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "ProfileViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *postTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPlaceholderImage:)];
    [self.profilePicture addGestureRecognizer:postTapGestureRecognizer];
    [self.profilePicture setUserInteractionEnabled:YES];
    
    UIColor *lighter = [UIColor colorWithRed: 0.69 green: 0.83 blue: 0.51 alpha: 1.0];
    UIColor *darker = [UIColor colorWithRed: 0.33 green: 0.62 blue: 0.29 alpha: 0.2];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.colorView.bounds;
    gradient.colors = @[(id)lighter.CGColor, (id)darker.CGColor];
    [self.colorView.layer insertSublayer:gradient atIndex:0];
    
    self.saveButton.layer.cornerRadius = 15.0;
    
    [self _fetchDetails];
}

- (void) _fetchDetails {
    self.currentName.text = [PFUser currentUser][@"name"];
    self.currentUsername.text = [NSString stringWithFormat:@"@%@", [PFUser currentUser].username];
    
    self.profilePicture.layer.cornerRadius  = self.profilePicture.frame.size.width/2;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.layer.borderWidth = 0.5f;
    self.profilePicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    PFUser *user = [PFUser currentUser];
    if(user[@"profilePicture"]){
        PFFileObject *file = user[@"profilePicture"];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [self.profilePicture setImage:image];
            }
        }];
    }
    else {
        self.profilePicture.image = [UIImage imageNamed: @"defaultpfp"];
    }
}

- (void) didTapPlaceholderImage:(UITapGestureRecognizer *)sender{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    if (editedImage){
        [self.profilePicture setImage: editedImage];
        PFFileObject *file = [self getPFFileFromImage: editedImage];
        [self.profilePicture setFile: file];
    }
    else{
        self.profilePicture.image = originalImage;
        PFFileObject *file = [self getPFFileFromImage: originalImage];
        [self.profilePicture setFile: file];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


- (IBAction)didTapSave:(id)sender {
    
    NSString *nameData;
    NSString *usernameData;
    NSString *passwordData;
    NSString *addressData;
    
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
    if(![self.addressField.text isEqual: @""]){
        addressData = self.addressField.text;
        user[@"address"] = addressData;
    }
    if(self.profilePicture.file){
        user[@"profilePicture"] = self.profilePicture.file;
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error saving: %@", error.localizedDescription);
        }
        else{
            [self.delegate didSaveEdits: nameData :usernameData :passwordData :addressData :self.profilePicture.file];
            
            self.nameField.text = @"";
            self.usernameField.text = @"";
            self.passwordField.text = @"";
            self.addressField.text = @"";
            [self _fetchDetails];
            NSLog(@"Successfully saved");
        }
    }];
}

- (void) _clearUserData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
}


- (IBAction)didTapLogout:(id)sender {
    [self _clearUserData];
    
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
