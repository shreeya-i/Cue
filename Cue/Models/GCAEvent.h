//
//  GCAEvent.h
//  Cue
//
//  Created by Shreeya Indap on 7/19/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCAEvent : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *startDate;

@end

NS_ASSUME_NONNULL_END
