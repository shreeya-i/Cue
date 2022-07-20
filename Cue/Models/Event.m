//
//  Event.m
//  Cue
//
//  Created by Shreeya Indap on 7/7/22.
//

#import "Event.h"

@implementation Event

@dynamic eventID;
@dynamic author;
@dynamic eventName;
@dynamic eventDate;
@dynamic selectedCues;
@dynamic searchRadius;

+ (nonnull NSString *)parseClassName {
return @"Event";
}

//To upload the user image to Parse, get the user input from the view controller and then call the postUserImage method from the view controller by passing all the required arguments into it.

+ (void) postEvent: ( NSString * _Nullable )name
          withDate: (NSDate * _Nullable)date
          withCues: (NSArray * _Nullable)cues
          withRadius:(NSNumber * _Nullable)radius
        withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Event *newEvent = [Event new];
    newEvent.eventName = name;
    newEvent.author = [PFUser currentUser];
    newEvent.eventDate = date;
    newEvent.selectedCues = cues;
    newEvent.searchRadius = radius;
    
[newEvent saveInBackgroundWithBlock: completion];
}

@end
