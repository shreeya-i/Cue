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
@dynamic cuesString;
@dynamic address;
@dynamic selectedCue;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

//To upload the user image to Parse, get the user input from the view controller and then call the postUserImage method from the view controller by passing all the required arguments into it.

+ (void) postEvent: ( NSString * _Nullable )name
          withDate: (NSDate * _Nullable)date
          withCues: (NSArray * _Nullable)cues
        withRadius:(NSNumber * _Nullable)radius
       withAddress:(NSString * _Nullable)address
    withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    NSMutableArray *yelpCategories = [[NSMutableArray alloc] init];
    for (NSString *cue in cues) {
        if([cue isEqual: @"Active life"]){
            [yelpCategories addObject: @"active"];
        }
        if([cue isEqual: @"Restaurants"]){
            [yelpCategories addObject: @"restaurants"];
        }
        if([cue isEqual: @"Arts and entertainment"]){
            [yelpCategories addObject: @"arts"];
        }
        if([cue isEqual: @"Local flavor"]){
            [yelpCategories addObject: @"localflavor"];
        }
        if([cue isEqual: @"Nightlife"]){
            [yelpCategories addObject: @"nightlife"];
        }
        if([cue isEqual: @"Shopping"]){
            [yelpCategories addObject: @"shopping"];
        }
        if([cue isEqual: @"Beauty and spas"]){
            [yelpCategories addObject: @"beautysvc"];
        }
        if([cue isEqual: @"Tours"]){
            [yelpCategories addObject: @"tours"];
        }
        if([cue isEqual: @"Event planning and services"]){
            [yelpCategories addObject: @"eventservices"];
        }
    }
    
    NSArray *cuesArray = [yelpCategories copy];
    
    Event *newEvent = [Event new];
    newEvent.eventName = name;
    newEvent.author = [PFUser currentUser];
    newEvent.eventDate = date;
    newEvent.selectedCues = cuesArray;
    newEvent.searchRadius = radius;
    newEvent.address = address;
    newEvent.cuesString = [cues componentsJoinedByString:@", "];
    
    [newEvent saveInBackgroundWithBlock: completion];
}

@end
