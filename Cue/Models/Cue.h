//
//  Cue.h
//  Cue
//
//  Created by Shreeya Indap on 8/1/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Cue : PFObject  <PFSubclassing>

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *objectId;

// Param name: Name of suggestion (cue) being selected to assign to an event
+ (void) createCue: ( NSString * _Nullable )name
      withImageURL: ( NSString * _Nullable )imageURL
      withDistance: ( NSString * _Nullable )distance
         withPhone: ( NSString * _Nullable )phone
        withRating: ( NSString * _Nullable )rating
         withPrice: ( NSString * _Nullable )price
    withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
