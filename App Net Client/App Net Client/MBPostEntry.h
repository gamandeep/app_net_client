//
//  MBPostEntry.h
//  App Net Client
//
//  Created by Gamandeep on 11/04/14.
//  Copyright (c) 2014 MB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBPostEntry : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic, strong) UIImage* image;

@end
