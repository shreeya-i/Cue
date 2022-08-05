//
//  GoogleViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/19/22.
//

#import <Foundation/Foundation.h>
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
    self.eventsTableView.rowHeight = 160;
    
    self.selectedEvents = [NSMutableArray array];
    
    NSArray *eventsData = self.importedEvents[@"items"];
    self.events = [NSMutableArray array];
    for (NSDictionary *anEvent in eventsData) {
        GCAEvent *event = [GCAEvent new];
        
        event.content = anEvent[@"summary"];
        
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        NSString *startDate = anEvent[@"start"][@"date"];
        NSString *startDateTime = anEvent[@"start"][@"dateTime"];
        
        if(!startDate){
            event.startDate = [dateFormatter2 dateFromString:startDateTime];
        } else {
            event.startDate = [dateFormatter1 dateFromString:startDate];
        }
        
        [self.events addObject:event];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%lu", (unsigned long)self.events.count);
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GoogleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoogleCell" forIndexPath:indexPath];
    cell.event = self.events[indexPath.row];
    cell.eventName.text = cell.event.content;
    
    cell.colorView.layer.cornerRadius = 20.0;
    cell.colorView.layer.shadowOffset = CGSizeMake(1, 0);
    cell.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.colorView.layer.shadowRadius = 5;
    cell.colorView.layer.shadowOpacity = .25;
    
    NSDateFormatter *dateformatter =[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"MMM d, yyyy"];
    NSString *date = [dateformatter stringFromDate: cell.event.startDate];
    cell.startDate.text = date;
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
        NSString *address = [PFUser currentUser][@"address"];
        [Event postEvent:event.content withDate:event.startDate withCues:cues withRadius:@1000 withAddress:address withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
