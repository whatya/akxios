//
//  HealthCheckVC.m
//  qingchu
//
//  Created by 张宝 on 16/4/15.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "HealthCheckVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"

@interface HealthCheckVC ()

@property (weak, nonatomic) IBOutlet UILabel *nameAndIDLB;

//身高、体重、体温
@property (weak, nonatomic) IBOutlet UILabel *sgLB;
@property (weak, nonatomic) IBOutlet UILabel *tzLB;
@property (weak, nonatomic) IBOutlet UILabel *twLB;
//体质指数
@property (weak, nonatomic) IBOutlet UILabel *zfhlLB;
@property (weak, nonatomic) IBOutlet UILabel *jcdxLB;
@property (weak, nonatomic) IBOutlet UILabel *bmiLB;
@property (weak, nonatomic) IBOutlet UILabel *txLB;

//血压 血氧 血糖 心率
@property (weak, nonatomic) IBOutlet UILabel *ssyLB;
@property (weak, nonatomic) IBOutlet UILabel *szyLB;
@property (weak, nonatomic) IBOutlet UILabel *xyLB;
@property (weak, nonatomic) IBOutlet UILabel *xtLB;
@property (weak, nonatomic) IBOutlet UILabel *xlLB;


//肺活量
@property (weak, nonatomic) IBOutlet UILabel *fvcLB;
@property (weak, nonatomic) IBOutlet UILabel *fevLB;
@property (weak, nonatomic) IBOutlet UILabel *pefLB;
@property (weak, nonatomic) IBOutlet UILabel *pef25LB;
@property (weak, nonatomic) IBOutlet UILabel *fef75LB;
@property (weak, nonatomic) IBOutlet UILabel *fef2575LB;
//尿常规
@property (weak, nonatomic) IBOutlet UILabel *ndyLB;
@property (weak, nonatomic) IBOutlet UILabel *dhsLB;
@property (weak, nonatomic) IBOutlet UILabel *qxLB;
@property (weak, nonatomic) IBOutlet UILabel *sjzLB;
@property (weak, nonatomic) IBOutlet UILabel *yxsyLB;
@property (weak, nonatomic) IBOutlet UILabel *bzLB;
@property (weak, nonatomic) IBOutlet UILabel *xxbLB;
@property (weak, nonatomic) IBOutlet UILabel *pttLB;
@property (weak, nonatomic) IBOutlet UILabel *ttLB;
@property (weak, nonatomic) IBOutlet UILabel *dbzLB;
@property (weak, nonatomic) IBOutlet UILabel *wsscLB;

@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (strong,nonatomic) NSDate  *uiDate;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;

@property (nonatomic,nonatomic) int pageIndex;
@property (weak, nonatomic) IBOutlet UIView *pagePanelView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *subContainerViews;

@end

@implementation HealthCheckVC

#define HealthBaseUrl @"http://webservice.3chunhui.com/data/health/"

#define PagePreTag  1975
#define PageNextTag 1976

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *name = [[NSPublic shareInstance] getname];
    NSString *mcard = [[NSPublic shareInstance] getMcard];
    self.nameAndIDLB.text = [NSString stringWithFormat:@"姓名:%@        卡号:%@",name,mcard.length > 0 ? mcard : @"(会员卡未绑定！)"];
    self.timeBtn.hidden = mcard.length > 0 ? NO : YES;
    
    
    self.nextBtn.hidden = mcard.length > 0 ? NO : YES;
    self.preBtn.hidden = mcard.length > 0 ? NO: YES;
    
    self.pageIndex = 0;
    
    for (UIView *view in self.subContainerViews){
        //AddConerWithShadow2(view, 2, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
        
        CALayer *layer = [view layer];
        layer.cornerRadius = 2;
        //layer.shadowRadius = radius;
        layer.borderWidth = 0;
        //layer.borderColor = [UIColor blackColor].CGColor;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.2;
        layer.shadowOffset = CGSizeMake(0, 0);
        
    }
}

#pragma mark- 按钮触发方法
- (IBAction)nextOrPre:(UIButton *)sender
{
    if (sender.tag == PagePreTag) {
        self.pageIndex ++;
        
    }else{
        if (self.pageIndex > 0) {
            self.pageIndex --;
        }
    }
    
}


- (void)setPageIndex:(int)pageIndex
{
    _pageIndex = pageIndex;
    
    
    if (pageIndex == 0){
        self.nextBtn.enabled = NO;
        self.nextBtn.alpha = 0.5;
    }else{
        self.nextBtn.enabled = YES;
        self.nextBtn.alpha = 1;
    }
    
    NSString *card  = [[NSPublic shareInstance] getMcard];
    if (card.length > 0){
        [self fetchDataWithMcard:card pageIndex:pageIndex];
    }
    
}

#pragma mark- 获取计步数据
- (void)fetchDataWithMcard:(NSString*)card pageIndex:(int)index
{
    [ProgressHUD show:@"获取体检报告中..." Interaction:YES];
    NSArray *keys = @[@"mcard",@"itemNum"];
    NSArray *values = @[card,[NSString stringWithFormat:@"%d",index]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"http://mfpservice.3chunhui.com/mfpservice/data/getAllData.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:9001 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            if (IsSuccessful(jsonData)) {
                self.pagePanelView.hidden = NO;
                [self updateBodyFigures:jsonData[@"data"]];
            }else{
                [ProgressHUD dismiss];
                [[Alert sharedAlert] showMessage:@"请体检后再查看！"];
                self.pagePanelView.hidden = YES;
            }
        }else{
            [ProgressHUD dismiss];
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}

#pragma mark- 更新体检报告
- (void)updateBodyFigures:(NSDictionary*)dictionary
{
    //身高 体重 体温
    self.sgLB.text = [NSString stringWithFormat:@"身高:%@cm",dictionary[@"height"]];
    self.tzLB.text = [NSString stringWithFormat:@"体重:%@kg",dictionary[@"weight"]];
    self.twLB.text = [NSString stringWithFormat:@"体温:%@度",dictionary[@"temp"]];
    //体质指数
    self.zfhlLB.text = [NSString stringWithFormat:@"脂肪含量:%@",dictionary[@"fat"]];
    self.jcdxLB.text = [NSString stringWithFormat:@"基础代谢:%@kcal",dictionary[@"basalMetaRate"]];
    self.bmiLB.text = [NSString stringWithFormat:@"BMI:%@kg/m2",dictionary[@"bmi"]];
    self.txLB.text = [NSString stringWithFormat:@"体型:%@",dictionary[@"bodyType"]];
    
    //血糖 血氧
    self.ssyLB.text = [NSString stringWithFormat:@"收缩压:%@",dictionary[@"sbp"]];
    self.szyLB.text = [NSString stringWithFormat:@"舒张压:%@",dictionary[@"dbp"]];
    self.xyLB.text = [NSString stringWithFormat:@"血氧:%@",dictionary[@"spo2"]];
    self.xtLB.text = [NSString stringWithFormat:@"血糖:%@",dictionary[@"sugarData"]];
    self.xlLB.text = [NSString stringWithFormat:@"心率:%@",dictionary[@"hr"]];
    
    //肺活量
    self.fvcLB.text = [NSString stringWithFormat:@"FVC:%@",dictionary[@"fvc"]];
    self.fevLB.text = [NSString stringWithFormat:@"FEV1:%@",dictionary[@"fev1"]];
    self.pefLB.text = [NSString stringWithFormat:@"PEF:%@",dictionary[@"pef"]];
    self.pef25LB.text = [NSString stringWithFormat:@"FEF25:%@",dictionary[@"fef25"]];
    self.fef75LB.text = [NSString stringWithFormat:@"FEF75:%@",dictionary[@"fef75"]];
    self.fef2575LB.text = [NSString stringWithFormat:@"FEF2575:%@",dictionary[@"fef2575"]];
    //尿常规
    self.ndyLB.text = [NSString stringWithFormat:@"尿胆原:%@",dictionary[@"uro"]];
    self.dhsLB.text = [NSString stringWithFormat:@"胆红素:%@",dictionary[@"bil"]];
    self.qxLB.text = [NSString stringWithFormat:@"潜血:%@",dictionary[@"bld"]];
    self.sjzLB.text = [NSString stringWithFormat:@"酸碱值:%@",dictionary[@"ph"]];
    self.yxsyLB.text = [NSString stringWithFormat:@"亚硝酸盐:%@",dictionary[@"nit"]];
    self.bzLB.text = [NSString stringWithFormat:@"比重:%@",dictionary[@"sg"]];
    self.xxbLB.text = [NSString stringWithFormat:@"白细胞:%@",dictionary[@"leu"]];
    self.pttLB.text = [NSString stringWithFormat:@"葡萄糖:%@",dictionary[@"glu"]];
    self.ttLB.text = [NSString stringWithFormat:@"酮体:%@",dictionary[@"ket"]];
    self.dbzLB.text = [NSString stringWithFormat:@"蛋白质:%@",dictionary[@"pro"]];
    self.wsscLB.text = [NSString stringWithFormat:@"维生素C:%@",dictionary[@"vc"]];
    
    //时间
    [self.timeBtn setTitle:dictionary[@"date"] forState:UIControlStateNormal];
}


@end
