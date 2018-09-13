//
//  MyThread.m
//  XZRunLoop
//
//  Created by kkxz on 2018/9/12.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "MyThread.h"

@implementation MyThread
-(void)dealloc
{
    NSLog(@"%@线程被释放了",self.name);
}
@end
