//
//  ViewController.m
//  MXLinkLabel-Demo
//
//  Created by Meniny on 16/7/8.
//  Copyright © 2016年 Meniny. All rights reserved.
//

#import "ViewController.h"
#import "MXLinkLabel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MXLinkLabel *linkLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[self linkLabel] setMarkupText:@"<h1>MXLinkLabel</h1>This is a <a href=\"http://www.meniny.cn/\">sample link</a>."];
    [[self linkLabel] setLinkTapHandler:^(NSURL * _Nullable url) {
        if (url != nil) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
