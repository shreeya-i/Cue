//
//  NotificationObject.h
//  Cue
//
//  Created by Shreeya Indap on 7/28/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationObject : PFObject <PFSubclassing>

//@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *postDate;

// Param text: Notification text
// Param date: Date of notification to be posted
+ (void) createNotification: ( NSString * _Nullable )text
                   withDate: ( NSDate * _Nullable )date
             withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
