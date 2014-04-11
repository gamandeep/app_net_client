//
//  MBViewController.h
//  App Net Client
//
//  Created by Gamandeep on 11/04/14.
//  Copyright (c) 2014 MB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBJSONFetcher;

@interface MBViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    MBJSONFetcher* mFetcher;
    NSMutableArray* mLabelFrames;
    
    // the dispatch queue to load images
    dispatch_queue_t queue;
}

@property (nonatomic, strong) UITableView* mTableView;
@property (nonatomic, strong) NSMutableArray* mPostsArray;
@property (nonatomic, strong) NSMutableDictionary* mImages;

- (void)receivedResponse : (MBJSONFetcher*) aFetcher;

@end
