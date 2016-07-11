//
//  ItemsVC.m
//  Demo
//
//  Created by ZhuXiaoyan on 16/3/9.
//  Copyright © 2016年 Nelson. All rights reserved.
//

#import "ItemsVC.h"
#import "CardCell.h"
#import "MJRefresh.h"

#import "UIImageView+WebCache.h"
#import "ItemDataService.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "V2LoginTVC.h"
#import "KeyWord.h"
#import "KeywodCell.h"
#import "Classification.h"

@interface ItemsVC ()
@property (nonatomic, strong) NSArray *cellSizes;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) ItemDataService *dataService;
@property (nonatomic, assign) int currentPageNo;

@property (nonatomic, strong) Query *query;

@property (weak, nonatomic) IBOutlet UIButton *orderBySellBtn;
@property (weak, nonatomic) IBOutlet UIButton *orderByPricBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIMV;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterTopCST;
@property (weak, nonatomic) IBOutlet UICollectionView   *filterCollectionView;
@property (nonatomic,strong) NSMutableArray *classes;

@property (weak, nonatomic) IBOutlet UIImageView *sellArrowIMV;
@property (weak, nonatomic) IBOutlet UIImageView *priceArrowIMV;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;

@end

@implementation ItemsVC

#define PageSize            10
#define GoodsDetailSegue    @"To GoodsDetailVC"
#define OrderListSegue      @"To OrderListVC"

#define CELL_COUNT 30
#define CELL_IDENTIFIER @"CardCell"
#define CELL_FILTER_ID  @"KeyWordCell"

#pragma mark - Life Cycle

#define ThemColor [UIColor colorWithRed:236/255.0 green:97/255.0 blue:2/255.0 alpha:1]


- (void)viewDidLoad {
    [super viewDidLoad];
    //变量初始化
    self.dataService = [[ItemDataService alloc] init];
    
    //设置排序按钮颜色
    [self.orderBySellBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.orderBySellBtn setTintColor:[UIColor clearColor]];
    [self.orderBySellBtn setTitleColor:ThemColor forState:UIControlStateSelected];
    [self.orderByPricBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.orderByPricBtn setTitleColor:ThemColor forState:UIControlStateSelected];
    [self.orderByPricBtn setTintColor:[UIColor clearColor]];
    
    [self.filterBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.filterBtn setTitleColor:ThemColor forState:UIControlStateSelected];
    [self.filterBtn setTintColor:[UIColor clearColor]];
    
    //搜索底图
    UIColor *borderColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
    AddCornerBorder(self.searchBackView, self.searchBackView.size.height/2, 0.5, borderColor.CGColor);
    
    self.query = [[Query alloc] init];
    
    //筛选视图初始化
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    //筛选视图获取数据
    self.classes = [NSMutableArray new];
    [self fetchClassesWithUser:[[NSPublic shareInstance] getUserName]];
    
    
    self.cards = [NSMutableArray new];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(4, 4, 20, 4);
    layout.minimumColumnSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    
    _collectionView.collectionViewLayout = layout;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    __weak ItemsVC* weak_self = self;
    
    NSString *username = [[NSPublic shareInstance] getUserName];
    if (!username) {
        username = @"";
    }
    
    self.collectionView.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weak_self.currentPageNo ++;
        //[weak_self fillCardsWithTitle:@"" user:(NSString*)username from:weak_self.currentPageNo to:PageSize];
        weak_self.query.pageNum ++;
        weak_self.query.user = username;
        weak_self.query.pageSize = PageSize;
        [self fillCards];
        
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weak_self.currentPageNo = 0;
        //[self fillCardsWithTitle:@"" user:(NSString*)username from:weak_self.currentPageNo to:PageSize];
        
        weak_self.query.pageNum = 0;
        weak_self.query.user = username;
        weak_self.query.pageSize = PageSize;
        [self fillCards];
        
    }];

    [self.collectionView.mj_header setState:MJRefreshStateRefreshing];
}

- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    NSInteger viewTag = sender.view.tag;
    if (viewTag == 1980) {
        [self sort:self.orderBySellBtn];
    }else if (viewTag == 1981){
        [self sort:self.orderByPricBtn];
    }else{
        [self filter:self.filterBtn];
    }
    
}

- (IBAction)toSearch:(id)sender
{
    NSString *searchType = @"商品";
    UIViewController *searchVC  = VCFromStoryboard(@"Mall", @"MallSearchVC");
    [searchVC setValue:searchType forKey:@"searchType"];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:searchNav animated:YES completion:NULL];

}


- (IBAction)sort:(UIButton *)sender {
    
    //按钮颜色更改
    [self allBtnsUnSelected];
    sender.selected = YES;
    self.query.sortBy = [sender isEqual:self.orderBySellBtn] ? 1 : 2;
    
    //排序
    self.query.isAsc = self.query.isAsc == 1 ? 0: 1;
    
    [self.collectionView.mj_header setState:MJRefreshStateRefreshing];
    //关闭筛选视图
    if (self.filterBtn.isSelected) {
        [self filter:self.filterBtn];
    }
    
    //更改箭头方向
    if ([sender isEqual:self.orderBySellBtn]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.sellArrowIMV.transform= self.query.isAsc == 0 ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.priceArrowIMV.transform= self.query.isAsc == 0 ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
        }];
    }
}

- (void)allBtnsUnSelected
{
    self.orderBySellBtn.selected = NO;
    self.orderByPricBtn.selected = NO;
    self.sellArrowIMV.transform= CGAffineTransformMakeRotation(0);
    self.priceArrowIMV.transform= CGAffineTransformMakeRotation(0);
}

- (IBAction)filter:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.arrowIMV.transform= sender.isSelected ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
    }];
    
    self.filterTopCST.constant = sender.isSelected ? 4 : -220;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if (sender.isSelected && self.classes.count == 0) {
        [self fetchClassesWithUser:[[NSPublic shareInstance] getUserName]];
    }
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
    CHTCollectionViewWaterfallLayout *layout =
    (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.filterCollectionView]) {
        return self.classes.count;
    }else{
        return self.cards.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.filterCollectionView]) {
        Classification *model = self.classes[indexPath.row];
        KeywodCell *cell = (KeywodCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_FILTER_ID forIndexPath:indexPath];
        cell.wordLB.text = model.className;
        cell.wordLB.textColor = model.selected ? ThemColor : [UIColor darkGrayColor];
        return cell;
    }else{
        CardCell *cell =
        (CardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        [self fillCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.filterCollectionView]) {
        //更改选中状态
        Classification *model = self.classes[indexPath.row];
        model.selected = !model.selected;
        [self.filterCollectionView reloadData];
        //关闭筛选视图
        [self filter:self.filterBtn];
        //发起请求
        self.query.classId = model.selected ? model.cid : @"0";
        [self.collectionView.mj_header setState:MJRefreshStateRefreshing];
        
    }
}

- (void)fillCell:(CardCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    Goods *model = self.cards[indexPath.row];
    cell.nameLB.text = model.title;
    
    cell.priceLB.text = [NSString stringWithFormat:@"¥%.1f",model.salePrice];
    cell.pointLB.text = [NSString stringWithFormat:@"+%d积分",(int)model.needScore];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.imageList.firstObject] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedView.backgroundColor = [UIColor lightGrayColor];
    cell.selectedBackgroundView = selectedView;
    NSLog(@"image url: %@",model.imageList.firstObject);
    
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSString *oldPriceStr = [NSString stringWithFormat:@"原价:%.1f",model.marketPrice];
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:oldPriceStr attributes:attribtDic];
    cell.oldPriceLB.attributedText = attribtStr;
}


#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.filterCollectionView]) {
        Classification *model = self.classes[indexPath.row];
        return CGSizeMake(model.size.width + 16, model.size.height + 16);
    }else{
        if (indexPath.row %2 == 0) {
            return CGSizeMake(500, 660);
        }else{
            return CGSizeMake(500, 660);
        }

    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:GoodsDetailSegue]) {
        UICollectionViewCell *cell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath) {
            Goods *model = self.cards[indexPath.row];
            [segue.destinationViewController setValue:model.gId forKey:@"inputGoodsId"];
        }
    }
}

#pragma mark- data fetch relative
- (void)fillCardsWithTitle:(NSString*)title user:(NSString*)username from:(int)index to:(int)size
{ShowLog

    
    [self.dataService itemsWithTitle:title user:(NSString*)username from:index to:size withCallback:^(NSString *errorString, NSArray *items) {
       
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self.collectionView.mj_header setState:MJRefreshStateIdle];
        }else{
            if (index == 0) {
                [self.cards removeAllObjects];
                [self.collectionView.mj_header endRefreshing];
            }
            if (items.count > 0) {
                [self.cards addObjectsFromArray:items];
                [self.collectionView reloadData];
                [self.collectionView.mj_footer endRefreshing];
            }else{
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    }];
}

- (void)fillCards
{
    
    [self.dataService itemsWithQuery:self.query andCallback:^(NSString *errorString, NSArray *items) {
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self.collectionView.mj_header setState:MJRefreshStateIdle];
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            if (self.query.pageNum == 0) {
                [self.cards removeAllObjects];
                [self.collectionView.mj_header endRefreshing];
            }
            if (items.count > 0) {
                [self.cards addObjectsFromArray:items];
                [self.collectionView reloadData];
                [self.collectionView.mj_footer endRefreshing];
            }else{
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }

    }];
}

- (void)fetchClassesWithUser:(NSString*)user
{
    [self.dataService classesWith:user andCallback:^(NSString *errorString, NSArray *classes) {
        
        if (classes.count > 0) {
            [self.classes addObjectsFromArray:classes];
            [self.filterCollectionView reloadData];
        }
        
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:OrderListSegue]) {
        if ([[NSPublic shareInstance] getUserName].length == 0) {
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
