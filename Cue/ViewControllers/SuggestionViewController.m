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
