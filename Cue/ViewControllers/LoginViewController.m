//
//  LoginViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "SignUpViewController.h"

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


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordField.secureTextEntry = true;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [ivc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
}

- (IBAction)didTapLogin:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Username or password is empty." preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
    else{
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                NSLog(@"User log in failed: %@", error.localizedDescription);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid acccount." preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:^{}];
            } else {
                NSLog(@"User logged in successfully");
                SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            }
        }];
    }
    
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
        if (authState) {
          GTMAppAuthFetcherAuthorization *authorization =
              [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];

          [self setGtmAuthorization:authorization];
          NSLog(@"Got authorization tokens. Access token: %@",
                           authState.lastTokenResponse.accessToken);
            self.kAccessToken = authState.lastTokenResponse.accessToken;
        } else {
          [self setGtmAuthorization:nil];
          NSLog(@"Authorization error: %@", [error localizedDescription]);
        }
      }];
    }];
    
}

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
      [self _checkParseUser: jsonDictionaryOrArray];
    }];
}

- (void) _checkParseUser:(NSDictionary*) userInfo {
    NSLog(@"Checking parse user");
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo: userInfo[@"email"]];
    
    // TODO: HANDLE ADDRESS FIELD

//    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *user, NSError *error) {
//        if (user.count > 0){
//            [self _loginUser: userInfo];
//            NSLog(@"logging in user");
//        } else if (user != nil) {
//            [self _createUser: userInfo];
//            NSLog(@"creating parse user");
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (user){
            [self _loginUser: userInfo];
            NSLog(@"logging in user");
        } else {
            [self _createUser: userInfo];
            NSLog(@"creating parse user");
        }
    }];
    
}

- (void) _loginUser: (NSDictionary*) userInfo {
    NSLog(@"what");
    NSString *username = userInfo[@"email"];
    NSString *password = @"google";
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid acccount." preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{}];
        } else {
            NSLog(@"User logged in successfully");
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        }
    }];
}

- (void) _createUser:(NSDictionary*) userInfo {
    NSLog(@"Almost there");
    PFUser *newUser = [PFUser user];
    newUser[@"name"] = userInfo[@"name"];
    newUser.username = userInfo[@"email"];
    newUser.password = @"google";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to sign up" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{}];
        } else {
            NSLog(@"User registered successfully");
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        }
    }];
}

- (IBAction)didTapSignUp:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//}

@end
