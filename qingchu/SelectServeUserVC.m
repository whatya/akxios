//
//  SelectServeUserVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SelectServeUserVC.h"

#import "MenuView.h"
#import "SelectServeUserCell.h"
#import "ServeUserModel.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "ServeUserDetailsVC.h"
#import "ServeCashVC.h"
#import "NSPublic.h"
#import "CashTVC.h"
#import "V2LoginTVC.h"
#import "SkillShareParam.h"


#define CitiesKey @"cities"
#define StateKey @"state"
#define CityKey @"city"
#define AreasKey @"areas"


#define serveURL       @"chunhui/m/doctor@getAllDoctor.do"

@interface SelectServeUserVC ()<MenuViewDataSource,MenuViewDelegate,UITableViewDataSource,UITableViewDelegate,selectButtonDelegate>


/**
 *  专长
 */
@property (nonatomic,strong) NSArray *specialityArray;

/**
 *  职业
 */
@property (nonatomic,strong) NSArray *professionArray;

@property (nonatomic,strong) NSMutableArray *serveUserArray;

@property (nonatomic,strong) NSArray * keys;
@property(nonatomic,strong) NSMutableArray * values;

@property(nonatomic,copy) NSString * area;
@property(nonatomic,copy) NSString * major;
@property(nonatomic,copy) NSString * userType;

@end

@implementation SelectServeUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _serveUserArray = [[NSMutableArray alloc] init];
    _serveUserArray = [[NSMutableArray alloc] init];
    _keys =@[@"area",@"major",@"sex",@"userType",@"pageNum",@"pageSize"];
    //_values = @[@"",@"",@"",@"",@"0",@"10"];
    _values = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"0",@"10", nil];
    _area = @"";
    _userType = @"";
    _major = @"";
    [self loadData];
    self.navigationItem.title = @"选择服务人员";

    _serveUserTB = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height - 40 ) style:UITableViewStylePlain];
    
    //_serveUserTB.backgroundColor = [UIColor greenColor];
    
    //_serveUserTB.tableHeaderView = dropMenu;
    
    [self.view addSubview:_serveUserTB];
    
    _serveUserTB.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _serveUserTB.delegate = self;
    
    _serveUserTB.dataSource = self;
    
    _specialityArray = @[@"全部",@"全科",@"心脑血管",@"糖尿病"];
    
    _professionArray = @[@"全部",@"医生",@"健康管理师"];
    
    MenuView *dropMenu = [[MenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    dropMenu.dataSource = self;
    dropMenu.delegate  =self;
    [self.view addSubview:dropMenu];
    dropMenu.address = [NSString string];
    dropMenu.major = [NSString stringWithFormat:@"%d",0];
    dropMenu.userType = [NSString stringWithFormat:@"%d",1];
    dropMenu.num1 = 0;
    dropMenu.num2 = 1;
    dropMenu.str1 = [NSString string];
    dropMenu.str2 = [NSString string];
    dropMenu.str3 = [NSString string];
}



-(void)touchMenu:(NSArray *)array
{
    //[self tableLoadData];
    if ([array[0] isEqualToString:@"全部"]) {
        _area = @"";
    }
    else{
    _area = array[0];
    }
    NSLog(@"+++++++++++++***********%@",_area);
    if ([array[1] intValue]>0) {
        _major = [NSString stringWithFormat:@"%@",array[1]];
    }
    else
    {
        _major = @"";
    }
    if ([[array lastObject] intValue]>1) {
        _userType = [NSString stringWithFormat:@"%@",array[2]];
    }
    else
    {
        _userType = @"";
    }
    [self.serveUserArray removeAllObjects];
    [self.serveUserTB reloadData];
    
    _values = [NSMutableArray arrayWithObjects:_area,_major,@"",_userType,@"0",@"10", nil];
    [self loadData];
}


#pragma mark - WSDropMenuView DataSource -
- (NSInteger)dropMenuView:(MenuView *)dropMenuView numberWithIndexPath:(WSIndexPath *)indexPath Provinces:(NSArray *)provinces Cities:(NSArray *)cities Areas:(NSArray *)areas{
    
    //WSIndexPath 类里面有注释
    //NSLog(@"colum:%ld,row:%ld",indexPath.column,indexPath.row);
    if (indexPath.column == 0 && indexPath.row == WSNoFound) {
        //        [self didSelectRow:indexPath.row inComponent:WSNoFound];
       // NSLog(@"row:%ld,item:%ld",indexPath.row,indexPath.item);
        return provinces.count;
    }
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item == WSNoFound) {
        //        [self didSelectRow:indexPath.row inComponent:0];
       // NSLog(@"row:%ld,item:%ld",(long)indexPath.row,indexPath.item);
        return cities.count;
    }
    
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item != WSNoFound && indexPath.rank == WSNoFound) {
        //        [self didSelectRow:indexPath.item inComponent:1];
       // NSLog(@"row:%ld,item:%ld",(long)indexPath.row,indexPath.item);
        return areas.count;
    }
    
    if (indexPath.column == 1) {
        
        return _specialityArray.count;
    }
    if (indexPath.column == 2) {
        
        return _professionArray.count;
    }
    return 0;
}

- (NSString *)dropMenuView:(MenuView *)dropMenuView titleWithIndexPath:(WSIndexPath *)indexPath Provinces:(NSArray *)provinces Cities:(NSArray *)cities Areas:(NSArray *)areas{
    
    //return [NSString stringWithFormat:@"%ld",indexPath.row];
    
    //左边 第一级
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item == WSNoFound) {
        
        return [provinces[indexPath.row] objectForKey:StateKey];
    }
    
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item != WSNoFound && indexPath.rank == WSNoFound) {
        
        return [cities[indexPath.item] objectForKey:CityKey];
    }
    
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item != WSNoFound && indexPath.rank != WSNoFound) {
        
        if (areas.count > 0) {
           
            return areas[indexPath.rank];
            
        }
        
    }
    
    if (indexPath.column == 1 && indexPath.row != WSNoFound ) {
        
       
        return _specialityArray[indexPath.row];
        
    }
    if (indexPath.column == 2 && indexPath.row != WSNoFound) {
        
        return _professionArray[indexPath.row];
        
    }
    return @"";
}


#pragma mark - MenuView Delegate -

- (void)dropMenuView:(MenuView *)dropMenuView didSelectWithIndexPath:(WSIndexPath *)indexPath{
    
    [self loadData];
}

- (void)getCityName:(NSString *)string{

    [self loadData];
}

- (void)getOtherSideName:(NSString *)string{

    [self loadData];
}

- (void)choseButton:(NSInteger *)tag{

    ServeUserModel *model = self.serveUserArray[(int)tag - 100];
    [SkillShareParam sharedSkill].order.doctorId = model.gId;
    [SkillShareParam sharedSkill].order.doctorName = model.realname;
    [SkillShareParam sharedSkill].order.doctorUsername = model.username;
    id temp = [SkillShareParam sharedSkill];
    ServeCashVC *cashVC = VCFromStoryboard(@"Service", @"ServeCashVC");
    cashVC.inputServeOrder = [SkillShareParam sharedSkill].order;
    
    [self.navigationController pushViewController:cashVC animated:YES];
}



- (BOOL)shouldPerformSegueWithIdentifier:(UIStoryboardSegue *) segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ServeCashVC"]) {
        
        if ([[NSPublic shareInstance]getUserName].length == 0) {
            
            UINavigationController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
            V2LoginTVC *loginVC = VC.viewControllers.firstObject;
            loginVC.shouldShowBackBtn = YES;
            [self presentViewController:VC animated:YES completion:NULL];
            
            return NO;
        }
        
        return YES;
    }
    return YES;
}



#define mark - 请求加载
-(void)loadData{

    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:_keys withValues:_values];


    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:serveURL portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            NSLog(@"%@",ErrorString(jsonData));
            
            return;
        }
        NSMutableArray *dataArray = jsonData[@"data"];
        for (NSDictionary *dict in dataArray) {
            
            ServeUserModel *model = [[ServeUserModel alloc] initFromDictonary:dict];
            [_serveUserArray addObject:model];
        }
        [_serveUserTB reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _serveUserArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellID = @"ID";
    
    SelectServeUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {

        cell = [[[NSBundle mainBundle] loadNibNamed:@"SelectServeUserCell" owner:self options:nil] lastObject];
    }
    ServeUserModel *model = self.serveUserArray[indexPath.row];

//    [cell.selectBtn addTarget:self action:@selector(butClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell configUI:self.serveUserArray[indexPath.row] withTag:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    ServeUserModel *model = self.serveUserArray[indexPath.row];
    [[NSPublic shareInstance] saveDoctorId:model.gId];
    
    ServeUserDetailsVC *serveDetailVC = [[UIStoryboard storyboardWithName:@"Service" bundle:nil] instantiateViewControllerWithIdentifier:@"ServeUserDetailsVC"];
    serveDetailVC.username = model.username;
    serveDetailVC.name = self.userName;
    [self.navigationController pushViewController:serveDetailVC animated:YES];
}



@end
