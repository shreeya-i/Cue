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
}

- (IBAction)didTapCreate:(id)sender {
    NSString *eventName = self.nameField.text;
    
    [Event postEvent:eventName withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
       if (error){
            NSLog(@"Error creating event");
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"Successfully created event");
        }
    }];
    
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
