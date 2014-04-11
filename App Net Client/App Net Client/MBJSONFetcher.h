//
//  MBJSONFetcher.h
//  App Net Client
//
//  Created by Gamandeep on 11/04/14.
//  Copyright (c) 2014 MB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"

@interface MBJSONFetcher : NSObject
{
    id receiver;
	SEL action;
    
    NSURLConnection *connection;
	NSMutableData *data;
    
    NSURLRequest *urlRequest;
	NSInteger failureCode;
    
    void *context;
    
    id result;
}


@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) NSInteger failureCode;
@property (nonatomic, assign) void *context;
@property (nonatomic, readonly) id result;

- (id)initWithURLString:(NSString *)aURLString
               receiver:(id)aReceiver
                 action:(SEL)receiverAction;
- (void)start;
- (void)cancel;
- (void)close;
@end
