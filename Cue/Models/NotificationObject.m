//
//  NotificationObject.m
//  Cue
//
//  Created by Shreeya Indap on 7/28/22.
//

#import "NotificationObject.h"

@implementation NotificationObject

@dynamic user;
@dynamic text;
@dynamic postDate;

+ (nonnull NSString *)parseClassName {
    return @"Notification";
}

+ (void) createNotification:(NSString *)text
                   withDate:(NSDate *)date
             withCompletion:(PFBooleanResultBlock)completion {
    NotificationObject *newNotif = [NotificationObject new];
    newNotif.text = text;
    newNotif.user = [PFUser currentUser];
    newNotif.postDate = date;

[newNotif saveInBackgroundWithBlock: completion];
}


@end
