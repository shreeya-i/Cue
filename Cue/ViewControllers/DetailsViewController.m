//
//  DetailsViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/11/22.
//

#import "DetailsViewController.h"
#import "SuggestionCell.h"
#import "AFNetworking/AFNetworking.h"
#import "Suggestion.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "SuggestionViewController.h"


@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noSuggestionsLabel;
@property (nonatomic, strong) NSString *eventCategories;
@property (nonatomic, strong) NSArray *suggestionsArray;
@property (nonatomic, strong) NSMutableArray *suggestions;
@property (strong, nonatomic) NSMutableArray *selectedSuggestions;

@end

@implementation DetailsViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setUpViews];
    [self _dispatchInfo];
}

- (void) _dispatchInfo {
    [SVProgressHUD show];
    dispatch_queue_t getSuggestionsQueue = dispatch_queue_create("Get Yelp Events", NULL);
    dispatch_async(getSuggestionsQueue, ^{
        [self _fetchData];
    });
}

- (void) _setUpViews {
    
    self.noSuggestionsLabel.hidden = YES;
    
    self.eventCategories = [self.detailEvent.selectedCues componentsJoinedByString:@","];
    self.eventCategories = [self.eventCategories stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"PRINT THIS %@", self.eventCategories);
    
    self.nameLabel.text = self.detailEvent.eventName;
    
    self.selectedSuggestions = [NSMutableArray array];
    self.suggestions = [NSMutableArray array];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEE, MMM d"];
    NSString *stringFromDate = [dayFormatter stringFromDate:self.detailEvent.eventDate];
    self.dayLabel.text = stringFromDate;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *timeFromDate = [timeFormatter stringFromDate:self.detailEvent.eventDate];
    self.timeLabel.text = timeFromDate;
}

- (void) _fetchData{
    NSString *apiKey = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"apiKey"];
    NSString *header = [NSString stringWithFormat:@"Bearer %@", apiKey];
    NSString *radius = [NSString stringWithFormat: @"%@", self.detailEvent.searchRadius];
    NSString *address = [PFUser currentUser][@"address"];
    NSString *location = [address stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *requestURL = [NSString stringWithFormat: @"http://api.yelp.com/v3/businesses/search?radius=%@&location=%@&categories=%@", radius, location, self.eventCategories];

    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error) {
            [SVProgressHUD dismiss];
            self.noSuggestionsLabel.hidden = NO;
            NSLog(@"error");
        } else {
            NSLog(@"%@", responseObject);
            NSArray *suggestionDictionary = responseObject[@"businesses"];
            self.suggestionsArray = [Suggestion SuggestionWithDictionary:suggestionDictionary];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if(self.suggestionsArray.count>0){
                    [self.suggestions addObjectsFromArray:self.suggestionsArray];
                }
                else{
                    self.noSuggestionsLabel.hidden = NO;
                }
                    self.suggestionsTableView.delegate = self;
                    self.suggestionsTableView.dataSource = self;
                    self.suggestionsTableView.rowHeight = 115;
                    [self.suggestionsTableView reloadData];
            });
        }
    }];
    [task resume];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
    cell.isSelected = NO;
    
    cell.suggestion = self.suggestions[indexPath.row];
    cell.businessName.text = cell.suggestion.name;
    
    cell.colorView.layer.cornerRadius = 20.0;
    cell.colorView.layer.shadowOffset = CGSizeMake(1, 0);
    cell.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.colorView.layer.shadowRadius = 5;
    cell.colorView.layer.shadowOpacity = .25;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.suggestions.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if([segue.identifier isEqualToString:@"suggestionSegue"]){
         NSIndexPath *myIndexPath = [self.suggestionsTableView indexPathForCell:sender];
         Suggestion *dataToPass = self.suggestionsArray[myIndexPath.row];
         SuggestionViewController *detailVC = [segue destinationViewController];
         detailVC.detailSuggestion = dataToPass;
     }
 }

@end
