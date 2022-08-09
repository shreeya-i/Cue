//
//  DetailsViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/11/22.
//

#import "DetailsViewController.h"
#import "SuggestionCell.h"
#import "YelpSelectionCell.h"
#import "AFNetworking/AFNetworking.h"
#import "Suggestion.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "FilterCell.h"


@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noSuggestionsLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *filtersCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *cuesForYourEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *sortByLabel;
@property (weak, nonatomic) IBOutlet UIButton *unassignCueButton;
@property (nonatomic, strong) NSString *eventCategories;
@property (nonatomic, strong) NSArray *suggestionsArray;
@property (nonatomic, strong) NSMutableArray <NSString *> *selectedFilters;
@property (nonatomic) BOOL suggestionSelected;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) NSMutableArray *sortedArray;
@property (nonatomic, strong) NSString *eventID;

@property (nonatomic, strong) NSString *suggestionName;
@property (nonatomic, strong) NSString *suggestionDistance;
@property (nonatomic, strong) NSString *suggestionRating;
@property (nonatomic, strong) NSString *suggestionImageURL;

@end

@implementation DetailsViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self _checkSelection];
    [self _postCheckFunctions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _checkSelection];
    [self _setUpViews];
    [self _postCheckFunctions];
}

- (void) _postCheckFunctions{
    if(self.suggestionSelected){
        [self _setUpTableView];
    } else {
        [self _dispatchInfo];
    }
}

- (void) _checkSelection {
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery getObjectInBackgroundWithId:self.eventID
                                      block:^(PFObject *event, NSError *error) {
        if(!error){
            if(event[@"selectedCueId"]){
                if([event[@"selectedCueId"] isEqual: @""]){
                    self.suggestionSelected = false;
                    return;
                }
                PFQuery *eventQuery = [PFQuery queryWithClassName:@"Cue"];
                
                [eventQuery getObjectInBackgroundWithId:event[@"selectedCueId"]
                                                  block:^(PFObject *cue, NSError *error) {
                    if(!error){
                        self.suggestionSelected = true;
                        self.suggestionName = cue[@"name"];
                        self.suggestionRating = cue[@"rating"];
                        self.suggestionDistance = cue[@"distance"];
                        self.suggestionImageURL = cue[@"imageURL"];
                        [self.suggestionsTableView reloadData];
                        
                    } else{
                        NSLog(@"No cue found");
                    }
                }];
            }
        } else{
            NSLog(@"No event found");
        }
    }];
}

- (void) _dispatchInfo {
    [SVProgressHUD show];
    dispatch_queue_t getSuggestionsQueue = dispatch_queue_create("Get Yelp Events", NULL);
    dispatch_async(getSuggestionsQueue, ^{
        [self _fetchData];
    });
}

- (void) _setUpViews {
    self.cuesForYourEventLabel.text = @"Suggested Cues:";
    
    self.eventID = self.detailEvent.objectId;
    
    self.filters = @[@"Rating", @"Distance"];
    self.filtersCollectionView.dataSource = self;
    self.filtersCollectionView.delegate = self;
    
    self.unassignCueButton.layer.cornerRadius = 15.0;
    [self.unassignCueButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    
    self.noSuggestionsLabel.hidden = YES;
    self.unassignCueButton.hidden = YES;
    self.sortByLabel.hidden = YES;
    self.filtersCollectionView.hidden = YES;
    self.cuesForYourEventLabel.hidden = YES;
    
    self.eventCategories = [self.detailEvent.selectedCues componentsJoinedByString:@","];
    self.eventCategories = [self.eventCategories stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"PRINT THIS %@", self.eventCategories);
    
    self.nameLabel.text = self.detailEvent.eventName;
    
    self.selectedFilters = [NSMutableArray array];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEE, MMM d"];
    NSString *stringFromDate = [dayFormatter stringFromDate:self.detailEvent.eventDate];
    self.dayLabel.text = stringFromDate;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *timeFromDate = [timeFormatter stringFromDate:self.detailEvent.eventDate];
    self.timeLabel.text = timeFromDate;
}

- (void) _fetchData {
    NSString *apiKey = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"apiKey"];
    NSString *header = [NSString stringWithFormat:@"Bearer %@", apiKey];
    NSString *radius = [NSString stringWithFormat: @"%@", self.detailEvent.searchRadius];
    NSString *location = [self.detailEvent.address stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *requestURL = [NSString stringWithFormat: @"http://api.yelp.com/v3/businesses/search?radius=%@&location=%@&categories=%@", radius, location, self.eventCategories];
    
    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error) {
            [SVProgressHUD dismiss];
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.noSuggestionsLabel.hidden = NO;
            NSLog(@"error");
        } else {
            __strong typeof(self) strongSelf = weakSelf;
            NSArray *suggestionDictionary = responseObject[@"businesses"];
            strongSelf.suggestionsArray = [Suggestion SuggestionWithDictionary:suggestionDictionary];
            [strongSelf.sortedArray removeAllObjects];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if(strongSelf.suggestionsArray.count == 0){
                    strongSelf.noSuggestionsLabel.hidden = NO;
                }
                [strongSelf _setUpTableView];
            });
        }
    }];
    [task resume];
}

- (void) _setUpTableView {
    self.suggestionsTableView.delegate = self;
    self.suggestionsTableView.dataSource = self;
    if(self.suggestionSelected){
        self.suggestionsTableView.rowHeight = 400;
        self.suggestionsTableView.allowsSelection = false;
        self.cuesForYourEventLabel.hidden = false;
        self.cuesForYourEventLabel.text = @"Selected Cue:";
        self.filtersCollectionView.hidden = true;
        self.sortByLabel.hidden = true;
        self.unassignCueButton.hidden = false;
    } else {
        self.suggestionsTableView.rowHeight = 115;
        self.cuesForYourEventLabel.hidden = false;
        self.cuesForYourEventLabel.text = @"Suggested Cues:";
        self.filtersCollectionView.hidden = false;
        self.sortByLabel.hidden = false;
        self.unassignCueButton.hidden = true;
    }
    [self.suggestionsTableView reloadData];
    [self.filtersCollectionView reloadData];
}

- (IBAction)refreshData:(id)sender {
    [self _fetchData];
    [self.suggestionsTableView reloadData];
    [self.filtersCollectionView reloadData];
}

- (IBAction)unassignCue:(id)sender {
    self.suggestionSelected = false;
    [self _resetSelection];
    [self _checkSelection];
    [self _setUpTableView];
    [self _fetchData];
    [self.suggestionsTableView reloadData];
    [self.filtersCollectionView reloadData];
}

- (void) _resetSelection{
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery getObjectInBackgroundWithId:self.eventID
                                      block:^(PFObject *event, NSError *error) {
        if(!error){
            event[@"selectedCueId"] = @"";
            [event saveInBackground];
        } else{
            NSLog(@"No event found");
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.suggestionSelected){
        YelpSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YelpSelectionCell" forIndexPath:indexPath];
        cell.businessName.text = self.suggestionName;
        cell.distanceLabel.text = [NSString stringWithFormat: @"%@ mi", self.suggestionDistance];
        cell.ratingLabel.text = self.suggestionRating;
        
        NSURL * url = [NSURL URLWithString: self.suggestionImageURL];
        NSData * data = [NSData dataWithContentsOfURL:url];
        cell.businessImage.image = [UIImage imageWithData:data];
        cell.businessImage.layer.cornerRadius = 8.0;
        cell.businessImage.layer.masksToBounds = YES;
        
        cell.colorView.layer.cornerRadius = 20.0;
        cell.colorView.layer.shadowOffset = CGSizeMake(1, 0);
        cell.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.colorView.layer.shadowRadius = 5;
        cell.colorView.layer.shadowOpacity = .25;
        
        return cell;
    } else {
        SuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
        if (self.sortedArray.count > 0) {
            cell.suggestion = self.sortedArray[indexPath.row];
        } else {
            cell.suggestion = self.suggestionsArray[indexPath.row];
        }
        
        cell.businessName.text = cell.suggestion.name;
        cell.colorView.layer.cornerRadius = 20.0;
        cell.colorView.layer.shadowOffset = CGSizeMake(1, 0);
        cell.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.colorView.layer.shadowRadius = 5;
        cell.colorView.layer.shadowOpacity = .25;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.suggestionSelected){
        return 1;
    } else {
        return self.suggestionsArray.count;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"suggestionSegue"]){
        NSIndexPath *myIndexPath = [self.suggestionsTableView indexPathForCell:sender];
        Suggestion *dataToPass = [[Suggestion alloc] init];
        if (self.sortedArray.count > 0) {
            dataToPass = self.sortedArray[myIndexPath.row];
        } else {
            dataToPass = self.suggestionsArray[myIndexPath.row];
        }
        SuggestionViewController *detailVC = [segue destinationViewController];
        detailVC.delegateObject = self;
        detailVC.detailSuggestion = dataToPass;
        detailVC.detailEvent = self.detailEvent;
    }
}

- (void) didSelectCue:(NSString *)cueId{
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery getObjectInBackgroundWithId:self.eventID
                                      block:^(PFObject *event, NSError *error) {
        if(!error){
            event[@"selectedCue"] = [PFObject objectWithoutDataWithClassName:@"Cue" objectId: cueId];
            event[@"selectedCueId"] = cueId;
            self.suggestionSelected = true;
            self.cuesForYourEventLabel.text = @"Selected Cue:";
            [event saveInBackground];
        } else{
            NSLog(@"No event found");
        }
    }];
    [self _setUpTableView];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilterCell *cell = [self.filtersCollectionView dequeueReusableCellWithReuseIdentifier:@"FilterCell" forIndexPath:indexPath];
    cell.filterName.text = self.filters[indexPath.row];
    cell.backgroundColor = [UIColor colorWithRed: 0.69 green: 0.83 blue: 0.51 alpha: 0.5];
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (void) _getSort:(NSString *) selectedFilter {
    NSSortDescriptor *sortDescriptor;
    if([selectedFilter isEqual:@"Distance"]){
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                     ascending:YES];
    } else if ([selectedFilter isEqual:@"Rating"]) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating"
                                                     ascending:YES];
    }
    NSArray *sorted = [self.suggestionsArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.sortedArray = [sorted mutableCopy];
    [self.suggestionsTableView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    UICollectionViewCell *cell =[self.filtersCollectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed: 0.33 green: 0.62 blue: 0.29 alpha: 0.5];
    NSString *selectedCell = self.filters[indexPath.row];
    [self.selectedFilters addObject:selectedCell];
    [self _getSort: selectedCell];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =[self.filtersCollectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed: 0.69 green: 0.83 blue: 0.51 alpha: 0.5];
    NSString *selectedCell = self.filters[indexPath.row];
    [self.selectedFilters removeObject:selectedCell];
}

@end
