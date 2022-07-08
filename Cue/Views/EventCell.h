//
//  EventCell.h
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

NS_ASSUME_NONNULL_END
