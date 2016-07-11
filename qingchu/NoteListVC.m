//
//  NoteListVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/11.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "NoteListVC.h"
#import "AppDelegate.h"
#import "CommonConstants.h"
#import "NSPublic.h"
#import "CHTermUser.h"
#import "NoteCell.h"

@interface NoteListVC ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *alertArray;
@property (nonatomic,strong) NSMutableArray *mesureArray;
@property (weak, nonatomic) IBOutlet UIView *tipView;

@property (nonatomic,strong) NSMutableArray *notifiArray;

//健康日报相关

@property (weak, nonatomic) IBOutlet UIButton *healthAlertBtn;
@property (weak, nonatomic) IBOutlet UIButton *notificationBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewCenterCST;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *notifiTableView;
@property (weak, nonatomic) IBOutlet UIView *pagerView;

@end

@implementation NoteListVC

#define CellID @"NoteCell"

#define NotiCellID @"NotifiCell"

#define ReadTag     1977

#define HealthBtnTag 1978
#define NotifiBtnTag 1979

#define AlarmImeiKey        @"imei"
#define AlarmTimeKey        @"receivetime"
#define AlarmTypeKey        @"type"
#define AlarmReadKey        @"read"

#define AlarmTitleKey       @"title"
#define AlarmDesckey        @"description"
#define AlarmContentKey     @"content"
#define AlarmContentDataKey @"data"

#define DailyTimeKey        @"time"
#define DailyUrlKey         @"url"
#define DailyTitleKey       @"title"

#define SettingSegue @"Setting Segue"
#define DailySegue   @"DailyAKXVCSegue"

- (void)viewDidLoad
{ShowLog
    
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.scrollView.delegate = self;
    [self initData];
    [self.tableView reloadData];
}

- (void)initData
{ShowLog
    
    self.notifiArray = [NSMutableArray new];
    
    NSMutableArray  *notesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AlertNoteKey"]];
    NSMutableArray  *dailyAKXsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DailyAkx"]];
    
    if (notesArray.count > 0) {
        self.tipView.hidden = YES;
    }else{
        self.tipView.hidden = NO;
    }
    
    self.alertArray = [NSMutableArray new];
    self.mesureArray = [NSMutableArray new];
    self.notifiArray = [NSMutableArray new];
    
    for (NSDictionary *dictionary in dailyAKXsArray){
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        
        if ([tempDic[@"content"] isKindOfClass:[NSString class]]) {
            
            NSString *jsonStr = tempDic[@"content"];
            
            NSData *data = [[NSData alloc] initWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
            NSError *jsonCovertError = nil;
            NSMutableDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonCovertError];
            if (!jsonCovertError) {
                tempDic[@"content"] = result;
            }else{
                tempDic[@"content"] = @{};
            }
            
        }
        
        [self.notifiArray addObject:dictionary];

    }
    
    for (NSDictionary *dictionary in notesArray){
       NSString *title = dictionary[AlarmTitleKey];
        if (title.length == 0) {
            continue;
        }
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        
        if ([tempDic[@"content"] isKindOfClass:[NSString class]]) {
            
            NSString *jsonStr = tempDic[@"content"];
            
            NSData *data = [[NSData alloc] initWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
            NSError *jsonCovertError = nil;
            NSMutableDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonCovertError];
            if (!jsonCovertError) {
                tempDic[@"content"] = result;
            }else{
                tempDic[@"content"] = @{};
            }
        }
        
        if ([title containsString:@"报警"]) {
            [self.alertArray addObject:tempDic];
        }else{
            [self.mesureArray addObject:tempDic];
        }
    }
    
    [self.alertArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSString *time1 = obj1[@"content"][@"data"][AlarmTimeKey];
        NSString *time2 = obj2[@"content"][@"data"][AlarmTimeKey];
        return [time2 compare:time1];
    }];
    
    [self.mesureArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSString *time1 = obj1[@"content"][@"data"][AlarmTimeKey];
        NSString *time2 = obj2[@"content"][@"data"][AlarmTimeKey];
        return [time2 compare:time1];
    }];

    
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([tableView isEqual:self.notifiTableView]) {
            return @" ";
        }
        return @"报警数据";
    }else{
        return @"测量数据";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.notifiTableView]) {
        return 1;
    }else{
        return 2;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([tableView isEqual:self.notifiTableView]) {
        return  self.notifiArray.count;
    }
    
    if (section == 0) {
        return self.alertArray.count;
    }else{
        return self.mesureArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ShowLog
    
    if ([tableView isEqual:self.notifiTableView]) {
        NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NotiCellID];
        NSDictionary *daiylAKX = self.notifiArray[indexPath.row];
         NSDictionary *dataDic = daiylAKX[AlarmContentKey][AlarmContentDataKey];
        cell.titleLB.text = daiylAKX[DailyTitleKey];
        cell.subTitleLB.text = dataDic[DailyTimeKey];
        AddCornerBorder(cell.dotView, 4, 0, nil);
        
        id read = daiylAKX[AlarmReadKey];
        if (read) {
            cell.dotView.hidden = YES;
        }else{
            cell.dotView.hidden = NO;
        }

        
        return cell;
        
    }else{
        
        NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        NSDictionary *notification = nil;
        if (indexPath.section == 0) {
            notification = [self alertArray][indexPath.row];
        }else{
            notification = [self mesureArray][indexPath.row];
        }
        
        
        NSDictionary *dataDic = notification[AlarmContentKey][AlarmContentDataKey];
        
        
        AddCornerBorder(cell.dotView, 4, 0, nil);
        
        cell.imvIcon.image = [self alertImageWithType:notification[AlarmTitleKey]];
        cell.titleLB.text = [self nameOfImei:dataDic[AlarmImeiKey]];
        cell.subTitleLB.text = notification[AlarmTitleKey];
        cell.rightLB.text = [self formateDateString:dataDic[AlarmTimeKey]];
        
        id read = notification[AlarmReadKey];
        if (read) {
            cell.dotView.hidden = YES;
        }else{
            cell.dotView.hidden = NO;
        }
        
        
        return cell;

    }
    
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.notifiTableView]) {
        
        NSMutableDictionary* dailyAKX = [self.notifiArray[indexPath.row] mutableCopy];
        [dailyAKX setObject:@"1" forKey:AlarmReadKey];
        
        self.notifiArray[indexPath.row] = dailyAKX;
        
        [self syncData];
        
        NSDictionary *dataDic = dailyAKX[AlarmContentKey][AlarmContentDataKey];
        
        [self.notifiTableView reloadData];
        
        [self performSegueWithIdentifier:DailySegue sender:dataDic[DailyUrlKey]];
        
        
        return;
    }
    
    
    NSMutableDictionary *notification = nil;
    if (indexPath.section == 0) {
        notification =  [NSMutableDictionary dictionaryWithDictionary:[self alertArray][indexPath.row]];
    }else{
        notification =  [NSMutableDictionary dictionaryWithDictionary:[self mesureArray][indexPath.row]];
    }

    [notification setObject:@"1" forKey:AlarmReadKey];
    
    if (indexPath.section == 0) {
        [self alertArray][indexPath.row] = notification;
    }else{
        [self mesureArray][indexPath.row] = notification;
    }
    
    [self syncData];
    
    [self.tableView reloadData];
    
    NSDictionary *data = notification[AlarmContentKey][AlarmContentDataKey];
    
    NSString *title = notification[AlarmTitleKey];
    if ([title containsString:@"心率"]) {
        NSString* name = [self nameOfImei:data[AlarmImeiKey]];
        NSString* heartRateTitle = [NSString stringWithFormat:@"%@的心率报警",name];
        PUSH(@"Home", @"HeartRateVC", heartRateTitle, @{@"mesuredPulse":data}, YES);
    }else if ([title containsString:@"定位"]){
        PUSH(@"Main", @"MapVC", @"定位", @{@"alertLocation":data}, YES);
        
    }else{
        //do other things
    }
    

}

- (void)syncData
{
    NSMutableArray *temp = [NSMutableArray new];
    for (NSDictionary *dic in self.alertArray){
        [temp addObject:dic];
    }
    
    for (NSDictionary *dic in self.mesureArray){
        [temp addObject:dic];
    }
    
    NSMutableArray *tempDaily = [NSMutableArray new];
    for (NSDictionary *dic in self.notifiArray){
        [tempDaily addObject:dic];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:tempDaily forKey:@"DailyAkx"];
    
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"AlertNoteKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SettingSegue]) {
        __weak NoteListVC *weak_self = self;
        
        void(^temp)() = ^{
            [self initData];
            [weak_self.tableView reloadData];
        };
        
        [segue.destinationViewController setValue:temp forKey:@"callback"];
    }else if ([segue.identifier isEqualToString:DailySegue]){
        [segue.destinationViewController setValue:sender forKey:@"inputUrl"];
        segue.destinationViewController.title = @"每日安康信";
    }
}

#pragma mark- 设置图片
- (UIImage*)alertImageWithType:(NSString*)type
{ShowLog
    if ([type hasPrefix:@"心率"]) {
        return [UIImage imageNamed:@"HeartAlert"];
        
    }else if ([type hasPrefix:@"定位"]){
        return [UIImage imageNamed:@"GpsAlert"];
        
    }else if ([type hasPrefix:@"血压"]){
        return [UIImage imageNamed:@"BloodAlert"];
        
    }else if ([type hasPrefix:@"sos"]){
        return [UIImage imageNamed:@"SosAlert"];
        
    }else{
        return nil;
    }
}

#pragma mark- 根据imei号码获取昵称
- (NSString*)nameOfImei:(NSString*)imei
{ShowLog
    
     NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];
    for (CHTermUser *user in termUsers){
        
        if ([user.imei isEqualToString:imei]) {
            
            if (user.relative.length > 0) {
                return user.relative;
            }
            if (user.name.length > 0) {
                return user.name;
            }
            
        }
    }
    
    return imei;
}

#pragma mark- 格式化时间
- (NSString*)formateDateString:(NSString*)inputDateString
{ShowLog
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSDate *inputDate = [inputFormatter dateFromString:inputDateString];
    
    NSDateFormatter *outputFormater = [[NSDateFormatter alloc] init];
    outputFormater.dateFormat = @"MM-dd hh:mm";
    NSString *outputDateString = [outputFormater stringFromDate:inputDate];
    
    
    NSString *month = [inputDateString substringWithRange:NSMakeRange(4, 2)];
    NSString *day = [inputDateString substringWithRange:NSMakeRange(6, 2)];
    
    NSString *hour = [inputDateString substringWithRange:NSMakeRange(8, 2)];
    NSString *minits = [inputDateString substringWithRange:NSMakeRange(10, 2)];
    
    return [NSString stringWithFormat:@"%@-%@ %@:%@",month,day,hour,minits];
}

//通知消息

- (IBAction)turnPage:(UIButton *)sender
{
    if (sender.tag == HealthBtnTag) {
        
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }else{
        [self.scrollView setContentOffset:CGPointMake(Screen_Width, 0) animated:YES];

    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollView]) {
        if (scrollView.contentOffset.x < Screen_Width) {
            self.bannerViewCenterCST.constant = 0;
            [UIView animateWithDuration:0.5 animations:^{
                [self.pagerView layoutIfNeeded];
            }];
        }else{
            self.bannerViewCenterCST.constant = Screen_Width * 0.5;
            [UIView animateWithDuration:0.5 animations:^{
                [self.pagerView layoutIfNeeded];
            }];
        }
        
    }
}

@end
