//
//  Cue.m
//  Cue
//
//  Created by Shreeya Indap on 8/1/22.
//

#import "Cue.h"

@implementation Cue

@dynamic name;
@dynamic imageURL;
@dynamic distance;
@dynamic phone;
@dynamic rating;
@dynamic price;

+ (nonnull NSString *)parseClassName {
    return @"Cue";
}

+ (void) createCue:(NSString *)name withImageURL:(NSString *)imageURL withDistance:(NSString *)distance withPhone:(NSString *)phone withRating:(NSString *)rating withPrice:(NSString *)price withCompletion:(PFBooleanResultBlock)completion {
    Cue *selectedCue = [Cue new];
    [selectedCue saveInBackgroundWithBlock: completion];
}

@end
