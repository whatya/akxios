//
//  ItemDetailVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ItemDetailVC.h"
#import "CommonConstants.h"
#import "UIImageView+WebCache.h"
#import "ItemDataService.h"
#import "ProgressHUD.h"
#import "Order.h"
#import "NSPublic.h"
#import "V2LoginTVC.h"
#import "WXApi.h"
#import "WXMediaMessage+messageConstruct.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#import "SelectUser.h"
#import "SkillShareParam.h"

#define BUFFER_SIZE 1024 * 100

@interface ItemDetailVC ()<UIWebViewDelegate,UIActionSheetDelegate>

@property (nonatomic,strong) UIImageView *shareImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightCST;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *imagesView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSArray *imgUrls;
@property (nonatomic,assign) int index;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

//price related
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLB;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLB;
@property (weak, nonatomic) IBOutlet UILabel *marketPriceLB;
@property (weak, nonatomic) IBOutlet UILabel *noteLB;

//pay related
@property (weak, nonatomic) IBOutlet UILabel *countLB;
@property (weak, nonatomic) IBOutlet UIView *payView;
@property (weak, nonatomic) IBOutlet UILabel *discountRateLB;

//indicator
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;

@property (nonatomic,strong) ItemDataService *dataService;
@property (nonatomic,assign) int purchaseCount;
@property (weak, nonatomic) IBOutlet UIButton *purchaseBtn;

@property (nonatomic,strong) Item *fetchedGoods;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productInforHeightCST; //117

//Skill related

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skillInforHeightCST; //200
@property (weak, nonatomic) IBOutlet UILabel *skillTitleLB;
@property (weak, nonatomic) IBOutlet UILabel *skillSlaePriceLB;
@property (weak, nonatomic) IBOutlet UILabel *skillDiscountRateLB;
@property (weak, nonatomic) IBOutlet UILabel *skillTotalTimeLB;
@property (weak, nonatomic) IBOutlet UILabel *skillTimesLB;
@property (weak, nonatomic) IBOutlet UIButton *skillByBtn;
@property (weak, nonatomic) IBOutlet UILabel *countTipLB;
@property (weak, nonatomic) IBOutlet UIButton *minsBtn;
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;


@end

@implementation ItemDetailVC

#define ToCashVC @"To CashVC"

#define ThemColor [UIColor colorWithRed:255/255.0 green:77/255.0 blue:8/255.0 alpha:1]

- (IBAction)die:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)share:(UIButton *)sender {
    UIActionSheet *shareSheet = [[UIActionSheet alloc]
                                 initWithTitle:@"微信分享"
                                 delegate:self
                                 cancelButtonTitle:@"取消"
                                 destructiveButtonTitle:@"微信好友"
                                 otherButtonTitles:@"朋友圈", nil];
    [shareSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    
    [self sendAppMessageInSence:(int)buttonIndex];
}


#pragma mark- 分享
- (void) sendAppMessageInSence:(int)sence
{
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    UIImage *thumbImage = [UIImage imageNamed:@"shareIcon"];
    
    NSString *url = [NSString stringWithFormat:@"http://h5.3chunhui.com/chunhui-h5/src/template/appProductView.html?id=%@",self.fetchedGoods.gId];
    
    NSString *title = self.fetchedGoods.title;
    if (title.length > 32) {
        title = [title substringToIndex:32];
    }
    
    NSString *desc = self.fetchedGoods.feature;
    if (desc.length > 32) {
        desc = [desc substringToIndex:32];
    }
    
    [self sendAppContentData:data
                     ExtInfo:@"<xml>extend info</xml>"
                      ExtURL:url
                       Title:title
                 Description:desc
                  MessageExt:desc
               MessageAction:@"<action></action>"
                  ThumbImage:thumbImage
                     InScene:sence];
}

- (BOOL)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene {
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    
    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:messageExt
                                                 MessageAction:action
                                                    ThumbImage:thumbImage
                                                      MediaTag:nil];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
    
}


- (IBAction)order:(id)sender {
    
    if ([self.itemType isEqualToString:@"服务"]) {
        
        Order *order = [[Order alloc] init];
        order.goods = self.fetchedGoods;
        order.orderNum = 1;
        order.payNum = self.fetchedGoods.salePrice;
        order.gId = self.fetchedGoods.gId;
        order.payPaltform = 1;
        order.username = [[NSPublic shareInstance] getUserName];
        order.deuctionNum = 0;
        order.isDeduction = self.fetchedGoods.isDeduction;
        order.deductionRate = self.fetchedGoods.deductionRate;
        order.salePrice = self.fetchedGoods.salePrice;
        
        if ([self.type isEqualToString:@"按次服务"]) {
            order.orderType = @"按次服务";
            PUSH(@"Mall", @"SkillTermConfirmTVC", @"订单确认", @{@"inputOrder":order}, YES);
        }else{
            
            //单利传递参数
            [[SkillShareParam sharedSkill] clear];
            [SkillShareParam sharedSkill].order = order;
            PUSH(@"Service", @"SelectUserVC", @"用户选择", @{},YES);
            
        }
        
        
        
    }
}

#define MinusTag 1973
#define PlusTag  1974
- (IBAction)toogleCount:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    if (tag == MinusTag) {
        if (self.purchaseCount > 1) {
            self.purchaseCount--;
        }
        
    }else{
        self.purchaseCount++;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.purchaseCount = 1;
    AddCornerBorder(self.skillByBtn, 2, 1, ThemColor.CGColor)
    AddCornerBorder(self.purchaseBtn, 2, 1, ThemColor.CGColor)
    self.imgUrls = [NSArray new];
    self.webView.delegate = self;
    self.webView.userInteractionEnabled = NO;
    //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qq.com"]]];
    
    if ([self.itemType isEqualToString:@"服务"]) {
        self.countLB.hidden = YES;
        self.countTipLB.hidden = YES;
        self.minsBtn.hidden = YES;
        self.purchaseBtn.hidden = YES;
        self.plusBtn.hidden = YES;
        
        
        self.productInforHeightCST.constant = 0;
        [self.view layoutIfNeeded];
        
    }else{
        
        self.skillByBtn.hidden = YES;
        
        self.skillInforHeightCST.constant = 0;
        [self.view layoutIfNeeded];
        
    }
    
    self.dataService = [[ItemDataService alloc] init];
    [self descWithId:self.inputGoodsId andUsername:@""];
    
    
}



- (void)setPurchaseCount:(int)purchaseCount
{
    _purchaseCount = purchaseCount;
    self.countLB.text = [NSString stringWithFormat:@"%d",purchaseCount];
}

- (void)setImgUrls:(NSArray *)imgUrls
{
    _imgUrls = imgUrls;
    if (imgUrls.count > 0) {
        //获取原始宽高
        CGFloat width = self.imagesView.bounds.size.width;
        CGFloat height = self.imagesView.bounds.size.height;
        
        //计算content size
        CGSize contentSize = CGSizeMake(width * imgUrls.count, height);
        self.scrollView.contentSize = contentSize;
        self.scrollView.pagingEnabled = YES;
        
        //添加图片到scrollview
        for (int i = 0; i < imgUrls.count; i++) {
            //计算图片的frame
            NSString *urlStr = imgUrls[i];
            CGFloat x = i * width;
            CGFloat y = 0;
            CGRect frame = CGRectMake(x, y, width, height);
            
            //添加图片
            UIImageView *image = [[UIImageView alloc] initWithFrame:frame];
            image.clipsToBounds = YES;
            image.contentMode = UIViewContentModeScaleAspectFill;
            
            //设置网络图片
            [image sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
            
            if (i == 0) {
                self.shareImage = image;
            }
            
            [self.scrollView addSubview:image];
        }
        
        //设置pagecontrol
        self.pageControl.numberOfPages = imgUrls.count;
        
        //开始轮播
        [self nextPage];
    }
}

- (void)nextPage
{
    self.index ++;
    if (self.index == self.imgUrls.count) {
        self.index = 0;
    }
    CGFloat x = self.imagesView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(x * self.index, 0) animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nextPage];
    });
}

- (void)setIndex:(int)index
{
    _index = index;
    self.pageControl.currentPage = index;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.flower stopAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        webView.width = [UIScreen mainScreen].bounds.size.width;
        //use js to get height dynamically
        CGFloat scrollSizeHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
        self.contentHeightCST.constant = scrollSizeHeight;
        [self.view layoutIfNeeded];
    });
    
    
}

#pragma mark- data fetch
- (void)descWithId:(NSString*)iId andUsername:(NSString*)username
{ShowLog
    
    if ([self.itemType isEqualToString:@"服务"]) {
        [self.dataService skillDescWithID:iId andUserName:username withCallback:^(NSString *errorString, Skill *skill) {
           
            if (errorString) {
                [ProgressHUD showError:errorString];
            }else{
                [self updateUIWithGoos:skill];
            }

            
        }];
        
        return;
    }
    
    [self.dataService itemDescWithID:iId andUserName:username withCallback:^(NSString *errorString, Goods *item) {
       
        if (errorString) {
            [ProgressHUD showError:errorString];
        }else{
            [self updateUIWithGoos:item];
        }
        
    }];
    
}

- (void)updateUIWithGoos:(Item*)model
{ShowLog
    self.fetchedGoods = model;
    

    self.titleLB.text = model.title;
    
    
    self.subTitleLB.text = model.feature;
    
    self.salePriceLB.text = [NSString stringWithFormat:@"¥%.1f",model.salePrice];
    
    
    self.marketPriceLB.text = [NSString stringWithFormat:@"原价 ¥%.1f",model.marketPrice];
    
    self.subTitleLB.text = model.feature;
    
    if (![model.provider isEqualToString:@"无"]) {
        self.noteLB.text = [NSString stringWithFormat:@"%@ 提供",model.provider];
    }
    
    self.discountRateLB.text = [NSString stringWithFormat:@"+%d积分",(int)model.needScore];
   
    
    self.imgUrls = model.imageList;
    
    if ([self.itemType isEqualToString:@"服务"]) {
        Skill *skill = (Skill*)model;
        self.skillTitleLB.text = skill.title;
        self.skillSlaePriceLB.text = [NSString stringWithFormat:@"¥%.1f",skill.salePrice];
        
        if (skill.serviceTerm > 0) {
            self.skillTotalTimeLB.text = [NSString stringWithFormat:@"服务周期：%d个月",skill.serviceTerm];
        }else{
            self.skillTotalTimeLB.text = @"";
        }
        self.skillTimesLB.text = [NSString stringWithFormat:@"服务次数：%d次",skill.useTimes];
        self.skillDiscountRateLB.text = [NSString stringWithFormat:@"+%d积分",(int)skill.needScore];
        self.skillTotalTimeLB.hidden = !skill.isShowInfo;
        self.skillTimesLB.hidden = !skill.isShowInfo;

    }
    
    [self.webView loadHTMLString:model.goodsDesc baseURL:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ToCashVC]) {
        //初始化订单对象
        Order *order = [[Order alloc] init];
        
        order.goods = self.fetchedGoods;
        order.orderNum = self.purchaseCount;
        order.payNum = self.purchaseCount * self.fetchedGoods.salePrice;
        order.gId = self.fetchedGoods.gId;
        order.payPaltform = 1;
        order.username = [[NSPublic shareInstance] getUserName];
        order.deuctionNum = 0;
        order.isDeduction = self.fetchedGoods.isDeduction;
        order.deductionRate = self.fetchedGoods.deductionRate;
        order.salePrice = self.fetchedGoods.salePrice;
        
        [segue.destinationViewController setValue:order forKey:@"inputOrder"];
        
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:ToCashVC]) {
        
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

@end


