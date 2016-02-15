//
//  ViewController.m
//  MRRouter
//
//  Created by 苏合 on 15/12/31.
//  Copyright © 2015年 juangua. All rights reserved.
//

#import "ViewController.h"
#import "MRRouter.h"
#import "FreeMarketViewController.h"

#define TEST_URL @"mgj://freemarket/clothing/trousers?aa=11&bb=22"
#define TEST_URL2 @"mgj://test?aa=11&bb=22"
#define TEST_URL3 @"mgj://second"
#define TEST_URL4 @"mgj://hello"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MRRouter sharedInstance].mapFileName = @"route_map.plist";
    [MRRouter sharedInstance].defaultExecutingBlock = ^(id object, NSDictionary *parameters) {
        [self.navigationController pushViewController:object animated:YES];
    };
    [MRRouter sharedInstance].postfix = @"ViewController";
    
    [MRRouter registerURL:TEST_URL executingBlock:^(NSString *sourceURL, NSDictionary *parameters) {
        [self.navigationController pushViewController:[[FreeMarketViewController alloc] init] animated:YES];
    }];
    [MRRouter map:TEST_URL4 toClassName:@"HelloViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            [MRRouter openURL:@"test://test?aa=11&bb=22"];
        }
            break;
        case 1:
        {
            [MRRouter openURL:TEST_URL3 parameters:@{@"ccc":@"333",@"ddd":@"444"}];
        }
            break;
        case 2:
        {
            [MRRouter openURL:TEST_URL];
        }
            break;
        case 3:
        {
            [MRRouter openURL:TEST_URL4];
        }
            break;
        default:
            break;
    }
}
@end
