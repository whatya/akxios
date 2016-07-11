//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "RootViewController.h"
#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "amrFileCodec.h"
#import "Base64.h"
#import "Room.h"
#import "ChatVC.h"
#import "CHTermUser.h"

@interface RootViewController ()
<UUInputFunctionViewDelegate,
UUMessageCellDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (strong, nonatomic) MJRefreshHeader *head;
@property (strong, nonatomic) ChatModel *chatModel;

@property (weak,  nonatomic) IBOutlet UITableView *chatTableView;
@property (weak,  nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong,nonatomic) Room *room;


@end

@implementation RootViewController{
    UUInputFunctionView *IFView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBar];
    [self addRefreshViews];
    
    [self loadBaseViewsAndData];
    [self fetchRoomByImei];
    
    NSArray *focusedPersons = [[NSPublic shareInstance] getTermUserArray];
    for (CHTermUser *user in focusedPersons){
        if ([user.imei isEqualToString:self.incomingImei]) {
            if (user.name.length > 0) {
                self.title = user.name;
                break;

            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullList) name:@"updateMessageList" object:nil];
}

- (void)pullList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadBaseViewsAndData];
    });
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [NSPublic shareInstance].vcIndex = 4;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSPublic shareInstance].vcIndex = 0;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)initBar
{
    self.title = self.incomingImei;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss:)];
    
    if (!self.shouldHideWatchIcon) {
        UIButton *roomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        roomBtn.frame = CGRectMake(0, 0, 28, 20);
        [roomBtn setImage:[UIImage imageNamed:@"users"] forState:UIControlStateNormal];
        [roomBtn addTarget:self action:@selector(toRooms) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:roomBtn];
    }
}

- (void)dismiss:(id)item
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    
    //load more
    int pageNum = 3;
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    [self.chatModel populateDataSourceWithImei:self.incomingImei];
    
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = keyboardEndFrame.size.height+40;
    }else{
        self.bottomConstraint.constant = 40;
    }
    
    [self.view layoutIfNeeded];
    
    //adjust UUInputFunctionView's originPoint
    CGRect newFrame = IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"strContent": message,
                          @"type": @(UUMessageTypeText)};
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
    [self dealTheFunctionData:dic];
    
    [self sendMessage:message type:1];
}



- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *imgStr = [Base64 stringByEncodingData:[self compressImage:image toMaxFileSize:40*1024]];
        NSArray *array1 = [[NSArray alloc] initWithObjects: self.incomingImei,@"3", [[NSPublic shareInstance]getsid], imgStr, [[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary1  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"sendMessage.do"] with:array1 with:@"sendMessage.do"];
        NSString *status  =  [NSString stringWithFormat:  @"%@",[dictionary1 objectForKey:@"status"]];
        NSLog(@"%@",status);
        
    });
}



- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    
//    NSString *sample = voiceSample;
//    NSData *voiceData = [Base64 decodeString:sample];
//    NSData *waveData = DecodeAMRToWAVE(voiceData);
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice)};
    [self dealTheFunctionData:dic];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSData *AudioData = EncodeWAVEToAMR(voice,1,16);
        NSString *audioStr = [AudioData base64EncodedStringWithOptions:0];
        NSArray *array1 = [[NSArray alloc] initWithObjects: self.incomingImei,@"2", [[NSPublic shareInstance]getsid], audioStr, [[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary1  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"sendMessage.do"] with:array1 with:@"sendMessage.do"];
        NSString *status  =  [NSString stringWithFormat:  @"%@",[dictionary1 objectForKey:@"status"]];
        NSLog(@"%@",status);
    
    });
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
    // headIamgeIcon is clicked
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
//    [alert show];
}

- (void)sendMessage:(NSString*)message type:(int)type
{
    
    
    NSString *url = @"chunhui/m/data@sendMessage.do";
    NSString *paramString = [NSString stringWithFormat:@"type=1&sid=%@&imei=%@&msg=%@",
                             [[NSPublic shareInstance] getsid],
                             self.incomingImei,
                             message];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              [ProgressHUD dismiss];
                                                              [self formatData:jsonData];
                                                          }];
}

- (void)formatData:(id)data
{
    NSLog(@"%@",data);
}

#pragma mark- 获取imei对应的亲友圈信息
- (void)fetchRoomByImei
{

    NSString *imei = self.incomingImei;
    NSString *user = [[NSPublic shareInstance] getUserName];
    NSArray  *keys = @[@"user",@"imei"];
    NSArray  *values = @[user,imei];

    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@getRoomInfoByImei.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                self.room = [[Room alloc] initFromDictionary:DataDictionary(jsonData)];
                NSLog(@"%@",self.room.roomId);
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
    
}

- (void)toRooms
{
    if ([self.room.imei isEqualToString:self.incomingImei] ) {
            ChatVC *chatVC              = [[ChatVC alloc] init];
            chatVC.senderId             = [[NSPublic shareInstance] getUserName];
            chatVC.senderDisplayName    = [[NSPublic shareInstance] getUserName];
            chatVC.title                = self.room.roomName;
            chatVC.roomId               = self.room.roomId;
            chatVC.room                 = self.room;
            [self.navigationController pushViewController:chatVC animated:YES];
            }
}

@end
