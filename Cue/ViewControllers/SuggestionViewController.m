//
//  SuggestionViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/25/22.
//

#import "SuggestionViewController.h"

@interface SuggestionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *businessImage;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *businessPhone;
@property (weak, nonatomic) IBOutlet UILabel *businessAddress;
@property (weak, nonatomic) IBOutlet UILabel *businessRating;
@property (weak, nonatomic) IBOutlet UILabel *businessDistance;
@property (weak, nonatomic) IBOutlet UIButton *selectSuggestion;

@end

@implementation SuggestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.businessName.text = self.detailSuggestion.name;
    self.businessPhone.text = self.detailSuggestion.phone;
    self.businessAddress.text = self.detailSuggestion.displayAddress;
    self.businessRating.text = self.detailSuggestion.rating;
    self.businessDistance.text = [NSString stringWithFormat: @"%@ miles away", self.detailSuggestion.distance];
    
    
    NSURL * url = [NSURL URLWithString: self.detailSuggestion.imageURL];
    NSData * data = [NSData dataWithContentsOfURL:url];
    self.businessImage.image = [UIImage imageWithData:data];
    
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.businessImage.frame.size.width, self.businessImage.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [self.businessImage addSubview:overlay];
}

- (IBAction)didTapSelect:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Would you like to assign this cue to this event?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alert completion:^{}];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alert completion:^{}];
        [self _didSelectCue];
        }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

-(void) _didSelectCue {
    [self.navigationController popViewControllerAnimated:YES];
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
