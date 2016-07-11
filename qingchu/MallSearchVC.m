//
//  MallSearchVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "MallSearchVC.h"
#import "KeywodCell.h"
#import "KeyWord.h"
#import "SearchResultCell.h"
#import "CommonConstants.h"
#import "ItemDataService.h"
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "Goods.h"
#import "NSPublic.h"

@interface MallSearchVC ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray *searchItems;
@property (nonatomic,strong) NSMutableArray *keyWords;

@property (nonatomic,strong) ItemDataService *dataService;

@end

@implementation MallSearchVC

#define WordCellID      @"KeyWordCell"
#define ResultCellID    @"SearchResultCell"

#define KeywordsKey     @"MallSearchKeywords"

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
- (IBAction)cancelSearch:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#define ItemPlaceHolder @"请输入商品名称"
#define SkillPlaceHolder @"请输入服务名称"

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *placeHolder = [self.searchType isEqualToString:@"服务"] ? SkillPlaceHolder :ItemPlaceHolder;
    self.searchBar.placeholder = placeHolder;
    self.searchBar.delegate = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchBar becomeFirstResponder];
    });
    self.searchItems = [NSMutableArray new];
    self.keyWords = [NSMutableArray new];
    self.dataService = [[ItemDataService alloc] init];
    [self showTips];
}

- (void)showTips
{
    [self.keyWords removeAllObjects];
    [self.keyWords addObjectsFromArray:[self wordsModel]];
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length > 0) {
        [self.view endEditing:YES];
        NSString *text = searchBar.text;
        [self saveWord:text];
        [self.keyWords removeAllObjects];
        NSString *username = [[NSPublic shareInstance] getUserName];
        if (!username) {
            username = @"";
        }
        
        [self fillCardsWithTitle:text user:username from:0 to:100];
    }
    
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        [self showTips];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.keyWords.count == 0 ? self.searchItems.count : self.keyWords.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.keyWords.count == 0) {
        Item *model = self.searchItems[indexPath.row];
        SearchResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ResultCellID forIndexPath:indexPath];
        cell.titleLB.text = model.title;
        cell.salePriceLB.text = [NSString stringWithFormat:@"¥%.1f",model.salePrice];
        NSString *imageUrl = model.imageList.firstObject;
        [cell.IMV sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
        AddCornerBorder(cell.IMV, 2, 0.5, [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1].CGColor);
        return cell;
        
    }else{
        KeywodCell *wordCell = [collectionView dequeueReusableCellWithReuseIdentifier:WordCellID forIndexPath:indexPath];
        KeyWord *wordModel = self.keyWords[indexPath.row];
        wordCell.wordLB.text = wordModel.keyWord;
        
        return wordCell;
    }
    
   
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.keyWords.count > 0) {
        [self.view endEditing:YES];
        KeyWord *toBeSearchd = self.keyWords[indexPath.row];
        self.searchBar.text = toBeSearchd.keyWord;
        [self.keyWords removeAllObjects];
        
        NSString *username = [[NSPublic shareInstance] getUserName];
        if (!username) {
            username = @"";
        }
        
        [self fillCardsWithTitle:toBeSearchd.keyWord user:username from:0 to:100];
        
    }else{
        Item *model = self.searchItems[indexPath.row];
        
        if ([self.searchType isEqualToString:@"服务"]) {
            
            if ([self.type isEqualToString:@"按次服务"]) {
                PUSH(@"Mall", @"ItemDetailVC", @"服务详情", (@{@"inputGoodsId":model.gId,@"itemType":@"服务",@"type":@"按次服务"}), YES);
            }else{
                PUSH(@"Mall", @"ItemDetailVC", @"服务详情", (@{@"inputGoodsId":model.gId,@"itemType":@"服务"}), YES);
            }
            
            
        }else{
            
            PUSH(@"Mall", @"ItemDetailVC", @"商品详情", @{@"inputGoodsId":model.gId}, YES)
        }
        
        
    }
}


#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.keyWords.count == 0) {
        
        return CGSizeMake(Screen_Width, 68);
        
    }else{
        KeyWord *model = self.keyWords[indexPath.row];
        return CGSizeMake(model.wordSize.width+16, model.wordSize.height+16);
    }
    
}


- (void)saveWord:(NSString*)word
{
    if (word.length == 0) {
        return;
    }
    
    NSMutableArray *words = [[[NSUserDefaults standardUserDefaults] objectForKey:KeywordsKey] mutableCopy];
    if (words) {
        for (NSString *tempWord in words){
            if ([word isEqualToString:tempWord]) {
                return;
            }
        }
        
        [words addObject:word];
        [[NSUserDefaults standardUserDefaults] setObject:words forKey:KeywordsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        words = [NSMutableArray new];
        [words addObject:word];
        [[NSUserDefaults standardUserDefaults] setObject:words forKey:KeywordsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray*)wordsModel
{
    NSArray *words = [[NSUserDefaults standardUserDefaults] objectForKey:KeywordsKey];
    if (!words) {
        return @[];
    }
    
    NSMutableArray *models = [NSMutableArray new];
    for (NSString* wordStr in words){
        KeyWord *model = [[KeyWord alloc] init];
        model.keyWord = wordStr;
        model.wordSize = [wordStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        [models addObject:model];
    }
    return models;
}

#pragma mark- data fetch relative
- (void)fillCardsWithTitle:(NSString*)title user:(NSString*)username from:(int)index to:(int)size
{ShowLog
    [ProgressHUD show:@"搜索中..."];
    
    Query *query = [[Query alloc] init];
    query.user = username;
    query.title = title;
    query.pageNum = index;
    query.pageSize = size;
    query.pType = [self.searchType isEqualToString:@"服务"] ? 1 : 0;
    
    [self.dataService itemsWithQuery:query andCallback:^(NSString *errorString, NSArray *items) {
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self showTips];
        }else{
            [ProgressHUD dismiss];
            [self.searchItems removeAllObjects];
            [self.searchItems addObjectsFromArray:items];
            [self.collectionView reloadData];
            
            NSLog(@"%@",self.searchItems);
        }

    }];
    
}

@end
