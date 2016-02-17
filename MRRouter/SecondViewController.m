//
//  SecondViewController.m
//  MRRouter
//
//  Created by 苏合 on 16/1/5.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "SecondViewController.h"
#import "MRRouter.h"

@interface SecondViewController ()

//@property (nonatomic, strong) NSString *ccc;
@property (nonatomic, strong) NSString *ddd;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    NSLog(@"%@", self.mr_parameters);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
