//
//  Notification.h
//  Cue
//
//  Created by Shreeya Indap on 7/18/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Notification : PFObject <PFSubclassing>

//@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *postDate;

// Param name: Name of event
// Param date: Date of event
// Param cues: Array of cues the user has requested e.g. Restaurant reservation or activity booking
+ (void) createNotification: ( NSString * _Nullable )text
          withDate: ( NSDate * _Nullable )date
          withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
