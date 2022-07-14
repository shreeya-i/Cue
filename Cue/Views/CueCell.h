//
//  CueCell.h
//  Cue
//
//  Created by Shreeya Indap on 7/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cueLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
