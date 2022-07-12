//
//  YelpClient.m
//  Cue
//
//  Created by Shreeya Indap on 7/12/22.
//

#import "YelpClient.h"

@implementation YelpClient

//- (id)initWithClientID:(NSString *)clientID apiKey:(NSString *)apiKey {
//    NSURL *baseURL = [NSURL URLWithString:@"http://api.yelp.com/v3/"];
//    self = [super initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
//        if (self) {
//            BDBOAuth1Credential *token = [BDBOAuth1Credential credentialWithToken:accessToken secret:accessSecret expiration:nil];
//            [self.requestSerializer saveAccessToken:token];
//        }
//        return self;
//}

- (AFHTTPRequestOperation *)searchForTerm:(NSString *)term Latitude:(double)latitude Longitude:(double)longitude Radius:(double)radius Success:(void (^)(AFHTTPRequestOperation *operation, id response))success Failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
    NSString *radiusFilter = [NSString stringWithFormat:@"%f",radius];
    NSDictionary *parameters = @{@"term": term, @"ll" : coordinates, @"radius_filter": radiusFilter};
    
    return [self GET:@"search" parameters:parameters success:success failure:failure];
}

@end
