//
//  LoginViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "GTMAppAuthFetcherAuthorization.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController

@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

@end

NS_ASSUME_NONNULL_END
