//
//  PeopleGetVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "PeopleGetVC.h"
#import "NSPublic.h"
#import "CommonConstants.h"
#import "PeopleGetCell.h"
#import "UIImageView+WebCache.h"

@interface PeopleGetVC ()<
UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *peoples;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation PeopleGetVC

#define CellID @"PeopleCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peoples = [NSMutableArray new];
    [self fillPeoples];
    self.nextBtn.enabled = NO;
}

- (void)fillPeoples
{
   NSArray *tempArray =  [[NSPublic shareInstance] getTermUserArray];
    
    for (CHTermUser *user in tempArray){
        PeopelModel *model = [[PeopelModel alloc] init];
        model.user = user;
        [self.peoples addObject:model];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peoples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PeopelModel *model = self.peoples[indexPath.row];
    PeopleGetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    cell.nameLB.text = model.user.name;
    cell.genderLB.text = model.user.sex;
    cell.imeiLB.text = model.user.imei;
    [cell.imv sd_setImageWithURL:[NSURL URLWithString:model.user.image] placeholderImage:[UIImage imageNamed:@"cellUserAvatar"]];
    cell.radioImv.image = model.checked ? [UIImage imageNamed:@"register-radiobutton-d"] : [UIImage imageNamed:@"register-radiobutton-u"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PeopelModel *model = self.peoples[indexPath.row];
    model.checked = !model.checked;
    
    //清除其它选项
    for (PeopelModel *otherModel in self.peoples){
        if (![otherModel isEqual:model]) {
            otherModel.checked = NO;
        }
    }
    
    BOOL hasUserChecked = NO;
    for (PeopelModel *tempModel in self.peoples){
        if (tempModel.checked) {
            hasUserChecked = YES;
            break;
        }
    }
    
    self.nextBtn.enabled = hasUserChecked;
    [self.tableView reloadData];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (IBAction)next:(id)sender {
    
    PeopelModel *targetModel = nil;
    for (PeopelModel *model in self.peoples){
        if (model.checked) {
            targetModel = model;
        }
    }
    
    if (targetModel) {
        PUSH(@"More", @"PhoneBillChargerTVC", @"支付", (@{@"user":targetModel.user}), YES);
    }
}

@end

@implementation PeopelModel
@end
