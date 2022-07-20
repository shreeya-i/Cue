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
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, strong) NSString *displayAddress;
@property (nonatomic, strong) NSString *phone;

+(NSArray*)SuggestionWithDictionary:(NSArray*)dictionaries;

@end

NS_ASSUME_NONNULL_END
