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
@import Parse;

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *eventsArray;
@property (weak, nonatomic) IBOutlet UILabel *noEventsLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaysDay;
@property (weak, nonatomic) IBOutlet UILabel *todaysDate;

@end

@implementation HomeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.noEventsLabel.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    [self.eventsTableView reloadData];
    [self fetchEvents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViews];
    [self fetchEvents];
}

- (void) setUpViews {
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(fetchEvents) forControlEvents:UIControlEventValueChanged];
//    [self.eventsTableView insertSubview:self.refreshControl atIndex:0];
    
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

- (void)fetchEvents {
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

- (IBAction)didTapCompose:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ComposeViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ComposeViewController"];
    [self.navigationController pushViewController:controller animated:YES];
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
