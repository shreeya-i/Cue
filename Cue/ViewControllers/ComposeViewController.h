//
//  ComposeViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposeViewController : UIViewController

@property (nonatomic, strong) NSString *segueType;
@property (nonatomic, strong) Event *detailEvent;

@end

NS_ASSUME_NONNULL_END
