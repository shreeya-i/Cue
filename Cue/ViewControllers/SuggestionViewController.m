//
//  SuggestionViewController.m
//  Cue
//
//  Created by Shreeya Indap on 7/25/22.
//

#import "SuggestionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cue.h"

@interface SuggestionViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *businessImage;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *businessAddress;
@property (weak, nonatomic) IBOutlet UILabel *businessRating;
@property (weak, nonatomic) IBOutlet UILabel *businessDistance;
@property (weak, nonatomic) IBOutlet UIButton *selectSuggestion;
@property (weak, nonatomic) IBOutlet UILabel *businessPrice;
@property (strong, nonatomic) NSString *businessPhone;

@end

@implementation SuggestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.businessName.text = self.detailSuggestion.name;
    self.businessPhone = self.detailSuggestion.phone;
    self.businessAddress.text = self.detailSuggestion.displayAddress;
    self.businessRating.text = self.detailSuggestion.rating;
    self.businessPrice.text = self.detailSuggestion.price;
    self.businessDistance.text = [NSString stringWithFormat: @"%@ mi", self.detailSuggestion.distance];
    
    
    NSURL * url = [NSURL URLWithString: self.detailSuggestion.imageURL];
    NSData * data = [NSData dataWithContentsOfURL:url];
    self.businessImage.image = [UIImage imageWithData:data];
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.businessImage.frame.size.width, self.businessImage.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [self.businessImage addSubview:overlay];
    self.businessImage.layer.cornerRadius = 20;
    self.businessImage.layer.masksToBounds = YES;
    
    [self _setUpMap];
}

- (void) _setUpMap {
    
    NSNumber *latitude = self.detailSuggestion.latitude;
    NSNumber *longitude = self.detailSuggestion.longitude;
    
    //set mapView location
    CLLocationCoordinate2D coord = {.latitude = [latitude doubleValue], .longitude = [longitude doubleValue]};
    MKCoordinateSpan span = {.latitudeDelta = 0.010f, .longitudeDelta = 0.010f};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];
    
    //set pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordforpin = {.latitude = [latitude doubleValue], .longitude = [longitude doubleValue]};
    [annotation setCoordinate:coordforpin];
    [annotation setTitle:self.detailSuggestion.name];
    [self.mapView addAnnotation: annotation];
}
- (IBAction)didTapCall:(id)sender {
    //This phone would theoretically be replaced with a formatted _businessPhone
    NSString *phoneStr = [NSString stringWithFormat:@"tel:9493784844"];
    NSURL *phoneURL = [NSURL URLWithString:phoneStr];
    [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:nil];
}

- (IBAction)didTapSelect:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Would you like to assign this cue to this event?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alert completion:^{}];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alert completion:^{}];
        [self _didSelectCue:self.detailSuggestion];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

-(void) _didSelectCue:(Suggestion*)detailSuggestion {
    [Cue createCue:detailSuggestion.name withImageURL:detailSuggestion.imageURL withDistance:detailSuggestion.distance withPhone:detailSuggestion.phone withRating:detailSuggestion.rating withPrice:detailSuggestion.price withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error selecting Cue");
        }
        else{
            NSLog(@"Successfully selected cue");
        }
    }];
    [self.delegateObject didSelectCue:detailSuggestion];
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
