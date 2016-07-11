//
//  MenuView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "MenuView.h"
#import "KJLocation.h"


#define Main_Screen_Height [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width [[UIScreen mainScreen] bounds].size.width
#define KBgMaxHeight  Main_Screen_Height
#define KTableViewMaxHeight 300

#define KTopButtonHeight 44

#define kDuration 0.25
#define kColumn 4
#define CitiesKey @"cities"
#define StateKey @"state"
#define CityKey @"city"
#define AreasKey @"areas"


typedef enum : NSUInteger {
    KJAreaTypeProvinces = 0,
    KJAreaTypeCitys,
    KJAreaTypeAreas
} KJAreaType;


@implementation WSIndexPath


+ (instancetype)twIndexPathWithColumn:(NSInteger)column
                                  row:(NSInteger)row
                                 item:(NSInteger)item
                                 rank:(NSInteger)rank{
    
    WSIndexPath *indexPath = [[self alloc] initWithColumn:column row:row item:item rank:rank];
    
    
    return indexPath;
}


- (instancetype)initWithColumn:(NSInteger )column
                           row:(NSInteger )row
                          item:(NSInteger )item
                          rank:(NSInteger )rank{
    
    if (self = [super init]) {
        
        self.column = column;
        self.row = row;
        self.item = item;
        self.rank = rank;
        
    }
    
    return self;
}

@end

static NSString *cellIdent = @"cellIdent";

@interface MenuView ()<UITableViewDelegate,UITableViewDataSource>

{

    NSInteger _currSelectColumn;
    NSInteger _currSelectRow;
    NSInteger _currSelectItem;
    NSInteger _currSelectRank;
    
    CGFloat _rightHeight;
    CGFloat _midHeight;
    
    
    BOOL _isRightOpen;
    BOOL _isMidOpen;
    BOOL _isLeftOpen;


}

@property (nonatomic, strong) KJLocation *locate;

@property (nonatomic,strong) UITableView *leftTableView;
@property (nonatomic,strong) UITableView *leftTableView_1;
@property (nonatomic,strong) UITableView *leftTableView_2;

@property (nonatomic,strong) UITableView *midTableView;

@property (nonatomic,strong) UITableView *rightTableView;

@property (nonatomic,strong) UIButton *bgButton; //背景

@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *midButton;
@property (nonatomic,strong) UIButton *rightButton;


/**
 *  省份
 */
@property (nonatomic, strong) NSArray *provinces;
/**
 *  城市
 */
@property (nonatomic, strong) NSArray *cities;
/**
 *  地区
 */
@property (nonatomic, strong) NSArray *areas;


@end

@implementation MenuView

/**
 *  数据的懒加载
 *
 */
- (NSArray *)provinces
{
    if (_provinces == nil) {
        
        _provinces = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"]];
    }
    
    return _provinces;
}

- (KJLocation *)locate
{
    if (_locate == nil) {
        _locate = [[KJLocation alloc] init];
    }
    
    return _locate;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        
        [self setButton];
        [self initialize];
        [self setSubViews];
    }
    return self;
}


- (void)initialize{
    
    _currSelectColumn = 0;
    _currSelectItem = WSNoFound;
    _currSelectRank = WSNoFound;
    _currSelectRow = WSNoFound;
    _isLeftOpen = NO;
    _isMidOpen  = NO;
    _isRightOpen = NO;
}

- (void)setButton{

    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.frame = CGRectMake(0, 0, Main_Screen_Width/3, KTopButtonHeight);
    [self.leftButton setTitle:LeftButtonTitle forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor colorWithWhite:0.004 alpha:1.000] forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.leftButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.leftButton.frame), 12, 1, 20)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line1];
    
    self.midButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.midButton .frame = CGRectMake(CGRectGetMaxX(self.leftButton .frame)+1, 0, Main_Screen_Width/3, KTopButtonHeight);
    [self.midButton  setTitle:MidButtonTitle forState:UIControlStateNormal];
    [self.midButton  addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.midButton setTitleColor:[UIColor colorWithWhite:0.004 alpha:1.000]  forState:UIControlStateNormal];
    self.midButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:self.midButton ];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.midButton.frame), 12, 1, 20)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line2];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton .frame = CGRectMake(CGRectGetMaxX(self.midButton .frame)+1, 0, Main_Screen_Width/3, KTopButtonHeight);
    [self.rightButton  setTitle:RightButtonTitle forState:UIControlStateNormal];
    [self.rightButton  addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTitleColor:[UIColor colorWithWhite:0.004 alpha:1.000]  forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:self.rightButton ];
    
    UIView *bottomShadow = [[UIView alloc]
                            initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, Main_Screen_Width, 0.5)];
    bottomShadow.backgroundColor = [UIColor colorWithRed:0.468 green:0.485 blue:0.465 alpha:1.000];
    [self addSubview:bottomShadow];

}


- (void)setSubViews{

    [self addSubview:self.bgButton];
    [self.bgButton addSubview:self.leftTableView];
    [self.bgButton addSubview:self.leftTableView_1];
    [self.bgButton addSubview:self.leftTableView_2];
    [self.bgButton addSubview:self.midTableView];
    [self.bgButton addSubview:self.rightTableView];

}

- (void)reloadLeftTableView{

    [self.leftTableView reloadData];

}

- (void)reloadMidTableView{

    [self.midTableView reloadData];
}

- (void)reloadRightTableView{

    [self.rightTableView reloadData];
}

#pragma mark -- getter -- 
- (UITableView *)leftTableView{

    if (!_leftTableView) {
        
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        [_leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        _leftTableView.frame = CGRectMake(0, 0, self.bgButton.frame.size.width/3.0, 0);
        _leftTableView.tableFooterView = [[UIView alloc]init];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _leftTableView;
}

- (UITableView *)leftTableView_1{
    
    if (!_leftTableView_1) {
        
        _leftTableView_1 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _leftTableView_1.delegate = self;
        _leftTableView_1.dataSource = self;
        [_leftTableView_1 registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        _leftTableView_1.frame = CGRectMake( self.bgButton.frame.size.width/3.0, 0 , self.bgButton.frame.size.width/3.0, 0);
        _leftTableView_1.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        _leftTableView_1.tableFooterView = [[UIView alloc]init];
        
        
    }
    
    return _leftTableView_1;
    
}

- (UITableView *)leftTableView_2{
    
    if (!_leftTableView_2) {
        
        _leftTableView_2 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _leftTableView_2.delegate = self;
        _leftTableView_2.dataSource = self;
        [_leftTableView_2 registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        _leftTableView_2.frame = CGRectMake( self.bgButton.frame.size.width/3.0 * 2, 0 , self.bgButton.frame.size.width/3.0, 0);
        _leftTableView_2.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
        _leftTableView_2.tableFooterView = [[UIView alloc]init];
        
    }
    
    return _leftTableView_2;
}


-(UITableView *)midTableView{

    if (!_midTableView) {
        
        _midTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _midTableView.delegate = self;
        _midTableView.dataSource = self;
        [_midTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        _midTableView.frame = CGRectMake(0, 0 , self.bgButton.frame.size.width, 0);
        _midTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _midTableView;
}


- (UITableView *)rightTableView{
    
    if (!_rightTableView) {
        
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        [_rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        _rightTableView.frame = CGRectMake(0, 0 , self.bgButton.frame.size.width, 0);
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _rightTableView;
}

- (UIButton *)bgButton{
    
    if (!_bgButton) {
        
        _bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgButton.backgroundColor = [UIColor clearColor];
        _bgButton.frame = CGRectMake(0, KTopButtonHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - KTopButtonHeight);
        [_bgButton addTarget:self action:@selector(bgAction:) forControlEvents:UIControlEventTouchUpInside];
        _bgButton.clipsToBounds = YES;
        
    }
    
    return _bgButton;
}

#pragma mark -- tableViews Change -
- (void)_hiddenLeftTableViews{
    
    self.leftTableView.frame = CGRectMake(self.leftTableView.frame.origin.x, self.leftTableView.frame.origin.y, self.leftTableView.frame.size.width, 0);
    self.leftTableView_1.frame = CGRectMake(self.leftTableView_1.frame.origin.x, self.leftTableView_1.frame.origin.y, self.leftTableView_1.frame.size.width, 0);
    self.leftTableView_2.frame = CGRectMake(self.leftTableView_2.frame.origin.x, self.leftTableView_2.frame.origin.y, self.leftTableView_2.frame.size.width, 0);
    
}

- (void)_showLeftTableViews{
    
    self.leftTableView.frame = CGRectMake(self.leftTableView.frame.origin.x, self.leftTableView.frame.origin.y, self.leftTableView.frame.size.width, KTableViewMaxHeight);
    self.leftTableView_1.frame = CGRectMake(self.leftTableView_1.frame.origin.x, self.leftTableView_1.frame.origin.y, self.leftTableView_1.frame.size.width, KTableViewMaxHeight);
    self.leftTableView_2.frame = CGRectMake(self.leftTableView_2.frame.origin.x, self.leftTableView_2.frame.origin.y, self.leftTableView_2.frame.size.width, KTableViewMaxHeight);
}

- (void)_showMidTableView{
    
    CGFloat height = MIN(_midHeight, KTableViewMaxHeight);
    
    self.midTableView.frame = CGRectMake(self.midTableView.frame.origin.x, self.midTableView.frame.origin.y, self.midTableView.frame.size.width, height);
}

- (void)_HiddenMidTableView{
    
    
    self.midTableView.frame = CGRectMake(self.midTableView.frame.origin.x, self.midTableView.frame.origin.y, self.midTableView.frame.size.width, 0);
}

- (void)_showRightTableView{
    
    CGFloat height = MIN(_rightHeight, KTableViewMaxHeight);
    
    self.rightTableView.frame = CGRectMake(self.rightTableView.frame.origin.x, self.rightTableView.frame.origin.y, self.rightTableView.frame.size.width, height);
}

- (void)_HiddenRightTableView{
    
    
    self.rightTableView.frame = CGRectMake(self.rightTableView.frame.origin.x, self.rightTableView.frame.origin.y, self.rightTableView.frame.size.width, 0);
}

- (void)_changeTopButton:(NSString *)string{
    
    if (_currSelectColumn == 0) {
        
        [self.leftButton setTitle:string forState:UIControlStateNormal];
    }
    if (_currSelectColumn == 1) {
        
        [self.midButton setTitle:string forState:UIControlStateNormal];
//        _major = self.midButton.titleLabel.text;
//        _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
//        if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
//            [self.delegate touchMenu:_array];
//        }
    }
    if (_currSelectColumn == 2) {
        
        [self.rightButton setTitle:string forState:UIControlStateNormal];
//        _userType = self.rightButton.titleLabel.text;
//        _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
//        if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
//            [self.delegate touchMenu:_array];
 //       }
    }
    
}

#pragma mark -- Action ----

- (void)buttonAction:(UIButton *)sender{
    if (self.leftButton == sender) {
        if (_isLeftOpen) {
            _isLeftOpen = !_isLeftOpen;
            [self bgAction:nil];
            return ;
        }
        _currSelectColumn = 0;
        _isLeftOpen = YES;
        _isMidOpen = NO;
        _isRightOpen = NO;
        [self _HiddenRightTableView];
        [self _HiddenMidTableView];
        
    }
    if (self.midButton == sender) {
        
        if (_isMidOpen) {
            
            _isMidOpen = !_isMidOpen;
            [self bgAction:nil];
            return;
        }
        _currSelectColumn = 1;
        _isMidOpen = YES;
        _isLeftOpen = NO;
        _isRightOpen = NO;
        [self _HiddenRightTableView];
        [self _hiddenLeftTableViews];
    }
    if (self.rightButton == sender) {
        
        if (_isRightOpen) {
            _isRightOpen = !_isRightOpen;
            [self bgAction:nil];
            return ;
        }
        
        _currSelectColumn = 2;
        _isRightOpen = YES;
        _isLeftOpen = NO;
        _isMidOpen = NO;
        [self _hiddenLeftTableViews];
        [self _HiddenMidTableView];
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, Main_Screen_Width, Main_Screen_Height);
    self.bgButton.frame = CGRectMake(self.bgButton.frame.origin.x, self.bgButton.frame.origin.y, self.bounds.size.width, self.bounds.size.height - KTopButtonHeight);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bgButton.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
        
        if (_currSelectColumn == 0) {
            [self _showLeftTableViews];
        }
        if (_currSelectColumn == 1) {
            
            [self _showMidTableView];
        }
        if (_currSelectColumn == 2) {
            
            [self _showRightTableView];
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)bgAction:(UIButton *)sender{
    
    _isRightOpen = NO;
    _isLeftOpen = NO;
    _isMidOpen = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        
        self.bgButton.backgroundColor = [UIColor clearColor];
        [self _hiddenLeftTableViews];
        [self _HiddenMidTableView];
        [self _HiddenRightTableView];
        
        
    } completion:^(BOOL finished) {
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, Main_Screen_Width, KTopButtonHeight);
        self.bgButton.frame = CGRectMake(self.bgButton.frame.origin.x, self.bgButton.frame.origin.y, self.bounds.size.width, 0);
        
    }];
}


#pragma mark -- DataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
                                    
    WSIndexPath *twIndexPath =[self _getTwIndexPathForNumWithtableView:tableView];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dropMenuView:numberWithIndexPath:Provinces:Cities:Areas:)]) {
        
        NSInteger count =  [self.dataSource dropMenuView:self numberWithIndexPath:twIndexPath Provinces:self.provinces Cities:self.cities Areas:self.areas];
        if (twIndexPath.column == 1 ) {
            _midHeight = count * 44.0;
        }
        if (twIndexPath.column == 2){
            _rightHeight = count *44.0;
        }
        return count;
    }else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    WSIndexPath *twIndexPath = [self _getTwIndexPathForCellWithTableView:tableView indexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor =  [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.004 alpha:1.000];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    //    [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dropMenuView:titleWithIndexPath:Provinces:Cities:Areas:)]) {
        
        cell.textLabel.text =  [self.dataSource dropMenuView:self titleWithIndexPath:twIndexPath  Provinces:self.provinces Cities:self.cities Areas:self.areas];
        
       // NSLog(@"*************++++++++++++++%@",cell.textLabel.text);
    }else{
        
        //cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    }
    
    return cell;
}

#pragma mark - tableView delegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"*************++++++++++++++++++++++%@_____________%ld",cell.textLabel.text,indexPath.row);
    [self _changeTopButton:cell.textLabel.text ];
    
    if (tableView == self.leftTableView) {
        _currSelectRow = indexPath.row;
        _currSelectItem = WSNoFound;
        _currSelectRank = WSNoFound;
        
        [self.leftTableView_1 reloadData];
        [self.leftTableView_2 reloadData];
        if (![_str1 isEqualToString:cell.textLabel.text]) {
            _str1 = cell.textLabel.text;
            if ([_str1 isEqualToString:@"全部"]) {
                _address = [NSString stringWithFormat:@"%@",_str1];
                _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
                if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
                    [self.delegate touchMenu:_array];
                }
                [self bgAction:nil];
            }
        }
        NSLog(@"第一级%@",cell.textLabel.text);
    }
    if (tableView == self.leftTableView_1) {
        _currSelectRank = WSNoFound;
        _currSelectItem = indexPath.row;

        [self.leftTableView_2 reloadData];
         NSLog(@"第二级%@",cell.textLabel.text);
        if (![_str2 isEqualToString:cell.textLabel.text]) {
            _str2 = cell.textLabel.text;
        }
    }
    
    if (self.leftTableView_2 == tableView) {
        
        NSLog(@"第三级%@",cell.textLabel.text);
        if (![_str3 isEqualToString:cell.textLabel.text]) {
            _str3 = cell.textLabel.text;
            _address = [NSString stringWithFormat:@"%@ %@ %@",_str1,_str2,_str3];
            _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
            if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
                [self.delegate touchMenu:_array];
            }
        }
        [self bgAction:nil];
    }
    if (self.midTableView == tableView) {
        if (_num1!=indexPath.row) {
            _num1 = indexPath.row;
            _major = [NSString stringWithFormat:@"%ld",_num1];
            _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
            if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
                [self.delegate touchMenu:_array];
            }
        }
        [self bgAction:nil];
        
    }
    
    if (self.rightTableView == tableView) {
        if (_num2 !=indexPath.row+1) {
            _num2 = indexPath.row+1;
            _userType = [NSString stringWithFormat:@"%ld",_num2];
            _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
            if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
                [self.delegate touchMenu:_array];
            }
        }
        [self bgAction:nil];
        
    }
}

/**
 *  选中某列某行
 *
 */
- (void)didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case KJAreaTypeProvinces: // 选中第一列
            // 修改cities数据
            self.cities = [self.provinces[row] objectForKey:CitiesKey];
            
            // 刷新第三列
            //[self reloadAreaComponentWithRow:0];
            
            self.locate.state = [[self.provinces objectAtIndex:row] objectForKey:StateKey];
            
            break;
            
        case KJAreaTypeCitys: // 选中第二列
        {
            self.areas = [self.cities[row] objectForKey:AreasKey];
            
            
            
            
            [self reloadAreaComponentWithRow:row];
        }
            break;
        case KJAreaTypeAreas: // 选中第三列
            if ([self.areas count] > 0) {
                self.locate.district = [self.areas objectAtIndex:row];
                
                NSLog(@"+*_+*_+*_+*_+*_%@",self.locate.district);
            } else{
                self.locate.district = @"";
            }
            break;
            
        default:
            break;
    }
    
    
}

- (void)reloadAreaComponentWithRow:(NSInteger)row
{
    self.areas = [self.cities[row] objectForKey:AreasKey];
    self.locate.city = [[self.cities objectAtIndex:row] objectForKey:CityKey];
    NSLog(@"%@",self.locate.city);
    
//    if ([self.areas count] > 0) {
//        self.locate.district = [self.areas objectAtIndex:0];
//    } else{
//        [self bgAction:nil];
//        self.locate.district = @"";
//    }
    //如果是直辖市者点到其后面一级就将弹框收回
    if (self.areas.count == 0) {
        //[self bgAction:nil];
        _address = [NSString stringWithFormat:@"%@ %@ %@",_str1,_str1,self.locate.city];
        _array =[NSArray arrayWithObjects:_address,_major,_userType, nil];
        if ([self.delegate respondsToSelector:@selector(touchMenu:)]) {
            [self.delegate touchMenu:_array];
        }
        [self bgAction:nil];
    }
}


- (WSIndexPath *)_getTwIndexPathForNumWithtableView:(UITableView *)tableView{

    if (tableView == self.leftTableView) {
        
        [self didSelectRow:0 inComponent:0];
        return  [WSIndexPath twIndexPathWithColumn:_currSelectColumn row:WSNoFound item:WSNoFound rank:WSNoFound];
        
    }
    
    if (tableView == self.leftTableView_1 && _currSelectRow != WSNoFound) {
        
        [self didSelectRow:_currSelectRow inComponent:0];
        NSLog(@"%@",self.cities);
        return [WSIndexPath twIndexPathWithColumn:_currSelectColumn row:_currSelectRow item:WSNoFound rank:WSNoFound];
    }
    
    if (tableView == self.leftTableView_2 && _currSelectRow != WSNoFound && _currSelectItem != WSNoFound) {
        [self didSelectRow:_currSelectItem inComponent:1];
        return [WSIndexPath twIndexPathWithColumn:_currSelectColumn row:_currSelectRow item:_currSelectItem  rank:WSNoFound];
    }
    
    if (tableView == self.midTableView) {
        
        return [WSIndexPath twIndexPathWithColumn:1 row:WSNoFound item:WSNoFound  rank:WSNoFound];
    }
    if (tableView == self.rightTableView) {
        
        return [WSIndexPath twIndexPathWithColumn:2 row:WSNoFound item:WSNoFound  rank:WSNoFound];
    }
    return  0;

}

- (WSIndexPath *)_getTwIndexPathForCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{

    
    if (tableView == self.leftTableView) {
        
        return  [WSIndexPath twIndexPathWithColumn:0 row:indexPath.row item:WSNoFound rank:WSNoFound];
        
    }
    
    if (tableView == self.leftTableView_1) {
        
        
        return [WSIndexPath twIndexPathWithColumn:_currSelectColumn row:_currSelectRow item:indexPath.row rank:WSNoFound];
    }
    
    if (tableView == self.leftTableView_2) {
        return [WSIndexPath twIndexPathWithColumn:_currSelectColumn row:_currSelectRow item:_currSelectItem  rank:indexPath.row];
    }
    
    if (tableView == self.midTableView) {
        
        return [WSIndexPath twIndexPathWithColumn:1 row:indexPath.row item:WSNoFound  rank:WSNoFound];
    }
    
    if (tableView == self.rightTableView) {
        
        return [WSIndexPath twIndexPathWithColumn:2 row:indexPath.row item:WSNoFound  rank:WSNoFound];
    }
    return  [WSIndexPath twIndexPathWithColumn:0 row:indexPath.row item:WSNoFound rank:WSNoFound];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

@end
