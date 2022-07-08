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

+ (nonnull NSString *)parseClassName {
return @"Event";
}

//To upload the user image to Parse, get the user input from the view controller and then call the postUserImage method from the view controller by passing all the required arguments into it.

+ (void) postEvent: ( NSString * _Nullable )name withCompletion: (PFBooleanResultBlock  _Nullable)completion {

Event *newEvent = [Event new];
newEvent.eventName = name;
newEvent.author = [PFUser currentUser];

[newEvent saveInBackgroundWithBlock: completion];
}

@end
