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
#import "MyAuth.h"
@import Parse;

static NSString *const kIssuer = @"https://accounts.google.com";
static NSString *const kExampleAuthorizerKey = @"authorization";
static NSString *const OIDOAuthTokenErrorDomain = @"org.openid.appauth.oauth_token";

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *eventsArray;
@property (weak, nonatomic) IBOutlet UILabel *noEventsLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaysDay;
@property (weak, nonatomic) IBOutlet UILabel *todaysDate;
@property (strong, nonatomic) NSString *kClientID;
@property (strong, nonatomic) NSString *kRedirectURI;
@property (strong, nonatomic) NSString *kAccessToken;

@end

@implementation HomeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.noEventsLabel.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    [self.eventsTableView reloadData];
    [self _fetchEvents];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setUpViews];
    [self _fetchEvents];
    [self _setUpConstants];
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

- (void) _setUpViews {
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(fetchEvents) forControlEvents:UIControlEventValueChanged];
//    [self.eventsTableView insertSubview:self.refreshControl atIndex:0];
    
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    [actions addObject:[UIAction actionWithTitle:@"Compose New" image:nil identifier:nil
                        handler:^(__kindof UIAction* _Nonnull action) {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ComposeViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ComposeViewController"];
            [self.navigationController pushViewController:controller animated:YES];
    }]];
    [actions addObject:[UIAction actionWithTitle:@"Import from Google" image:nil identifier:nil
                        handler:^(__kindof UIAction* _Nonnull action) {
        [self _didTapImport];
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

- (void)_fetchEvents {
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery orderByAscending: @"eventDate"];
    [eventQuery whereKey:@"author" equalTo: [PFUser currentUser]];
    NSDate *curDate = [NSDate date];
    [eventQuery whereKey:@"eventDate" greaterThanOrEqualTo:curDate];
    eventQuery.limit = 20;

    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            self.eventsArray = [NSMutableArray arrayWithArray:events];
            [self.eventsTableView reloadData];
            
            if(self.eventsArray.count == 0){
                self.noEventsLabel.hidden = NO;
            }
            //[self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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

  // Creates a GTMSessionFetcherService with the authorization.
  // Normally you would save this service object and re-use it for all REST API calls.
    GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
//    MyAuth *auth = [[MyAuth alloc] initWithAccessToken: self.kAccessToken];
//    fetcherService.authorizer = auth;
    fetcherService.authorizer = self.authorization;

  // Creates a fetcher for the API call.
    NSString *endpoint = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/primary?access_token=%@", self.kAccessToken];
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
    NSLog(@"Success: %@", jsonDictionaryOrArray);
  }];
}

- (void) _didTapImport {
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


// Table View Functions:

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    cell.event = self.eventsArray[indexPath.row];
    cell.nameLabel.text = cell.event.eventName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"h:mm a MMM d"];
    [formatter setDateFormat:@"MMM d"];
    NSString *stringFromDate = [formatter stringFromDate:cell.event.eventDate];
    cell.dateLabel.text = stringFromDate;


//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = cell.colorView.bounds;
//    gradient.colors = @[(id)[UIColor lightGrayColor].CGColor, (id)[UIColor darkGrayColor].CGColor];
//    [cell.colorView.layer insertSublayer:gradient atIndex:0];
    
    cell.colorView.layer.cornerRadius = 20.0;
    cell.colorView.layer.shadowOffset = CGSizeMake(1, 0);
    cell.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.colorView.layer.shadowRadius = 5;
    cell.colorView.layer.shadowOpacity = .25;
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.eventsArray.count;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailSegue"]){
        NSIndexPath *myIndexPath = [self.eventsTableView indexPathForCell:sender];
        Event *dataToPass = self.eventsArray[myIndexPath.row];
        DetailsViewController *detailVC = [segue destinationViewController];
        detailVC.detailEvent = dataToPass;
    }
}

@end
