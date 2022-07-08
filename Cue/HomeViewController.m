//
//  HomeViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "HomeViewController.h"
#import "ComposeViewController.h"
#import "EventCell.h"
@import Parse;

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *eventsArray;

@end

@implementation HomeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.eventsTableView reloadData];
    [self fetchEvents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViews];
    [self fetchEvents];
}

- (void) setUpViews {
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchEvents) forControlEvents:UIControlEventValueChanged];
    [self.eventsTableView insertSubview:self.refreshControl atIndex:0];
    
    self.eventsTableView.delegate = self;
    self.eventsTableView.dataSource = self;
    self.eventsTableView.rowHeight = 225;
}

- (void)fetchEvents {
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery orderByDescending:@"createdAt"];
    [eventQuery whereKey:@"author" equalTo: [PFUser currentUser]];
    eventQuery.limit = 20;

    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            self.eventsArray = [NSMutableArray arrayWithArray:events];
            [self.eventsTableView reloadData];
            [self.refreshControl endRefreshing];
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
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.eventsArray.count;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell
 *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
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
