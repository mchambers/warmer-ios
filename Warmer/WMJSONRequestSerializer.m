//
//  WMJSONRequestSerializer.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMJSONRequestSerializer.h"

@implementation WMJSONRequestSerializer

// Append the access token into the query string on all outbound requests.
//
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     error:(NSError * __autoreleasing *)error
{
    NSMutableDictionary* tokenParameters;
    if(parameters)
        tokenParameters=[NSMutableDictionary dictionaryWithDictionary:parameters];
    
    if(self.accessToken)
    {
        if([method isEqualToString:@"GET"])
        {
            // parameter method
            if(!tokenParameters)
                tokenParameters=[NSMutableDictionary dictionaryWithCapacity:1];
            
            [tokenParameters setValue:self.accessToken.accessToken forKey:@"access_token"];
        }
        else {
            // header method
            [self setValue:[NSString stringWithFormat:@"Token %@", self.accessToken.accessToken] forHTTPHeaderField:@"Authorization"];
        }
    }
    else
    {
        [self clearAuthorizationHeader];
    }
    
    return [super requestWithMethod:method URLString:URLString parameters:tokenParameters error:error];
}

@end
