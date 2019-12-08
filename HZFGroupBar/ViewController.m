//
//  ViewController.m
//  HZFGroupBar
//
//  Created by Eric Huang on 2019/12/8.
//  Copyright © 2019 hzf. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.i
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)onClickGroupBarChart:(id)sender {
    HomeViewController *vc = [[HomeViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
