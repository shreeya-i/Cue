//
//  HomeViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "HomeViewController.h"
#import "ComposeViewController.h"
#import "EventCell.h"
#import "DetailsViewController.h"
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

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *eventsArray;
@property (strong, nonatomic) NSArray *filteredData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *noEventsLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaysDay;
@property (weak, nonatomic) IBOutlet UILabel *todaysDate;
@property (strong, nonatomic) NSString *kClientID;
@property (strong, nonatomic) NSString *kRedirectURI;
@property (strong, nonatomic) NSString *kAccessToken;
@property (nonatomic) BOOL isLoggedIn;

@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.eventsTableView reloadData];
    [self _fetchEvents];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.noEventsLabel.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    [self.eventsTableView reloadData];
    [self _fetchEvents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initYelp];
    [self _initGoogle];
    [self _setUpViews];
    [self _fetchEvents];
    [self _loginChecks];
}

/// Initialize Yelp API constants
- (void) _initYelp {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSString *apiKey = [dict objectForKey: @"API_Key"];
    
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"apiKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Initialize Google API constants
- (void) _initGoogle {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *GTMClientID = [dict objectForKey: @"kGoogleAPIClientID"];
    [[NSUserDefaults standardUserDefaults] setObject:GTMClientID forKey:@"GTMClientID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *baseID = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"GTMClientID"];
    self.kClientID = [NSString stringWithFormat:@"%@.apps.googleusercontent.com", baseID];
    self.kRedirectURI = [NSString stringWithFormat: @"com.googleusercontent.apps.%@:/oauthredirect", baseID];
}

/// Set up constant UIViews
- (void) _setUpViews {
    self.isLoggedIn = FALSE;
    
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    __weak typeof(self) weakSelf = self;
    [actions addObject:[UIAction actionWithTitle:@"Compose New" image:nil identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:@"composeSegue" sender:self];
    }]];
    [actions addObject:[UIAction actionWithTitle:@"Import from Google" image:nil identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _didTapImport];
    }]];
    
    UIMenu* menu = [UIMenu menuWithTitle:@"" children:actions];
    
    self.composeButton.menu = menu;
    self.composeButton.showsMenuAsPrimaryAction = TRUE;
    
    self.eventsTableView.delegate = self;
    self.eventsTableView.dataSource = self;
    self.eventsTableView.rowHeight = 200;
    
    NSDate *curDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:curDate];
    self.todaysDate.text = stringFromDate;
    
    NSDate *curDate2 = [NSDate date];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"EEEE"];
    NSString *stringFromDate2 = [formatter2 stringFromDate:curDate2];
    self.todaysDay.text = stringFromDate2;
}

/// Fetch Parse events for current logged in user to populate home calendar
- (void)_fetchEvents {
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery orderByAscending: @"eventDate"];
    [eventQuery whereKey:@"author" equalTo: [PFUser currentUser]];
    NSDate *curDate = [NSDate date];
    [eventQuery whereKey:@"eventDate" greaterThanOrEqualTo:curDate];
    eventQuery.limit = 20;
    
    __weak typeof(self) weakSelf = self;
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.eventsArray = [NSMutableArray arrayWithArray:events];
            [strongSelf.eventsTableView reloadData];
            
            if(strongSelf.eventsArray.count == 0){
                strongSelf.noEventsLabel.hidden = NO;
            }
            
            strongSelf.filteredData = strongSelf.eventsArray;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

/// Check whether a user is logging in with Google. If this is a first time user, they will be prompted to enter a home address
/// If this account but is a new session, the user will be asked if they want to import from their GCal
- (void) _loginChecks {
    NSString *address = [PFUser currentUser][@"address"];
    if(!address){
        [self _addressAlert];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"] != nil) {
        [self _importFromGoogle];
    }
}

- (void) _addressAlert {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Address Required"
                                                                              message: @"Input an address to be associated with your Google account."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Address";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * addressField = textfields[0];
        PFUser *user = [PFUser currentUser];
        user[@"address"] = addressField.text;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                NSLog(@"Error saving: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully saved");
            }
        }];
        [self _importFromGoogle];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) _importFromGoogle {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"] != nil) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        self.kAccessToken = [defaults objectForKey:@"kAccessToken"];
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"Google Calendar"
                                                                        message: @"Would you like to import your Google Calendar events?"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self _getUserEvents];
        }];
        [alert addAction:noAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
}

/// Following Google API functions:

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
    self.isLoggedIn = TRUE;
}

- (void)updateUI {
    if (!_authorization.canAuthorize) {
    } else {
        [self _getUserEvents];
    }
}

- (void ) _getUserEvents {
    
    // Creates a GTMSessionFetcherService with the authorization.
    // Normally you would save this service object and re-use it for all REST API calls.
    GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
    fetcherService.authorizer = self.authorization;
    
    NSDate *curDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *curDateString = [dateFormatter stringFromDate:curDate];
    
    // Creates a fetcher for the API call.
    NSString *endpoint = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=%@&access_token=%@&singleEvents=true&orderBy=startTime", curDateString, self.kAccessToken];
    NSURL *userinfoEndpoint = [NSURL URLWithString:endpoint];
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
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GoogleViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"GoogleViewController"];
        controller.importedEvents = jsonDictionaryOrArray;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

/// Initiates Google login if the user is not logged in through a Google account. Else directly imports Google Calendar events.
- (void) _didTapImport {
    if (self.isLoggedIn) {
        [self _getUserEvents];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"] != nil) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        self.kAccessToken = [defaults objectForKey:@"kAccessToken"];
        [self _getUserEvents];
    } else {
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
                                                                     @"https://www.googleapis.com/auth/calendar.events"]
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
                    GTMAppAuthFetcherAuthorization *authorization =
                    [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf setGtmAuthorization:authorization];
                    NSLog(@"Got authorization tokens. Access token: %@",
                          authState.lastTokenResponse.accessToken);
                    strongSelf.kAccessToken = authState.lastTokenResponse.accessToken;
                } else {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf setGtmAuthorization:nil];
                    NSLog(@"Authorization error: %@", [error localizedDescription]);
                }
            }];
        }];
    }
}


/// Table View Functions:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    cell.event = self.filteredData[indexPath.row];
    cell.nameLabel.text = cell.event.eventName;
    if([cell.event.cuesString isEqual:@""]){
        cell.cuesLabel.text = @"No Cues Selected";
    } else {
        cell.cuesLabel.text = [NSString stringWithFormat: @"Cues: %@", cell.event.cuesString];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d"];
    NSString *stringFromDate = [formatter stringFromDate:cell.event.eventDate];
    cell.dateLabel.text = stringFromDate;
    
    UIColor *lighter = [UIColor colorWithRed: 0.69 green: 0.83 blue: 0.51 alpha: 0.2];
    UIColor *darker = [UIColor colorWithRed: 0.33 green: 0.62 blue: 0.29 alpha: 0.1];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = cell.colorView.bounds;
    gradient.colors = @[(id)lighter.CGColor, (id)darker.CGColor];
    [cell.colorView.layer insertSublayer:gradient atIndex:0];
    
    cell.colorView.layer.cornerRadius = 20.0;
    cell.colorView.clipsToBounds = YES;
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredData.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchText isEqualToString:@""]) {
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        [eventQuery orderByAscending: @"eventDate"];
        [eventQuery whereKey:@"eventName" containsString: searchText];
        [eventQuery whereKey:@"author" equalTo: [PFUser currentUser]];
        NSDate *curDate = [NSDate date];
        [eventQuery whereKey:@"eventDate" greaterThanOrEqualTo:curDate];
        
        __weak typeof(self) weakSelf = self;
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
            if (events != nil) {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.filteredData = [NSMutableArray arrayWithArray:events];
                [strongSelf.eventsTableView reloadData];
            } else {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.filteredData = strongSelf.eventsArray;
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    else{
        self.filteredData = self.eventsArray;
    }
    [self.eventsTableView reloadData];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailSegue"]){
        NSIndexPath *myIndexPath = [self.eventsTableView indexPathForCell:sender];
        Event *dataToPass = self.filteredData[myIndexPath.row];
        DetailsViewController *detailVC = [segue destinationViewController];
        detailVC.detailEvent = dataToPass;
    } else if ([segue.identifier isEqualToString:@"editSegue"]){
        NSIndexPath *myIndexPath = [self.eventsTableView indexPathForCell:sender];
        Event *dataToPass = self.filteredData[myIndexPath.row];
        ComposeViewController *detailVC = [segue destinationViewController];
        detailVC.segueType = @"editSegue";
        detailVC.detailEvent = dataToPass;
    }
}

@end
