//
//  ComposeViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "ComposeViewController.h"
#import "Event.h"
#import "CueCell.h"
#import "NotificationObject.h"

@interface ComposeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *addressSwitch;
@property (weak, nonatomic) IBOutlet UITableView *cuesTableView;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *sliderValueLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) NSArray *cues;
@property (strong, nonatomic) NSMutableArray *selectedCues;
@property (strong, nonatomic) UNUserNotificationCenter *center;
@property (nonatomic) BOOL notifsOn;
@property (nonatomic, strong) NSNumber *selectedRadius;
@property (nonatomic, strong) NSString *inputtedAddress;
@property (nonatomic, strong) NSString *addressToUse;

@end

bool isGrantedNotificationAccess;

@implementation ComposeViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    if([self.segueType isEqual: @"editSegue"]){
        [self _setUpEdit];
    } else {
        [self _setUpCompose];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    
    isGrantedNotificationAccess = false;
    self.notifsOn = true;
    
    self.cues = [[NSArray alloc]initWithObjects: @"Active life", @"Restaurants", @"Arts and entertainment", @"Local flavor", @"Nightlife", @"Shopping", @"Beauty and spas", @"Tours", @"Event planning and services", nil];
    
    self.colorView.layer.cornerRadius = 20.0;
    self.colorView.clipsToBounds = YES;
    
    self.createButton.layer.cornerRadius = 15.0;
    [self.createButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    
    self.cuesTableView.dataSource = self;
    self.cuesTableView.delegate = self;
    self.cuesTableView.rowHeight = 50;
    
    self.selectedCues = [NSMutableArray array];
    
    self.center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    
    [self.center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        isGrantedNotificationAccess = granted;
    }];
}

- (void) _setUpEdit {
    self.pageTitle.text = @"Edit Event";
    self.nameField.placeholder = self.detailEvent.eventName;
    NSLog(@"%@", self.detailEvent.eventName);
}

- (void) _setUpCompose {
    self.pageTitle.text = @"Compose Event";
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

- (IBAction)didChangeRadius:(id)sender {
    NSNumber *newRadius = @((int) self.distanceSlider.value);
    NSString *stringValue = [newRadius stringValue];
    self.selectedRadius = newRadius;
    self.sliderValueLabel.text = [NSString stringWithFormat:@"%@ meters", stringValue];
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
        if(self.inputtedAddress) {
            self.addressToUse = self.inputtedAddress;
        } else {
            self.addressToUse = [PFUser currentUser][@"address"];
        }
        __weak typeof(self) weakSelf = self;
        [Event postEvent:eventName withDate:selectedDate withCues:cuesArray withRadius: self.selectedRadius withAddress: self.addressToUse withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error){
                __strong typeof(self) strongSelf = weakSelf;
                NSLog(@"Error creating event");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to create event." preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
                [alert addAction:okAction];
                [strongSelf presentViewController:alert animated:YES completion:^{}];
            }
            else{
                __strong typeof(self) strongSelf = weakSelf;
                if(isGrantedNotificationAccess && self.notifsOn){
                    /// Notifications: DO NOT account for current user which needs to be fixed.
                    [strongSelf _weekNotif];
                    [strongSelf _dayNotif];
                }
                
                [strongSelf.navigationController popViewControllerAnimated:YES];
                strongSelf.tabBarController.tabBar.hidden = NO;
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
    NSDateComponents *increaseWeek = [[NSDateComponents alloc] init];
    [increaseWeek setDay:+7];
    NSDate *sevenDaysAfter = [[NSCalendar currentCalendar] dateByAddingComponents:increaseWeek toDate:curDate options:0];
    NSTimeInterval weekDiff = [selectedDate timeIntervalSinceDate:sevenDaysAfter];
    
    if(weekDiff > 0){
        NSString *notificationText = [NSString stringWithFormat:@"%@ is happening in one week", eventName];
        
        UNMutableNotificationContent *weekContent = [[UNMutableNotificationContent alloc] init];
        weekContent.title = @"Cue";
        weekContent.body = notificationText;
        weekContent.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:weekDiff repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventName content:weekContent trigger:trigger];
        [self.center addNotificationRequest:request withCompletionHandler:nil];
        
        NSDateComponents *decreaseWeek = [[NSDateComponents alloc] init];
        [decreaseWeek setDay:-7];
        NSDate *sevenDaysBefore = [[NSCalendar currentCalendar] dateByAddingComponents:decreaseWeek toDate:selectedDate options:0];
        
        [NotificationObject createNotification:notificationText withDate:sevenDaysBefore withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error){
                NSLog(@"Error creating notification");
            }
            else{
                NSLog(@"Successfully created week notification");
            }
        }];
    }
}

//Day before notification:
- (void) _dayNotif {
    NSDate *selectedDate = self.datePicker.date;
    NSString *eventName = self.nameField.text;
    NSDate *curDate = [NSDate date];
    NSDateComponents *increaseOneDay = [[NSDateComponents alloc] init];
    [increaseOneDay setDay:+1];
    NSDate *oneDay = [[NSCalendar currentCalendar] dateByAddingComponents:increaseOneDay toDate:curDate options:0];
    NSTimeInterval dayDiff = [selectedDate timeIntervalSinceDate:oneDay];
    
    if(dayDiff > 0){
        NSString *notificationText = [NSString stringWithFormat:@"%@ is happening in one day", eventName];
        
        UNMutableNotificationContent *dayContent = [[UNMutableNotificationContent alloc] init];
        dayContent.title = @"Cue";
        dayContent.body = notificationText;
        dayContent.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:dayDiff repeats:NO];
        UNNotificationRequest *request1 = [UNNotificationRequest requestWithIdentifier:eventName content:dayContent trigger:trigger1];
        [self.center addNotificationRequest:request1 withCompletionHandler:nil];
        
        NSDateComponents *decreaseDay = [[NSDateComponents alloc] init];
        [decreaseDay setDay:-1];
        NSDate *sevenDaysBefore = [[NSCalendar currentCalendar] dateByAddingComponents:decreaseDay toDate:selectedDate options:0];
        
        [NotificationObject createNotification:notificationText withDate:sevenDaysBefore withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error){
                NSLog(@"Error creating notification");
            }
            else{
                NSLog(@"Successfully created day notification");
            }
        }];
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

- (IBAction)addressSwitchPressed:(id)sender {
    if(![self.addressSwitch isOn]){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Input Address"
                                                                                  message: @"Input location for this event."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Address";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField * addressField = textfields[0];
            self.inputtedAddress = addressField.text;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
