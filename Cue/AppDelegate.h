//
//  AppDelegate.h
//  Cue
//
//  Created by Shreeya Indap on 7/5/22.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "GTMAppAuth/GTMAppAuth.h"
#import "OIDServiceConfiguration.h"
#import "OIDExternalUserAgentSession.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) OIDServiceConfiguration * _Nonnull configuration;
@property(nonatomic, nullable)
    id<OIDExternalUserAgentSession> currentAuthorizationFlow;

@end
