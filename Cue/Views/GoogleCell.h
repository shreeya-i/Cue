//
//  GoogleCell.h
//  Cue
//
//  Created by Shreeya Indap on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "GCAEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) GCAEvent *event;
@property (nonatomic) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
