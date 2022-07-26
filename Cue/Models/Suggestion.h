//
//  Suggestion.h
//  Cue
//
//  Created by Shreeya Indap on 7/12/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN
 
@interface Suggestion : NSObject

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *displayAddress;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *rating;


+(NSArray*)SuggestionWithDictionary:(NSArray*)dictionaries;

@end

NS_ASSUME_NONNULL_END
