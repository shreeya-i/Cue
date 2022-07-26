//
//  GoogleViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/19/22.
//

#import "GoogleViewController.h"
#import "GoogleCell.h"
#import "GCAEvent.h"
#import "Event.h"

@interface GoogleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *selectedEvents;

@end

@implementation GoogleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
    self.eventsTableView.rowHeight = 100;
    
    self.selectedEvents = [NSMutableArray array];
    
    NSArray *eventsData = self.importedEvents[@"items"];
    self.events = [NSMutableArray array];
    for (NSDictionary *anEvent in eventsData) {
        GCAEvent *event = [GCAEvent new];

        event.content = anEvent[@"summary"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, MMM d"];

        //TODO: check date vs datetime is null, if second then split the string
        
        NSString *startDate = anEvent[@"start"][@"date"];
        NSString *startDateTime = anEvent[@"start"][@"dateTime"];
        event.startDate = [dateFormatter dateFromString:startDate];
        
        NSLog(@"1 %@", startDate);
        NSLog(@"2 %@", startDateTime);
        NSLog(@"3 %@", [dateFormatter stringFromDate:event.startDate]);
        
//        NSDateComponents *comps = [[NSDateComponents alloc] init];
//        [comps setDay:10];
//        [comps setMonth:10];
//        [comps setYear:2022];
//        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
//        event.startDate = date;

        [self.events addObject:event];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return self.importedEvents.count;
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GoogleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoogleCell" forIndexPath:indexPath];
    cell.event = self.events[indexPath.row];
    cell.eventName.text = cell.event.content;
    cell.isSelected = NO;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GoogleCell *cell = [self.eventsTableView cellForRowAtIndexPath:indexPath];
    GCAEvent *event = cell.event;
    if(cell.isSelected){
        [self.selectedEvents removeObject:event];
    } else {
        [self.selectedEvents addObject:event];
    }
    cell.isSelected = !(cell.isSelected);
}

- (IBAction)didTapImport:(id)sender {
    NSArray *cues = [NSArray array];
    for(GCAEvent *event in self.selectedEvents){
        [Event postEvent:event.content withDate:event.startDate withCues:cues withRadius:@1000 withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
       if (error){
           NSLog(@"Error creating event");
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to create event." preferredStyle:(UIAlertControllerStyleAlert)];
           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
           [alert addAction:okAction];
           [self presentViewController:alert animated:YES completion:^{}];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"Successfully created event");
        }
    }];
    }
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
