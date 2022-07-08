//
//  Event.h
//  Cue
//
//  Created by Shreeya Indap on 7/7/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDate *eventDate;

+ (void) postEvent: ( NSString * _Nullable )name withDate: ( NSDate * _Nullable )date withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END