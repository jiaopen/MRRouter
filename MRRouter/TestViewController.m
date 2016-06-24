//
//  TestViewController.m
//  MRRouter
//
//  Created by 苏合 on 16/1/5.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "TestViewController.h"
#import "MRRouter.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%@", self.mr_parameters);
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender {
//    id obj = [MRRouter existedInstanceWithURL:@"test://test"];
    if (self.mr_respondBlock)
    {
        self.mr_respondBlock(@"test");
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
