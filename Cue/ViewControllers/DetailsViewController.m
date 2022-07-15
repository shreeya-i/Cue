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

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSMutableArray *suggestionsArray;
@property (strong, nonatomic) NSMutableArray *selectedSuggestions;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    //[self fetchData];
}

- (void) setUpViews {
    self.suggestionsTableView.delegate = self;
    self.suggestionsTableView.dataSource = self;
    self.suggestionsTableView.rowHeight = 170;
    
    self.nameLabel.text = self.detailEvent.eventName;
    
    self.selectedSuggestions = [NSMutableArray array];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEE, MMM d"];
    NSString *stringFromDate = [dayFormatter stringFromDate:self.detailEvent.eventDate];
    self.dayLabel.text = stringFromDate;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *timeFromDate = [timeFormatter stringFromDate:self.detailEvent.eventDate];
    self.timeLabel.text = timeFromDate;
}

//- (void) fetchData{
//
//    NSString *apiKey = [[NSUserDefaults standardUserDefaults]
//        stringForKey:@"apiKey"];
//    NSString *header = [NSString stringWithFormat:@"Bearer %@", apiKey];
//
//    //NSDictionary *params = @{@"location": @"1950 Wyatt Drive Santa Clara", @"radius": @5};
//    NSDictionary *params = @{@"location": @"1950 Wyatt Drive Santa Clara"};
//    NSURL *url = [NSURL URLWithString:@"http://api.yelp.com/v3/businesses/search"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setValue:header forHTTPHeaderField:@"Authorization"];
//    [request setHTTPBody:[self httpBodyForParameters:params]];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if(error) {
//            NSLog(@"error");
//        } else {
//            NSLog(@"%@", responseObject);
//        }
//    }];
//
////    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
////        if (error) {
////            NSLog(@"dataTaskWithRequest error: %@", error);
////        }
////        else{
////            NSLog(@"%@", response);
////        }
////    }];
//   [task resume];
//
//////    [manager GET:@"http://api.yelp.com/v3/businesses/search" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//////
//////    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//////
//////    }];
//
//
//}
//
//- (NSData *)httpBodyForParameters:(NSDictionary *)parameters {
//    NSMutableArray *parameterArray = [NSMutableArray array];
//
//    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
//        NSString *param = [NSString stringWithFormat:@"%@=%@", [self percentEscapeString:key], [self percentEscapeString:obj]];
//        [parameterArray addObject:param];
//    }];
//
//    NSString *string = [parameterArray componentsJoinedByString:@"&"];
//    return [string dataUsingEncoding:NSUTF8StringEncoding];
//}
//
//- (NSString *)percentEscapeString:(NSString *)string {
//    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
//    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
    cell.isSelected = NO;
    //cell.suggestion = self.suggestionsArray[indexPath.row];
    //cell.businessName.text = cell.suggestion.businessName;
    cell.businessName.text = @"Sample Business";
    
    cell.colorView.layer.cornerRadius = 20.0;
    cell.colorView.layer.shadowOffset = CGSizeMake(1, 0);
    cell.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.colorView.layer.shadowRadius = 5;
    cell.colorView.layer.shadowOpacity = .25;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SuggestionCell *cell = [self.suggestionsTableView cellForRowAtIndexPath:indexPath];
    NSString *suggestion = cell.businessName.text;
    if(cell.isSelected){
        [self.selectedSuggestions removeObject:suggestion];
    } else {
        [self.selectedSuggestions addObject:suggestion];
    }
    cell.isSelected = !(cell.isSelected);
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
