//
//  HomeViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

NS_ASSUME_NONNULL_END
