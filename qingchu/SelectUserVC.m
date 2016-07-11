//
//  SelectUserVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/12.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SelectUserVC.h"
#import "SelectUserCell.h"
#import "SelectUser.h"
#import "UIImageView+WebCache.h"

#import "NSPublic.h"
#import "CHTermUser.h"
#import "DataPublic.h"

#import "HttpManager.h"
#import "CommonConstants.h"
#import "SelectServeUserVC.h"
#import "ProgressHUD.h"
#import "SkillShareParam.h"

#define ThemColor [UIColor colorWithRed:224/255.0 green:43/255.0 blue:30/255.0 alpha:1]
@interface SelectUserVC ()<SelectUserCellDelegate,UITableViewDataSource,UITableViewDelegate>

{
    
   UIImageView *loginedUserIcon;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;



@property (nonatomic,strong) UIButton *button;
@property(nonatomic,copy) NSString * str;
@end

@implementation SelectUserVC



- (void)viewDidLoad {
    [super viewDidLoad];
    
    Order  *temp = [SkillShareParam sharedSkill].order;
    
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    
    self.usersArray = [NSMutableArray new];
    
    [self initUI];
    
    _TBView.dataSource = self;
    
    _TBView.delegate = self;
    
    _nextButton.userInteractionEnabled = NO;
    [self populateData];
}


- (void)initUI{

    loginedUserIcon.clipsToBounds = YES;
    loginedUserIcon.layer.cornerRadius = 50;

}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

   return self.usersArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SelectUser *model = self.usersArray[indexPath.row];
    model.indexPath = indexPath;
    SelectUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectUserCell"];
    cell.delegate = self;
    cell.model = model;
    _str = model.users.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.statusImageV.image = model.checked ? [UIImage imageNamed:@"register-radiobutton-d"] : [UIImage imageNamed:@"register-radiobutton-u"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     SelectUser *model = self.usersArray[indexPath.row];
     model.checked = !model.checked;
    
    if (model.checked) {
        
        Order  *temp = [SkillShareParam sharedSkill].order;
        
        [SkillShareParam sharedSkill].order.receiverId = model.users.userId;
        [SkillShareParam sharedSkill].order.receiverName = model.users.name;
        
        Order  *temp2 = [SkillShareParam sharedSkill].order;
        NSLog(@"sth");
    }
    
    //清除其它选项
    for (SelectUser *otherModel in self.usersArray){
        if (![otherModel isEqual:model]) {
            otherModel.checked = NO;
        }
    }
    
    
    BOOL hasUserChecked = NO;
    
    for (SelectUser *otherModel in self.usersArray){
        if (otherModel.checked) {
            hasUserChecked = YES;
        }
    }
    
    if (hasUserChecked) {
        _nextButton.userInteractionEnabled = YES;
        _nextButton.backgroundColor = ThemColor;
    }else{
        _nextButton.userInteractionEnabled = NO;
        _nextButton.backgroundColor = [UIColor clearColor];
    }
    
    
    [self.tableView reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 80;
}




#pragma mark- 获取数据
- (void)populateData
{
    [ProgressHUD show:@"获取亲人中" Interaction:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];
        
        if (termUsers.count == 0) {
            return ;
        }
        
        self.usersArray = [NSMutableArray arrayWithCapacity:termUsers.count];
        for (CHTermUser *termUser in termUsers) {
            
            NSLog(@"%@",termUser.name);
            
            SelectUser *model = [[SelectUser alloc] init];
            model.users = termUser;
            
            [self.usersArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [ProgressHUD dismiss];
            [self.tableView reloadData];
        });
    });
    
}


- (IBAction)nextButton:(id)sender {
    
    SkillShareParam *temp = [SkillShareParam sharedSkill];
    
    SelectServeUserVC *vc = [[SelectServeUserVC alloc] init];
    vc.userName = _str;
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
