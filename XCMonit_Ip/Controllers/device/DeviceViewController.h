//
//  DeviceViewController.h
//  XCMonit_Ip
//
//  Created by xia zhonglin  on 14-5-20.
//  Copyright (c) 2014年 xia zhonglin . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
@interface DeviceViewController : CustomViewController <UITableViewDataSource,UITableViewDelegate>


-(void)initData:(NSInteger)nIndex;
-(void)loadMoreData;
@end
