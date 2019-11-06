//
//  ViewController.m
//  MusicPlayer
//
//  Created by miao yu on 2019/10/12.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "ViewController.h"
#import "JYMusicPlayerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JYMusicPlayerController *controller = [JYMusicPlayerController sharedPlayerController];
    controller.view.frame = self.view.bounds;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:controller.view];
    [self addChildViewController:controller];
}


@end
