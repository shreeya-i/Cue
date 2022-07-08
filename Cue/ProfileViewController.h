//
//  ProfileViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol EditDelegate

- (void)didSaveEdits:(NSString *)name :(NSString *)username :(NSString *)password;

@end

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *currentName;
@property (weak, nonatomic) IBOutlet UILabel *currentUsername;
@property (nonatomic, weak) id<EditDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
