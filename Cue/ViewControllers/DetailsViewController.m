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
@property (nonatomic, strong) NSString *eventCategories;
@property (nonatomic, strong) NSArray *suggestionsArray;
@property (nonatomic, strong) NSMutableArray <NSString *> *selectedFilters;
@property (nonatomic, strong) Suggestion *selectedSuggestion;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) NSMutableArray *sortedArray;

@end

@implementation DetailsViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setUpViews];
    if(self.selectedSuggestion){
        [self _setUpTableView];
    } else {
        [self _dispatchInfo];
    }
}

- (void) _dispatchInfo {
    [SVProgressHUD show];
    dispatch_queue_t getSuggestionsQueue = dispatch_queue_create("Get Yelp Events", NULL);
    dispatch_async(getSuggestionsQueue, ^{
        [self _fetchData];
    });
}

- (void) _setUpViews {
    
    self.filters = @[@"Rating", @"Distance"];
    self.filtersCollectionView.dataSource = self;
    self.filtersCollectionView.delegate = self;
    
    self.noSuggestionsLabel.hidden = YES;
    
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
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error) {
            [SVProgressHUD dismiss];
            self.noSuggestionsLabel.hidden = NO;
            NSLog(@"error");
        } else {
            NSLog(@"%@", responseObject);
            NSArray *suggestionDictionary = responseObject[@"businesses"];
            self.suggestionsArray = [Suggestion SuggestionWithDictionary:suggestionDictionary];
            [self.sortedArray removeAllObjects];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if(self.suggestionsArray.count == 0){
                    self.noSuggestionsLabel.hidden = NO;
                }
                [self _setUpTableView];
            });
        }
    }];
    [task resume];
}

- (void) _setUpTableView {
    self.suggestionsTableView.delegate = self;
    self.suggestionsTableView.dataSource = self;
    if(self.selectedSuggestion){
        self.suggestionsTableView.rowHeight = 200;
    } else {
        self.suggestionsTableView.rowHeight = 115;
    }
    [self.suggestionsTableView reloadData];
}

- (IBAction)refreshData:(id)sender {
    [self _fetchData];
    [self.suggestionsTableView reloadData];
    [self.filtersCollectionView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectedSuggestion){
        YelpSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YelpSelectionCell" forIndexPath:indexPath];
        cell.detailSuggestion = self.selectedSuggestion;
        cell.businessName.text = cell.detailSuggestion.name;
        cell.distanceLabel.text = cell.detailSuggestion.distance;
        cell.ratingLabel.text = cell.detailSuggestion.rating;
        
        NSURL * url = [NSURL URLWithString: cell.detailSuggestion.imageURL];
        NSData * data = [NSData dataWithContentsOfURL:url];
        cell.businessImage.image = [UIImage imageWithData:data];
        
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
    if(self.selectedSuggestion){
        return 1;
    } else {
        return self.suggestionsArray.count;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"suggestionSegue"]){
        NSIndexPath *myIndexPath = [self.suggestionsTableView indexPathForCell:sender];
        Suggestion *dataToPass = self.suggestionsArray[myIndexPath.row];
        SuggestionViewController *detailVC = [segue destinationViewController];
        detailVC.delegateObject = self;
        detailVC.detailSuggestion = dataToPass;
        detailVC.detailEvent = self.detailEvent;
    }
}

- (void) didSelectCue:(Suggestion *)suggestionToSend {
    self.selectedSuggestion = suggestionToSend;
    [self _setUpTableView];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilterCell *cell = [self.filtersCollectionView dequeueReusableCellWithReuseIdentifier:@"FilterCell" forIndexPath:indexPath];
    cell.filterName.text = self.filters[indexPath.row];
    cell.backgroundColor = [UIColor colorWithRed: 0.92 green: 0.95 blue: 0.84 alpha: 1.00];
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
    cell.backgroundColor = [UIColor colorWithRed: 0.56 green: 0.78 blue: 0.58 alpha: 1.00];
    NSString *selectedCell = self.filters[indexPath.row];
    [self.selectedFilters addObject:selectedCell];
    [self _getSort: selectedCell];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =[self.filtersCollectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed: 0.92 green: 0.95 blue: 0.84 alpha: 1.00];
    NSString *selectedCell = self.filters[indexPath.row];
    [self.selectedFilters removeObject:selectedCell];
}

@end
