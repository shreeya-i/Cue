//
//  LoginViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "SignUpViewController.h"
#import "NotificationObject.h"
#import <UserNotifications/UserNotifications.h>
/// Google API imports:
#import "GoogleAPIClientForREST/GTLRCalendar.h"
#import "GTMAppAuth/GTMAppAuth.h"
#import "OIDAuthorizationRequest.h"
#import "OIDAuthorizationService.h"
#import "AppDelegate.h"
#import "OIDAuthState+IOS.h"
#import "OIDTokenResponse.h"
#import "GoogleViewController.h"

@import Parse;

static NSString *const kIssuer = @"https://accounts.google.com";
static NSString *const kExampleAuthorizerKey = @"authorization";
static NSString *const OIDOAuthTokenErrorDomain = @"org.openid.appauth.oauth_token";

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (strong, nonatomic) NSString *kClientID;
@property (strong, nonatomic) NSString *kRedirectURI;
@property (strong, nonatomic) NSString *kAccessToken;
@property (strong, nonatomic) UNUserNotificationCenter *notificationCenter;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordField.secureTextEntry = true;
    self.notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [ivc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
}

- (IBAction)didTapLogin:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        [self _emptyFieldAlert];
    }
    else{
        __weak typeof(self) weakSelf = self;
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                __strong typeof(self) strongSelf = weakSelf;
                NSLog(@"User log in failed: %@", error.localizedDescription);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid acccount." preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:okAction];
                [strongSelf presentViewController:alert animated:YES completion:^{}];
            } else {
                __strong typeof(self) strongSelf = weakSelf;
                NSLog(@"User logged in successfully");
                [strongSelf _importExistingNotifs];
                [strongSelf _switchViews];
            }
        }];
    }
}

/// Instantiate tab bar view once login completed
- (void) _switchViews {
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
}

/// Import currently logged in user's notifications saved in backend
- (void) _importExistingNotifs {
    PFQuery *notifQuery = [PFQuery queryWithClassName:@"Notification"];
    [notifQuery whereKey:@"user" equalTo: [PFUser currentUser]];
    NSDate *curDate = [NSDate date];
    [notifQuery whereKey:@"postDate" greaterThanOrEqualTo:curDate];
    
    [notifQuery findObjectsInBackgroundWithBlock:^(NSArray *notifs, NSError *error) {
        if (notifs != nil) {
            for(NotificationObject *notif in notifs){
                
                NSDate *curDate = [NSDate date];
                NSTimeInterval dayDiff = [notif.postDate timeIntervalSinceDate:curDate];
                
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = @"Cue";
                content.body = notif.text;
                content.sound = [UNNotificationSound defaultSound];
                
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:dayDiff repeats:NO];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notif.text content:content trigger:trigger];
                [self.notificationCenter addNotificationRequest:request withCompletionHandler:nil];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) _emptyFieldAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Username or password is empty." preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

/// Initialize Google API Constants
- (void) _setUpConstants {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *GTMClientID = [dict objectForKey: @"kGoogleAPIClientID"];
    [[NSUserDefaults standardUserDefaults] setObject:GTMClientID forKey:@"GTMClientID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *baseID = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"GTMClientID"];
    self.kClientID = [NSString stringWithFormat:@"%@.apps.googleusercontent.com", baseID];
    self.kRedirectURI = [NSString stringWithFormat: @"com.googleusercontent.apps.%@:/oauthredirect", baseID];
    NSLog(@"%@", baseID);
    NSLog(@"%@", self.kClientID);
    NSLog(@"%@", self.kRedirectURI);
}

- (IBAction)didTapGoogle:(id)sender {
    [self _setUpConstants];
    
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:self.kRedirectURI];
    
    NSLog(@"Fetching configuration for issuer: %@", issuer);
    
    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
        
        if (!configuration) {
            NSLog(@"Error retrieving discovery document: %@", [error localizedDescription]);
            [self setGtmAuthorization:nil];
            return;
        }
        
        NSLog(@"Got configuration: %@", configuration);
        
        // builds authentication request
        OIDAuthorizationRequest *request =
        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:self.kClientID
                                                        scopes:@[OIDScopeOpenID, OIDScopeProfile,
                                                                 @"https://www.googleapis.com/auth/calendar",
                                                                 @"https://www.googleapis.com/auth/calendar.events",
                                                                 @"https://www.googleapis.com/auth/userinfo.email"]
                                                   redirectURL:redirectURI
                                                  responseType:OIDResponseTypeCode
                                          additionalParameters:nil];
        // performs authentication request
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSLog(@"Initiating authorization request with scope: %@", request.scope);
        
        appDelegate.currentAuthorizationFlow =
        [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                       presentingViewController:self
                                                       callback:^(OIDAuthState *_Nullable authState,
                                                                  NSError *_Nullable error) {
            __weak typeof(self) weakSelf = self;
            if (authState) {
                __strong typeof(self) strongSelf = weakSelf;
                GTMAppAuthFetcherAuthorization *authorization =
                [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                [strongSelf setGtmAuthorization:authorization];
                NSLog(@"Got authorization tokens. Access token: %@",
                      authState.lastTokenResponse.accessToken);
                strongSelf.kAccessToken = authState.lastTokenResponse.accessToken;
                
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:authState.lastTokenResponse.accessToken forKey:@"kAccessToken"];
                [defaults synchronize];
            } else {
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf setGtmAuthorization:nil];
                NSLog(@"Authorization error: %@", [error localizedDescription]);
            }
        }];
    }];
}

/// Google API functions:

- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
    if ([_authorization isEqual:authorization]) {
        return;
    }
    _authorization = authorization;
    [self stateChanged];
}

- (void)stateChanged {
    [self saveState];
    [self updateUI];
}

- (void)saveState {
    if (_authorization.canAuthorize) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:kExampleAuthorizerKey];
    } else {
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kExampleAuthorizerKey];
    }
}

- (void)updateUI {
    if (!_authorization.canAuthorize) {
    } else {
        [self _getUserInfo];
    }
}

/// Access Google user information e.g. name, email
- (void ) _getUserInfo {
    NSLog(@"Performing userinfo request");
    
    GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
    fetcherService.authorizer = self.authorization;
    
    // Creates a fetcher for the API call.
    NSURL *userinfoEndpoint = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v3/userinfo"];
    GTMSessionFetcher *fetcher = [fetcherService fetcherWithURL:userinfoEndpoint];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        // Checks for an error.
        if (error) {
            // OIDOAuthTokenErrorDomain indicates an issue with the authorization.
            if ([error.domain isEqual:OIDOAuthTokenErrorDomain]) {
                [self setGtmAuthorization:nil];
                NSLog(@"Authorization error during token refresh, clearing state. %@", error);
                // Other errors are assumed transient.
            } else {
                NSLog(@"Transient error during token refresh. %@", error);
            }
            return;
        }
        
        // Parses the JSON response.
        NSError *jsonError = nil;
        id jsonDictionaryOrArray =
        [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // JSON error.
        if (jsonError) {
            NSLog(@"JSON decoding error %@", jsonError);
            return;
        }
        
        // Success response!
        NSLog(@"Success: %@", jsonDictionaryOrArray);
        [self _checkGoogleParseUser: jsonDictionaryOrArray];
    }];
}

/// Check if the user who just logged in with User already has an account created locally in Parse
- (void) _checkGoogleParseUser:(NSDictionary*) userInfo {
    NSLog(@"Checking parse user");
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo: userInfo[@"email"]];
    
    __weak typeof(self) weakSelf = self;
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (user){
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _loginGoogleUser: userInfo];
            NSLog(@"logging in user");
        } else {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _createGoogleUser: userInfo];
            NSLog(@"creating parse user");
        }
    }];
}

/// Login existing Google user
- (void) _loginGoogleUser: (NSDictionary*) userInfo {
    NSString *username = userInfo[@"email"];
    NSString *password = @"google";
    
    __weak typeof(self) weakSelf = self;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            __strong typeof(self) strongSelf = weakSelf;
            NSLog(@"User login failed: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid acccount." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [strongSelf presentViewController:alert animated:YES completion:^{}];
        } else {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _importExistingNotifs];
            SceneDelegate *sceneDelegate = (SceneDelegate *)strongSelf.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        }
    }];
}

/// Create new Cue user using Google account
- (void) _createGoogleUser:(NSDictionary*) userInfo {
    PFUser *newUser = [PFUser user];
    newUser[@"name"] = userInfo[@"name"];
    newUser.username = userInfo[@"email"];
    newUser.password = @"google";
    __weak typeof(self) weakSelf = self;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            __strong typeof(self) strongSelf = weakSelf;
            NSLog(@"Error: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to sign up" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [strongSelf presentViewController:alert animated:YES completion:^{}];
        } else {
            __strong typeof(self) strongSelf = weakSelf;
            SceneDelegate *sceneDelegate = (SceneDelegate *)strongSelf.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        }
    }];
}

@end
