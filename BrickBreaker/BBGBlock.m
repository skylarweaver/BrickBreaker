//
//  BBGBlock.m
//  BrickBreaker
//
//  Created by Tyler Hedrick on 11/12/13.
//  Copyright (c) 2013 Tyler Hedrick. All rights reserved.
//

#import "BBGBlock.h"
#import "BBGSpriteCategories.h"

@implementation BBGBlock

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
  if (self = [super initWithImageNamed:@"block"]) {
    self.colorBlendFactor = 0.7;
    self.color = color;
    self.size = size;
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = blockCategory;
    self.physicsBody.contactTestBitMask = ballCategory;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.dynamic = YES;
  }
  return self;
}

@end
