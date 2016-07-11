//
//  NoteSettingTVC.m
//  qingchu
//
//  Created by 张宝 on 15/12/11.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "NoteSettingTVC.h"
@interface NoteSettingTVC()<UIAlertViewDelegate>


@end

@implementation NoteSettingTVC

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定清除所有消息吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DailyAkx"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AlertNoteKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        void(^temp)() = self.callback;
        if (temp) {
            temp();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
