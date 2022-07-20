//
//  ComposeViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "ComposeViewController.h"
#import "Event.h"
#import "CueCell.h"

@interface ComposeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIButton *cuesButton;
@property (weak, nonatomic) IBOutlet UITableView *cuesTableView;
@property (strong, nonatomic) NSArray *cues;
@property (strong, nonatomic) NSMutableArray *selectedCues;
@property (strong, nonatomic) UNUserNotificationCenter *center;
@property (nonatomic) BOOL notifsOn;

@end

bool isGrantedNotificationAccess;

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isGrantedNotificationAccess = false;
    self.notifsOn = true;
    
    self.cues = [[NSArray alloc]initWithObjects: @"Restaurant Reservation", @"Activity Booking", @"Play Gift Purchase", @"Practical Gift Purchase", nil];
    
    self.cuesTableView.dataSource = self;
    self.cuesTableView.delegate = self;
    self.cuesTableView.rowHeight = 50;
    
    self.selectedCues = [NSMutableArray array];
    
    self.center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    
    [self.center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        isGrantedNotificationAccess = granted;
    }];
    
    //Might want to add this but causes delay going back to home page:
    //self.tabBarController.tabBar.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CueCell" forIndexPath:indexPath];
    cell.isSelected = NO;
    cell.cueLabel.text = self.cues[indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CueCell *cell = [self.cuesTableView cellForRowAtIndexPath:indexPath];
    NSString *cueName = cell.cueLabel.text;
    UIImage *unselected = [UIImage systemImageNamed:@"checkmark.circle"];
    UIImage *selected = [UIImage systemImageNamed:@"checkmark.circle.fill"];
    if(cell.isSelected){
        [cell.selectButton setImage:unselected forState:UIControlStateNormal];
        [self.selectedCues removeObject:cueName];
    } else {
        [cell.selectButton setImage:selected forState:UIControlStateNormal];
        [self.selectedCues addObject:cueName];
    }
    cell.isSelected = !(cell.isSelected);
}

- (IBAction)didTapCreate:(id)sender {
    NSString *eventName = self.nameField.text;
    NSDate *selectedDate = self.datePicker.date;
    NSArray *cuesArray = self.selectedCues;
    NSDate *curDate = [NSDate date];
    NSTimeInterval diff = [selectedDate timeIntervalSinceDate:curDate];
    
    if([eventName isEqual:@""]) {
        [self _emptyFieldAlert];
    }
    else if(diff <= 0){
        [self _pastDateAlert];
    }
    else{
       [Event postEvent:eventName withDate:selectedDate withCues:cuesArray withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
       if (error){
           NSLog(@"Error creating event");
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to create event." preferredStyle:(UIAlertControllerStyleAlert)];
           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
           [alert addAction:okAction];
           [self presentViewController:alert animated:YES completion:^{}];
        }
        else{
            if(isGrantedNotificationAccess && self.notifsOn){
                /// Notifications: DO NOT account for current user which needs to be fixed.
                [self _weekNotif];
                [self _dayNotif];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"Successfully created event");
        }
    }];
    }
    
}

- (void) _emptyFieldAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Event must have a name" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void) _pastDateAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Date has already passed" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

//Week before notification
- (void) _weekNotif {
    NSDate *selectedDate = self.datePicker.date;
    NSString *eventName = self.nameField.text;
    NSDate *curDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:+7];
    NSDate *sevenDays = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:curDate options:0];
    NSTimeInterval weekDiff = [selectedDate timeIntervalSinceDate:sevenDays];
    
    if(weekDiff > 0){
        UNMutableNotificationContent *weekContent = [[UNMutableNotificationContent alloc] init];
        weekContent.title = @"Cue";
        weekContent.body = [NSString stringWithFormat:@"%@ is happening in one week", eventName];
        weekContent.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:weekDiff repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventName content:weekContent trigger:trigger];
        [self.center addNotificationRequest:request withCompletionHandler:nil];
    }
}

//Day before notification:
- (void) _dayNotif {
    NSDate *selectedDate = self.datePicker.date;
    NSString *eventName = self.nameField.text;
    NSDate *curDate = [NSDate date];
    NSDateComponents *dateComponents1 = [[NSDateComponents alloc] init];
    [dateComponents1 setDay:+1];
    NSDate *oneDay = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents1 toDate:curDate options:0];
    NSTimeInterval dayDiff = [selectedDate timeIntervalSinceDate:oneDay];
    
    if(dayDiff > 0){
        UNMutableNotificationContent *dayContent = [[UNMutableNotificationContent alloc] init];
        dayContent.title = @"Cue";
        dayContent.body = [NSString stringWithFormat:@"%@ is happening in one day", eventName];
        dayContent.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:dayDiff repeats:NO];
        UNNotificationRequest *request1 = [UNNotificationRequest requestWithIdentifier:eventName content:dayContent trigger:trigger1];
        [self.center addNotificationRequest:request1 withCompletionHandler:nil];
    }
    
}

- (IBAction)switchPressed:(id)sender {
    if([self.notificationSwitch isOn]){
        self.notifsOn = YES;
        NSLog(@"%i", self.notifsOn);
    }
    else{
        self.notifsOn = NO;
        NSLog(@"%i", self.notifsOn);
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
