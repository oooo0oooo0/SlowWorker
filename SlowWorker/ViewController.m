//
//  ViewController.m
//  SlowWorker
//
//  Created by 张光发 on 15/11/28.
//  Copyright © 2015年 张光发. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ViewController

-(NSString *)fetchSomethingFromServer
{
    [NSThread sleepForTimeInterval:1];
    return @"Hi There";
}

//转大写
-(NSString *)processData:(NSString *)data
{
    [NSThread sleepForTimeInterval:2];
    return [data uppercaseString];
}

//计算长度
-(NSString *)calculateFirstResult:(NSString *)data
{
    [NSThread sleepForTimeInterval:3];
    return [NSString stringWithFormat:@"number of chars:%d",[data length]];
}

//替换
-(NSString *)calculaterSecondResult:(NSString *)data
{
    [NSThread sleepForTimeInterval:4];
    return [data stringByReplacingOccurrencesOfString:@"E" withString:@"e"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)doWork:(id)sender {
    NSDate *startTime=[NSDate date];
    self.startButton.enabled=NO;
    
    [self.spinner startAnimating];
    //获取全局可用的队列
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //后台执行
    dispatch_async(queue, ^{
        NSString *fetchedData=[self fetchSomethingFromServer];
        NSString *processData=[self processData:fetchedData];
        
//        NSString *firstResult=[self calculateFirstResult:processData];
//        NSString *secondResult=[self calculaterSecondResult:processData];
        __block NSString *firstResult;
        __block NSString *secondResult;
        dispatch_group_t group=dispatch_group_create();
        //并行执行方法一
        dispatch_group_async(group, queue, ^{
            firstResult=[self calculateFirstResult:processData];
        });
        //并行执行方法二
        dispatch_group_async(group, queue, ^{
            secondResult=[self calculaterSecondResult:processData];
        });
        //合并
        dispatch_group_notify(group, queue, ^{
            NSString *resultsSummary=[NSString stringWithFormat:@"First:[%@]\nSecond:[%@]",firstResult,secondResult];
            //使用主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDate *endTime=[NSDate date];
                self.resultsTextView.text=[NSString stringWithFormat:@"耗时约:%f\n%@",[endTime timeIntervalSinceDate:startTime],resultsSummary];
                self.startButton.enabled=YES;
                [self.spinner stopAnimating];
            });
            NSDate *endTime=[NSDate date];
            NSLog(@"Completed in %f seconds",[endTime timeIntervalSinceDate:startTime]);
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
