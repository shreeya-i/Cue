//
//  ComposeViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import "ComposeViewController.h"
#import "Event.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

bool isGrantedNotificationAccess;

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isGrantedNotificationAccess = false;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        isGrantedNotificationAccess = granted;
    }];
    
    //Might want to add this but causes delay going back to home page:
    //self.tabBarController.tabBar.hidden = YES;
}

- (IBAction)didTapCreate:(id)sender {
    NSString *eventName = self.nameField.text;
    NSDate *selectedDate = self.datePicker.date;
    
    if([eventName isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Event must have a name" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
    else{
    [Event postEvent:eventName withDate:selectedDate withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
       if (error){
           NSLog(@"Error creating event");
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to create event." preferredStyle:(UIAlertControllerStyleAlert)];
           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
           [alert addAction:okAction];
           [self presentViewController:alert animated:YES completion:^{}];
        }
        else{
            if(isGrantedNotificationAccess){
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = @"Cue";
                content.body = @"An important date is coming up";
                content.sound = [UNNotificationSound defaultSound];
                
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
                
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"TestNotification" content:content trigger:trigger];
                
                [center addNotificationRequest:request withCompletionHandler:nil];
            }
            
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
