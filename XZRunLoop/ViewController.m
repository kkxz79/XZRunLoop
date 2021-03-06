//
//  ViewController.m
//  XZRunLoop
//
//  Created by kkxz on 2018/9/12.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "ViewController.h"
#import "MyThread.h"

@interface ViewController ()
@property(nonatomic,assign)NSInteger experimentType;
@property(nonatomic,strong)MyThread * subThread;
@property(nonatomic,weak)MyThread * subTwoThread;
@property(nonatomic,weak)MyThread * subThreeThread;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.experimentType = 9;
    /*
     iOS 系统中，提供了两种RunLoop：NSRunLoop 和 CFRunLoopRef。
     CFRunLoopRef 是在 CoreFoundation 框架内的，它提供了纯 C 函数的 API，所有这些 API 都是线程安全的。
     NSRunLoop 是基于 CFRunLoopRef 的封装，提供了面向对象的 API，但是这些 API 不是线程安全的。
     CFRunLoopRef 的代码是开源的，所以有些源码部分以CFRunLoop来讲。
     */
    //使用场景：保持线程的存活，而不是线性的执行完任务就退出了。
    
    /*在遇到一些耗时操作时，为了避免主线程阻塞导致界面卡顿，影响用户体验，往往我们会把这些耗时操作放在一个临时开辟的子线程中。操作完成了，子线程线性的执行了代码也就退出了，就像下面一样。*/
    if(1==self.experimentType){
        NSLog(@"%@------开辟子线程",[NSThread currentThread]);
        MyThread *subThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        subThread.name = @"subThread";
        [subThread start];
        //就像一开始所说的一样，子线程执行完操作就自动退出了。
    }
    
    //实验用self来持有子线程
    /*
     如果子线程的操作是偶尔或者干脆只需要执行一次的话，像上面那样就没什么问题。但是如果这个操作需要频繁执行，那么按照上面那样的逻辑，我们就需要频繁创建子线程，这是很消耗资源的。就像平时我们在设计类的时候会把需要频繁使用的对象保持起来，而不是频繁创建一样。我们试试把线程“保持”起来，让它在需要的时候执行任务，不需要的时候就啥都不干。
     */
    if(2==self.experimentType){
        NSLog(@"%@------开辟子线程",[NSThread currentThread]);
        self.subThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        self.subThread.name = @"subThread";
        [self.subThread start];
        //[self.subThread start];
        /*018-09-12 17:33:30.802466+0800 XZRunLoop[2764:723558] <NSThread: 0x15fe09690>{number = 1, name = main}------开辟子线程
         2018-09-12 17:33:30.803503+0800 XZRunLoop[2764:723670] <MyThread: 0x15fd6e410>{number = 5, name = subThread}----执行子线程任务
         2018-09-12 17:33:30.807871+0800 XZRunLoop[2764:723558] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[MyThread start]: attempt to start the thread again'*/
        /*
         因为执行完任务后，虽然Thread没有被释放，还处于内存中，但是它处于死亡状态（当线程的任务结束后就会进入这种状态）。打个比方，人死不能复生，线程死了也不能复生（重新开启），苹果不允许在线程死亡后再次开启。所以会报错attempt to start the thread again(尝试重新开启线程)
         */
    }
    
    //让线程不结束任务导致进入死亡状态
    if(3==self.experimentType){
        NSLog(@"%@----开辟子线程",[NSThread currentThread]);
        
        self.subThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        self.subThread.name = @"subThread";
        [self.subThread start];
    }
    
    if(4==self.experimentType){
        NSLog(@"%@------开辟子线程",[NSThread currentThread]);
        MyThread *subThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        subThread.name = @"subThread";
        [subThread start];
        
        /*
         2018-09-12 17:47:31.974273+0800 XZRunLoop[2771:729160] <NSThread: 0x149d09130>{number = 1, name = main}------开辟子线程
         2018-09-12 17:47:31.975448+0800 XZRunLoop[2771:729283] <MyThread: 0x149d80e20>{number = 4, name = subThread}----开始执行子线程任务
         */
        //这里没有对线程进行引用，也没有让线程内部的任务进行显式的循环。为什么子线程的里面的任务没有执行到输出任务结束这一步，为什么子线程没有销毁？就是因为[runLoop run];这一行的存在。
        //前面讲了，RunLoop本质就是个Event Loop的do while循环，所以运行到这一行以后子线程就一直在进行接受消息->等待->处理的循环。
        
    }
    
    if(5==self.experimentType){
        NSLog(@"%@------开辟子线程",[NSThread currentThread]);
        MyThread *subThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        subThread.name = @"subThread";
        [subThread start];
    }
    
    if(6==self.experimentType){
        NSLog(@"%@----开辟子线程",[NSThread currentThread]);
        
        MyThread *tmpThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        //subThread用weak声明，用weak声明，用weak声明
        self.subTwoThread = tmpThread;
        self.subTwoThread.name = @"subTwoThread";
        [self.subTwoThread start];
    }
    
    if(7==self.experimentType){
        NSTimer * timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(wantTodo) userInfo:nil repeats:YES];
        //timerWith开头的方法创建的Timer如果不加下面一句无法运行。
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        /*
         其实NSTimer定时器的触发正是基于RunLoop运行的，所以使用NSTimer之前必须注册到RunLoop。
         同时我们也应该知道Timer并不是严格的按照设定的时间点来触发的，
         RunLoop为了节省资源并不会在非常准确的时间点调用定时器，
         如果一个任务执行时间较长，那么当错过一个时间点后只能等到下一个时间点执行，并不会延后执行。
         */
    }
    
    if(8==self.experimentType){
        NSLog(@"%@----开辟子线程",[NSThread currentThread]);
        MyThread *tmpThread = [[MyThread alloc] initWithTarget:self selector:@selector(subThreadTodo) object:nil];
        //subThread用weak声明，用weak声明，用weak声明
        self.subThreeThread = tmpThread;
        self.subThreeThread.name = @"subThreeThread";
        [self.subThreeThread start];
    }
    
    //RunLoop状态监听
    //CFRunLoopAddObserver(CFRunLoopRef rl, CFRunLoopObserverRef observer, CFStringRef mode)
    /*
         第一个参数：RunLoop
         第二个参数：observer
         第三个参数：mode
     */
    if(9==self.experimentType){
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            NSLog(@"-----------%zd",activity);
        });
        //添加监听者
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
        CFRelease(observer);//释放
    }
    
}

-(void)subThreadTodo
{
    if(1==self.experimentType||2==self.experimentType){
        NSLog(@"%@----执行子线程任务",[NSThread currentThread]);
    }
    //log
    /*
     2018-09-12 17:22:14.818527+0800 XZRunLoop[2752:718375] <NSThread: 0x159d08c50>{number = 1, name = main}------开辟子线程
     2018-09-12 17:22:14.820117+0800 XZRunLoop[2752:718479] <MyThread: 0x159d9cba0>{number = 4, name = subThread}----执行子线程任务
     2018-09-12 17:22:14.820445+0800 XZRunLoop[2752:718479] subThread线程被释放了
     */
    
    if(3==self.experimentType){
        do {
            NSLog(@"%@----执行子线程任务",[NSThread currentThread]);
        } while (1);
        /*
         一通操作过后代码变成这样。但是写完仔细一想，确实子线程不会进入死亡状态了，但是子线程却在不分时间地点场合的疯狂执行任务。这根我们一开始想象的，需要的时候执行任务，不需要的时候就啥都不干差远了。看起来似乎又是一次失败的尝试，但是别灰心，我们已经越来越接近答案了。
         */
    }
    
    //Event Loop 模式
    /*
     performSelectorOnMainThread:withObject:waitUntilDone:
     performSelectorOnMainThread:withObject:waitUntilDone:modes:
     
     performSelector:onThread:withObject:waitUntilDone:
     performSelector:onThread:withObject:waitUntilDone:modes:
     
     performSelector:withObject:afterDelay:
     performSelector:withObject:afterDelay:inModes:
     */
    //RunLoop
    if(4==self.experimentType){
        NSLog(@"%@----开始执行子线程任务",[NSThread currentThread]);
        //获取当前子线程的runloop
        NSRunLoop * runLoop  = [NSRunLoop currentRunLoop];
        //下面这一行必须加，否则RunLoop无法正常启用。我们暂时先不管这一行的意思，稍后再讲。
        [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        NSLog(@"RunLoop:%@",runLoop);
        //让RunLoop跑起来
        [runLoop run];
        NSLog(@"%@----执行子线程任务结束",[NSThread currentThread]);
    }
    
    if(5==self.experimentType){
        NSLog(@"%@----开始执行子线程任务",[NSThread currentThread]);
        //获取当前子线程的RunLoop
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        //给RunLoop添加一个事件源，注意添加的Mode
        //关于这里的[NSMachPort port]我的理解是，给RunLoop添加了一个占位事件源，告诉RunLoop有事可做，让RunLoop运行起来。
        //但是暂时这个事件源不会有具体的动作，而是要等RunLoop跑起来过后等有消息传递了才会有具体动作。
        [runLoop addPort:[NSMachPort port] forMode:UITrackingRunLoopMode];
        [runLoop run];
        NSLog(@"%@----执行子线程任务结束",[NSThread currentThread]);
        /*2018-09-12 18:19:39.068988+0800 XZRunLoop[2783:740732] <NSThread: 0x10be017e0>{number = 1, name = main}------开辟子线程
         2018-09-12 18:19:39.070612+0800 XZRunLoop[2783:740856] <MyThread: 0x10bd9c870>{number = 5, name = subThread}----开始执行子线程任务
         2018-09-12 18:19:39.074861+0800 XZRunLoop[2783:740856] <MyThread: 0x10bd9c870>{number = 5, name = subThread}----执行子线程任务结束
         2018-09-12 18:19:39.076995+0800 XZRunLoop[2783:740856] subThread线程被释放了*/
        //RunLoop正常运行的条件是：1.有Mode。2.Mode有事件源。3.运行在有事件源的Mode下。
    }
    
    if(6==self.experimentType){
        NSLog(@"%@----开始执行子线程任务",[NSThread currentThread]);
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"%@----执行子线程任务结束",[NSThread currentThread]);
    }
    
    if(8==self.experimentType){
        NSLog(@"%@----开始执行子线程任务",[NSThread currentThread]);
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"%@----执行子线程任务结束",[NSThread currentThread]);
    }
    
    
}

//我们希望放在子线程中执行的任务
- (void)wantTodo
{
    if(6==self.experimentType){
        //断点2
        NSLog(@"当前线程:%@执行任务处理数据", [NSThread currentThread]);
        //log
        /*
         2018-09-13 11:10:42.430775+0800 XZRunLoop[4638:1064499] <NSThread: 0x117e05960>{number = 1, name = main}----开辟子线程
         2018-09-13 11:10:42.433416+0800 XZRunLoop[4638:1064578] <MyThread: 0x117ea7a20>{number = 4, name = subTwoThread}----开始执行子线程任务
         2018-09-13 11:10:47.442705+0800 XZRunLoop[4638:1064578] 当前线程:<MyThread: 0x117ea7a20>{number = 4, name = subTwoThread}执行任务处理数据
         2018-09-13 11:10:47.443017+0800 XZRunLoop[4638:1064578] <MyThread: 0x117ea7a20>{number = 4, name = subTwoThread}----执行子线程任务结束
         2018-09-13 11:10:47.443954+0800 XZRunLoop[4638:1064578] subTwoThread线程被释放了
         */
    }
    
    if(7==self.experimentType){
        NSLog(@"timer启动");
    }
    
    if(8==self.experimentType){
        //断点1
        //1.这个方法是作用于当前线程，现在在子线程中调用这个函数，所以会作用于子线程的RunLoop
        //self这个位置只要是继承自NSObject的对象都能填，但是他要有后面SEL的方法，否则会崩溃。（直白的说这个方法就是在当前线程中延迟调用某个对象的某个方法。）
        [self performSelector:@selector(afterDelayTodo) withObject:nil afterDelay:0];
        //当调用 performSelecter:afterDelay: 后，其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中，所以这个方法是属于Timer源的。
    }
}

- (void)afterDelayTodo{
    //断点2
    NSLog(@"当前线程:%@执行任务处理数据", [NSThread currentThread]);
}

//屏幕点击事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //在子线程中去响应wantTodo方法
    if(6==self.experimentType){
        //断点1
        [self performSelector:@selector(wantTodo) onThread:self.subTwoThread withObject:nil waitUntilDone:NO];
    }
    if(8==self.experimentType){
        [self performSelector:@selector(wantTodo) onThread:self.subThreeThread withObject:nil waitUntilDone:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy init
@synthesize experimentType = _experimentType;
@synthesize subThread = _subThread;
@synthesize subTwoThread = _subTwoThread;
@synthesize subThreeThread = _subThreeThread;

@end
