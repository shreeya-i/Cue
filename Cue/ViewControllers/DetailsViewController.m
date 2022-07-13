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

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.suggestionsTableView.delegate = self;
    self.suggestionsTableView.dataSource = self;
    self.suggestionsTableView.rowHeight = 170;
    
    self.nameLabel.text = self.detailEvent.eventName;
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEE, MMM d"];
    NSString *stringFromDate = [dayFormatter stringFromDate:self.detailEvent.eventDate];
    self.dayLabel.text = stringFromDate;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *timeFromDate = [timeFormatter stringFromDate:self.detailEvent.eventDate];
    self.timeLabel.text = timeFromDate;
    
    [self fetchData];
    
}

- (void) fetchData{
//    NSURL *url = [NSURL URLWithString:@"http://api.yelp.com/v3/businesses/search"];
//    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
////    [request setValue:@"Bearer APIKEY" forKey:@"Authorization"];
//    [request setValue:@"Bearer APIKEY" forHTTPHeaderField:@"Authorization"];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//
//    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//        if(error) {
//
//        } else {
//            NSLog(@"%@", responseObject);
//        }
//    }];
//
//    [task resume];
//
////    [manager GET:@"http://api.yelp.com/v3/businesses/search" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
////
////    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////
////    }];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
     cell.suggestion = self.suggestionsArray[indexPath.row];
     cell.businessName.text = cell.suggestion.businessName;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
