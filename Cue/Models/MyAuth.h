//
//  MyAuth.h
//  Cue
//
//  Created by Shreeya Indap on 7/18/22.
//

#import <Foundation/Foundation.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyAuth : NSObject <GTMFetcherAuthorizationProtocol>

+ (MyAuth *)initWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
