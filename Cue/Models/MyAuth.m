//
//  MyAuth.m
//  Cue
//
//  Created by Shreeya Indap on 7/18/22.
//

#import "MyAuth.h"

#ifndef GTM_OAUTH2_BEARER
#define GTM_OAUTH2_BEARER "Bearer"
#endif

@interface MyAuth ()
@property (strong, nonatomic) NSString *accessToken;
@end

@implementation MyAuth

+ (MyAuth *)initWithAccessToken:(NSString *)accessToken {
    MyAuth *auth = [[MyAuth alloc] init];
    auth.accessToken = [accessToken copy];
    return auth;
}

- (void)authorizeRequest:(NSMutableURLRequest *)request
                delegate:(id)delegate
       didFinishSelector:(SEL)sel {
    [self setTokeToRequest:request];

    NSMethodSignature *sig = [delegate methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:sel];
    [invocation setTarget:delegate];
    [invocation setArgument:(&self) atIndex:2];
    [invocation setArgument:&request atIndex:3];
    [invocation invoke];
}

- (void)authorizeRequest:(NSMutableURLRequest *)request
   completionHandler:(void (^)(NSError *error))handler {
    [self setTokeToRequest:request];
}

- (void)setTokeToRequest:(NSMutableURLRequest *)request {
    if (request) {
        NSString *value = [NSString stringWithFormat:@"%s %@", GTM_OAUTH2_BEARER, self.accessToken];
        [request setValue:value forHTTPHeaderField:@"Authorization"];
    }
}

- (BOOL)isAuthorizedRequest:(NSURLRequest *)request {
    return NO;
}

- (void)stopAuthorization {
}

- (void)stopAuthorizationForRequest:(NSURLRequest *)request {
}

- (BOOL)isAuthorizingRequest:(NSURLRequest *)request {
    return YES;
}

@synthesize userEmail;

@end
