//
//  BBGViewController.m
//  BrickBreaker
//
//  Created by Tyler Hedrick on 11/12/13.
//  Copyright (c) 2013 Tyler Hedrick. All rights reserved.
//

#import "BBGViewController.h"
#import "BBGMyScene.h"
#import "BBGSpriteCategories.h"

@implementation BBGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  SKView * skView = (SKView *)self.view;
  if (!skView.scene) {
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    SKScene *scene = [BBGMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
  }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
