//
//  YelpSelectionCell.h
//  Cue
//
//  Created by Shreeya Indap on 7/27/22.
//

#import <UIKit/UIKit.h>
#import "Suggestion.h"

NS_ASSUME_NONNULL_BEGIN

@interface YelpSelectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *businessImage;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) Suggestion *detailSuggestion;

@end

NS_ASSUME_NONNULL_END
