//
//  ImageCenterViewController.h
//  Created by Devin Ross on 4/16/10.
//

 


#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface ImageListViewController : TKTableViewController<UITableViewDataSource,UITableViewDelegate> {
	NSArray *urlArray;
	TKImageCache *imageCache;
    ASIHTTPRequest *asiRequest;
}
@property(nonatomic,retain) ASIHTTPRequest *asiRequest;

@end
