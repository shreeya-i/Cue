//
//  Notification.m
//  Cue
//
//  Created by Shreeya Indap on 7/18/22.
//

#import "Notification.h"

@implementation Notification

@dynamic user;
@dynamic text;
@dynamic postDate;

+ (nonnull NSString *)parseClassName { 
    return @"Notification";
}

+ (void) createNotification:(NSString *)text
                   withDate:(NSDate *)date
             withCompletion:(PFBooleanResultBlock)completion {
Notification *newNotif = [Notification new];
    newNotif.text = text;
    newNotif.user = [PFUser currentUser];
    newNotif.postDate = date;

[newNotif saveInBackgroundWithBlock: completion];
}


@end
