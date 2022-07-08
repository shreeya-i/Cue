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

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
