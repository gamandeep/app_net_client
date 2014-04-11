//
//  MBJSONFetcher.m
//  App Net Client
//
//  Created by Gamandeep on 11/04/14.
//  Copyright (c) 2014 MB. All rights reserved.
//

#import "MBJSONFetcher.h"
#import "SBJson.h"

@implementation MBJSONFetcher

@synthesize data;
@synthesize urlRequest;
@synthesize failureCode;
@synthesize context;
@synthesize result;

- (id)initWithURLString:(NSString *)aURLString
               receiver:(id)aReceiver
                 action:(SEL)receiverAction
{
	//
	// Create the URL request and invoke super
	//
	NSURL *url = [NSURL URLWithString:aURLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	self = [super init];
	if (self != nil)
	{
		action = receiverAction;
		receiver = aReceiver;
		urlRequest = request;
		
		connection =
        [[NSURLConnection alloc]
         initWithRequest:urlRequest
         delegate:self
         startImmediately:NO];
	}
    
	return self;
}

- (void)start
{
	[connection start];
}

- (void)close
{
	[connection cancel];
	connection = nil;
		
	[receiver performSelector:action withObject:self];
	receiver = nil;
    
	data = nil;
    
    result = nil;
}

- (void)cancel
{
	receiver = nil;
	[self close];
}


- (void)connection:(NSURLConnection *)aConnection
didReceiveResponse:(NSHTTPURLResponse *)aResponse
{
    
	if ([aResponse statusCode] >= 400)
	{
		failureCode = [aResponse statusCode];
		
		NSString *errorMessage;
		if (failureCode == 404)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"Requested file not found or couldn't be opened.", @"HTTPFetcher", @"Error given when a file cannot be opened or played.");
		}
		else if (failureCode == 403)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"The server did not have permission to open the file..", @"HTTPFetcher", @"Error given when a file permissions problem prevents you opening or playing a file.");
		}
		else if (failureCode == 415)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"The requested file couldn't be converted for streaming.", @"HTTPFetcher", @"Error given when a file can't be streamed.");
		}
		else if (failureCode == 500)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"An internal server error occurred when requesting the file.", @"HTTPFetcher", @"Error given when an unknown problem occurs on the server.");
		}
		else
		{
			errorMessage = [NSString stringWithFormat:
                            NSLocalizedStringFromTable(@"Server returned an HTTP error %ld.", @"HTTPFetcher", @"Error given when an unknown communication problem occurs. Placeholder is replaced with the error number."),
                            failureCode];
		}
        
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedStringFromTable(@"Connection Error", @"HTTPFetcher", @"Title of the error dialog used for any kind of connection or streaming error.")
         message:errorMessage
         delegate:nil
         cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"HTTPFetcher", @"Standard dialog dismiss button.")
         otherButtonTitles:nil];
        [alert show];
		
		[self close];
		return;
	}
    
    data = nil;
    data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
	if ([[error domain] isEqual:NSURLErrorDomain])
	{
		failureCode = [error code];
	}

    if ([error code] == -1004)
    {
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedStringFromTable(@"Server not running error", @"HTTPFetcher", @"Title for a specific connection error.")
         message:NSLocalizedStringFromTable(@"Cannot connect to server. A response was received that no server was running on the specified port.", @"HTTPFetcher", @"Detail for a specific connection error.")
         delegate:nil
         cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"HTTPFetcher", @"Standard dialog dismiss button.")
         otherButtonTitles:nil];
        [alert show];
    }
    else if ([error code] == -1001)
    {
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedStringFromTable(@"Connection timeout", @"HTTPFetcher", @"Title for a specific connection error.")
         message:NSLocalizedStringFromTable(@"The server's computer could be off, taking too long to respond, or a firewall or router may be blocking the connection.", @"HTTPFetcher", @"Detail for a specific connection error.")
         delegate:nil
         cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"HTTPFetcher", @"Standard dialog dismiss button.")
         otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedStringFromTable(@"Connection Error", @"HTTPFetcher", @"Title for a specific connection error.")
         message:[NSString stringWithFormat:
                  NSLocalizedStringFromTable(@"Connection to server failed:\n%@", @"HTTPFetcher", @"Detail for a specific connection error."),
                  [error localizedDescription]]
         delegate:nil
         cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"HTTPFetcher", @"Standard dialog dismiss button.")
         otherButtonTitles:nil];
        [alert show];    
    }
    
	[self close];
}


- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)newData
{
	[data appendData:newData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    SBJsonParser *json = [SBJsonParser new];
	result = [json objectWithData:data] ;
    
	if (result == nil)
	{
		UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedStringFromTable(@"Connection Error", @"JSONFetcher", @"Title for error dialog")
         message:NSLocalizedStringFromTable(@"Server response was not understood.", @"JSONFetcher", @"Detail for an error dialog.")
         delegate:nil
         cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"JSONFetcher", @"Standard dialog dismiss button")
         otherButtonTitles:nil];
		[alert show];
	}

    
	[self close];
}


@end
