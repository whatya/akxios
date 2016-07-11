//
//  ImageCenterViewController.m
//  Created by Devin Ross on 4/16/10.
//


#import "ImageListViewController.h"
#import "EScrollerView.h"
#import "PullingRefreshTableView.h"
#import "CJSONDeserializer.h"
#import "NewsModel.h"



@interface ImageListViewController () <
 PullingRefreshTableViewDelegate,ASIHTTPRequestDelegate,
UITableViewDataSource,
UITableViewDelegate
>
-(void) GetErr:(ASIHTTPRequest *)request;
-(void) GetResult:(ASIHTTPRequest *)request;
@property (retain,nonatomic) PullingRefreshTableView *tableView;
@property (retain,nonatomic) NSMutableArray *list;
@property (nonatomic) BOOL refreshing;
@property (assign,nonatomic) NSInteger page;
@end


@implementation ImageListViewController
 



- (id) init{
	if(!(self=[super init])) return nil;
	 
	return self;
}


- (void) loadView{
	[super loadView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageRetrieved:) name:@"newImageCache" object:nil];
    //首页滑动海报
    EScrollerView *scroller=[[EScrollerView alloc] initWithFrameRect:CGRectMake(0, 0, 320, 180)
                                                          ImageArray:[NSArray arrayWithObjects:@"jingchu1.jpg",@"jingchu2.jpg",@"jingchu3.jpg", nil]
                                                          TitleArray:[NSArray arrayWithObjects:@"1",@"2",@"3", nil]];
	self.tableView.tableHeaderView = scroller;
	self.tableView.rowHeight = 100;
	self.tableView.allowsSelection = YES;
    self.page++;
    [scroller release];

	 
	
 
}

-(void) GetErr:(ASIHTTPRequest *)request
{
    self.refreshing = NO;
   // [self.tableView tableViewDidFinishedLoading];
    //[tooles MsgBox:@"连接网络失败，请检查是否开启移动数据"];
    
}

-(void) GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
    if ([dictionary objectForKey:@"data"]) {
		NSArray *array = [NSArray arrayWithArray:[dictionary objectForKey:@"data"]];
        for (NSDictionary *ns in array) {
            NewsModel *newsModel = [[[NewsModel alloc]initWithDictionary:ns]autorelease];
            [self.list addObject:newsModel];
        }
    }  
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%d",[self.list count]);
    return [self.list count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
    NewsModel *nm = [self.list objectAtIndex:[indexPath row]];
	cell.textLabel.text = nm.title;//[NSString stringWithFormat:@"Cell%d",indexPath.row];
    cell.detailTextLabel.text = nm.description;   //index
	UIImage *img = [imageCache imageForKey:nm.id  url:[NSURL URLWithString:nm.img] queueIfNeeded:YES tag:0];
	cell.imageView.image = img;

    return cell;
}

- (void) newImageRetrieved:(NSNotification*)sender{
	NSDictionary *dict = [sender userInfo];
	NSInteger tag = [[dict objectForKey:@"tag"] intValue];
	NSArray *paths = [self.tableView indexPathsForVisibleRows];
    
	for(NSIndexPath *path in paths){
		
		NSInteger index = path.row % urlArray.count;
		
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
		if(cell.imageView.image == nil && tag == index){
			
			cell.imageView.image = [dict objectForKey:@"image"];
			[cell setNeedsLayout];
			
		}
	}
}

- (void) dealloc {
	[urlArray release];
	[imageCache release];
    [super dealloc];
}



@end

