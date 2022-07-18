//
//  HomeViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "GTMAppAuthFetcherAuthorization.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet UIButton *userInfoButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

@end

NS_ASSUME_NONNULL_END
