//
//  SuggestionCell.h
//  Cue
//
//  Created by Shreeya Indap on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Suggestion.h"

NS_ASSUME_NONNULL_BEGIN

@interface SuggestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (nonatomic, strong) Suggestion *suggestion;

@end

NS_ASSUME_NONNULL_END
