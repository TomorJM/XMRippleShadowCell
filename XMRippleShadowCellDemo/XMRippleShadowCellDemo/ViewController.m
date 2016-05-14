//
//  ViewController.m
//  XMRippleShadowCellDemo
//
//  Created by joker on 16/5/4.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "ViewController.h"
#import "TestCell.h"
#import "TwoController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"One";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"test";
    
    TestCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"海绵宝宝.jpeg"];
    cell.textLabel.text = @"我是海绵宝宝,派大星呢?";
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"didSelectRowAtIndexPath");
    TwoController *two = [[TwoController alloc] init];
    [self.navigationController pushViewController:two animated:YES];
}




@end
