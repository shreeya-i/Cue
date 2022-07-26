//
//  Suggestion.m
//  Cue
//
//  Created by Shreeya Indap on 7/12/22.
//

#import "Suggestion.h"

@implementation Suggestion

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self)
    {
        self.name = dictionary[@"name"];
        self.imageURL = dictionary [@"image_url"];
        
        NSArray *addressComponents = dictionary[@"location"][@"display_address"];
        self.displayAddress = [addressComponents componentsJoinedByString:@", "];
        
        float milesPerMeter = 0.000621371;
        float originalDist = [dictionary[@"distance"] integerValue] * milesPerMeter;
        NSString* formattedDist = [NSString stringWithFormat:@"%.02f", originalDist];
        self.distance = formattedDist;
        
        float originalRating = [dictionary[@"rating"] integerValue];
        NSString* formattedRating = [NSString stringWithFormat:@"%.01f", originalRating];
        self.rating = formattedRating;
        
        self.phone = dictionary[@"display_phone"];
     
    }
    return self;
}

+(NSArray*)SuggestionWithDictionary:(NSArray*)dictionaries
{
    NSMutableArray *suggestions = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in dictionaries)
    {
        Suggestion *suggestion = [[Suggestion alloc] initWithDictionary:dict];
        [suggestions addObject:suggestion];
    }
    return suggestions;
}


@end
