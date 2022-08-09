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

@interface ProfileViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setUpViews];
    [self _fetchDetails];
}

- (void) _setUpViews {
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
    [self.saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    
    self.nameField.delegate = self;
    [self addPlaceholder:self.nameField :@"Name"];
    [self.nameField addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    self.usernameField.delegate = self;
    [self addPlaceholder:self.usernameField :@"Username"];
    [self.usernameField addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    self.addressField.delegate = self;
    [self addPlaceholder:self.addressField :@"Address"];
    [self.addressField addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    self.passwordField.delegate = self;
    [self addPlaceholder:self.passwordField :@"Password"];
    [self.passwordField addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
}

/// Fetch current user details from Parse
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing: true];
    return false;
}

/// Animation for text input
- (void) didChangeText:(UITextField *)textField {
    UILabel *label = [[UILabel alloc] init];
    for(UIView *subview in textField.subviews){
        if(subview.tag == 55555){
            label = subview;
        }
    }
    [UIView animateWithDuration:0.5 animations:^{
        if(textField.text.length == 0){
            label.center = [textField convertPoint:textField.center fromView:textField.superview];
            CGRect myFrame = label.frame;
            myFrame.origin.x = 5.0;
            label.frame = myFrame;
        } else {
            label.frame=CGRectMake(label.frame.origin.x,
                                   textField.bounds.origin.y - 13.0,
                                   100,
                                   10);
        }
    }];
}

- (void) addPlaceholder:(UITextField *)textField :(NSString *)name {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor lightGrayColor];
    label.tag = 55555;
    label.font = [UIFont systemFontOfSize:13];
    label.text = name;
    [label sizeToFit];
    [textField addSubview:label];
    label.center = [textField convertPoint:textField.center fromView:textField.superview];
    CGRect myFrame = label.frame;
    myFrame.origin.x = 5.0;
    label.frame = myFrame;
}
 
/// Tap gesture for editing profile picture
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
    __weak typeof(self) weakSelf = self;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error saving: %@", error.localizedDescription);
        }
        else{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.delegate didSaveEdits: nameData :usernameData :passwordData :addressData :strongSelf.profilePicture.file];
            
            strongSelf.nameField.text = @"";
            strongSelf.usernameField.text = @"";
            strongSelf.passwordField.text = @"";
            strongSelf.addressField.text = @"";
            [strongSelf _fetchDetails];
        }
    }];
}

- (IBAction)didTapLogout:(id)sender {
    [self _clearUserData];
    
    __weak typeof(self) weakSelf = self;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Cannot log out");
        } else {
            // Success
            __strong typeof(self) strongSelf = weakSelf;
            SceneDelegate *sceneDelegate = (SceneDelegate *)strongSelf.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            sceneDelegate.window.rootViewController = loginViewController;
        }
    }];
}

/// Removes notifications and Google access token upon logout
- (void) _clearUserData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
}

@end
