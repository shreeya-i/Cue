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

@end

@implementation SuggestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.businessName.text = self.detailSuggestion.name;
    self.businessPhone.text = self.detailSuggestion.phone;
    
    NSURL * url = [NSURL URLWithString: self.detailSuggestion.imageURL];
    NSData * data = [NSData dataWithContentsOfURL:url];
    self.businessImage.image = [UIImage imageWithData:data];
    
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.businessImage.frame.size.width, self.businessImage.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [self.businessImage addSubview:overlay];
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
