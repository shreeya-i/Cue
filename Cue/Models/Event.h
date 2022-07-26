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
@property (nonatomic, strong) NSArray *selectedCues;
@property (nonatomic, strong) NSNumber *searchRadius;
@property (nonatomic, strong) NSString *cuesString;


// Param name: Name of event
// Param date: Date of event
// Param cues: Array of cues the user has requested e.g. Restaurant reservation or activity booking
+ (void) postEvent: ( NSString * _Nullable )name
          withDate: ( NSDate * _Nullable )date
          withCues: ( NSArray * _Nullable )cues
          withRadius: ( NSNumber * _Nullable)radius
    withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
