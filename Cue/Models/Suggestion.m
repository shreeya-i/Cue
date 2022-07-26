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
//        NSArray *categories = dictionary[@"categories"];
//        NSMutableArray *categoryNames = [NSMutableArray array];
//        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [categoryNames addObject:obj[0]];
//        } ];
//        self.categories = [categoryNames componentsJoinedByString:@", "];
        
        self.name = dictionary[@"name"];
        self.imageURL = dictionary [@"image_url"];
        NSArray *location = [dictionary valueForKeyPath:@"location.address"];
        
        if(location.count > 0)
        {
            NSString *street = [dictionary valueForKeyPath:@"location.address"][0];
            NSString *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
            self.address = [NSString stringWithFormat:@"%@, %@",street,neighborhood];
        
            NSArray *address = [dictionary valueForKeyPath:@"location.display_address"];
            self.displayAddress = [address componentsJoinedByString:@", "];
            
        }
        else
        {
            self.address = @"";
        }
        
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
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
