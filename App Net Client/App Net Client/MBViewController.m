//
//  MBViewController.m
//  App Net Client
//
//  Created by Gamandeep on 11/04/14.
//  Copyright (c) 2014 MB. All rights reserved.
//

#import "MBViewController.h"
#import "MBJSONFetcher.h"
#import "MBPostEntry.h"
#import "MBTableViewCell.h"

@interface MBViewController ()

@end

@implementation MBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"App Net Client";
    [self makeRequestForPosts];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeRequestForPosts
{
    NSString* urlString = @"https://alpha-api.app.net/stream/0/posts/stream/global";
    if (mFetcher)
    {
        [mFetcher cancel];
        mFetcher = nil;
    }
    
    mFetcher = [[MBJSONFetcher alloc] initWithURLString:urlString receiver:self action:@selector(receivedResponse:)];
    
    [mFetcher start];
}

- (void)receivedResponse:(MBJSONFetcher *)aFetcher
{
    if (self.mPostsArray)
    {
        self.mPostsArray = nil;
        mLabelFrames = nil;
        self.mImages = nil;
    }
    
    self.mPostsArray = [NSMutableArray array];
    
    NSArray* array = [NSArray arrayWithArray:[mFetcher.result objectForKey:@"data"]];
    mLabelFrames = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.mImages = [[NSMutableDictionary alloc] init];
//    NSLog(@"%@", array[0]);
    for (NSDictionary* dict in array)
    {
        MBPostEntry* entry = [[MBPostEntry alloc] init];
        entry.name = [[dict objectForKey:@"user"] objectForKey:@"name"];
        entry.text = [dict objectForKey:@"text"];
        entry.imageURL = [[[dict objectForKey:@"user"] objectForKey:@"avatar_image"] objectForKey:@"url"];
        
        [self.mPostsArray addObject:entry];
        [mLabelFrames addObject:[NSNumber numberWithInt:80]];
    }
    
    if (self.mTableView == nil)
        [self loadTableView];
    else
        [self.mTableView reloadData];
    
}

- (void)loadTableView
{
    self.mTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;

    [self.mTableView registerNib:[UINib nibWithNibName:@"MBTableViewCell" bundle:nil] forCellReuseIdentifier:@"myCell"];

    [self.view addSubview:self.mTableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:refreshControl];

    [self.mTableView reloadData];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    [self makeRequestForPosts];
    [refreshControl endRefreshing];
}

#pragma mark - Table view delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBPostEntry *entry = [self.mPostsArray objectAtIndex:indexPath.row];
    NSString* text = entry.text;
    
    MBTableViewCell *cell = (MBTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:12] , NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString: text attributes:attributesDictionary];

    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(215, 200) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    

    //Calculate the new size based on the text
    CGSize expectedLabelSize = rect.size;
    
    
    //Dynamically figure out the padding for the cell
    CGFloat topPadding = 35 - cell.frame.origin.y;
    
    
    CGFloat bottomOfLabel = 95;
    CGFloat bottomPadding = cell.frame.size.height - bottomOfLabel;
    
    
    CGFloat padding = topPadding + bottomPadding;
    
    
    CGFloat minimumHeight = 100;
    

    [mLabelFrames replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt: expectedLabelSize.height ]];
    

    CGFloat cellHeight = expectedLabelSize.height + padding;
    
    cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.frame.size.width, cellHeight);
    
    if (cellHeight < minimumHeight) {
        
        cellHeight = minimumHeight;
    }
    
    return cellHeight;

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.mPostsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{

    MBTableViewCell * cell = [self.mTableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (!cell)
    {
        [self.mTableView registerNib:[UINib nibWithNibName:@"MBTableViewCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
        cell = [self.mTableView dequeueReusableCellWithIdentifier:@"myCell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MBTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBPostEntry *entry = [self.mPostsArray objectAtIndex:indexPath.row];
    
    if (cell.postLabel != nil)
    {
        [cell.postLabel removeFromSuperview];
        cell.postLabel = nil;
    }
    
    cell.nameLabel.text = entry.name;
    
    cell.picView.image = [self imageForRowAtIndexPath:indexPath];
    cell.picView.layer.cornerRadius = 15.0;
    cell.picView.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 35, 215, [[mLabelFrames objectAtIndex:indexPath.row] integerValue ])];
    label.text = entry.text;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:label];
    cell.postLabel = label;

}

- (UIImage *)imageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBPostEntry *entry = [self.mPostsArray objectAtIndex:indexPath.row];

    UIImage *image = [self.mImages objectForKey:entry.imageURL];
    
    if(!image)
    {
        // if we didn't find an image, create a placeholder image and
        // put it in the "cache". Start the download of the actual image
        image = [UIImage imageNamed:@"Profile.png"];
        
        if (entry.imageURL == nil)
            return image;
        
        [self.mImages setValue:image forKey:entry.imageURL];
        
        //get the string version of the URL for the image
        NSString *url = entry.imageURL;
        
        // create the queue if it doesn't exist
        if (!queue) {
            queue = dispatch_queue_create("image_queue", NULL);
        }
        
        //dispatch_async to get the image data
        dispatch_async(queue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *anImage = [UIImage imageWithData:data];
            [self.mImages setValue:anImage forKey:entry.imageURL];
            MBTableViewCell *cell = (MBTableViewCell*)[self.mTableView cellForRowAtIndexPath:indexPath];
            
            //dispatch_async on the main queue to update the UI
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.picView.image = anImage;
            });
        });
    }
    
    // return the image, it could be the placeholder, or an image from the cache
    return image;
}

@end
