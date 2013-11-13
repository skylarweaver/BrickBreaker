//
//  BBGMyScene.m
//  BrickBreaker
//
//  Created by Tyler Hedrick on 11/12/13.
//  Copyright (c) 2013 Tyler Hedrick. All rights reserved.
//

#import "BBGMyScene.h"
#import "BBGBlock.h"
#import "BBGSpriteCategories.h"

@interface BBGMyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode *ball;
@property (nonatomic) SKSpriteNode *paddle;
@property (nonatomic) BOOL isSetup;
@property (nonatomic) BOOL ballIsMoving;
@property (nonatomic) NSInteger numberOfLives;
@property (nonatomic) NSInteger score;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *livesLabel;
@end

static inline CGPoint vecAdd(CGPoint a, CGPoint b) {
  return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint vecSub(CGPoint a, CGPoint b) {
  return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint vecMult(CGPoint a, float b) {
  return CGPointMake(a.x * b, a.y * b);
}

static inline float vecLength(CGPoint a) {
  return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint vecNormalize(CGPoint a) {
  float length = vecLength(a);
  return CGPointMake(a.x / length, a.y / length);
}

#define kScoreHeight 44.0

@implementation BBGMyScene

CGPoint CGRectGetCenter(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
        /* Setup your scene here */
    self.backgroundColor = [SKColor blackColor];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    self.ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.size.width / 2.0];
    self.ball.physicsBody.categoryBitMask = ballCategory;
   // self.ball.physicsBody.collisionBitMask = paddleCateogry;
    self.ball.physicsBody.contactTestBitMask = blockCategory;
    self.ball.physicsBody.usesPreciseCollisionDetection = YES;
    self.ball.position = CGRectGetCenter(self.frame);
    self.ball.physicsBody.friction = 0.0;
    self.ball.physicsBody.restitution = 1.0;
    self.ball.physicsBody.linearDamping = 0.0;
    self.ball.physicsBody.angularDamping = 0.0;
    [self addChild:self.ball];
    
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.size];
    self.paddle.physicsBody.categoryBitMask = paddleCateogry;
    self.paddle.physicsBody.collisionBitMask = ballCategory;
    self.paddle.physicsBody.contactTestBitMask = ballCategory;
    self.paddle.physicsBody.affectedByGravity = NO;
    self.paddle.physicsBody.dynamic = NO;
    CGPoint centerPoint = CGRectGetCenter(self.frame);
    centerPoint.y = self.paddle.size.height / 2.0;
    self.paddle.position = centerPoint;
    [self addChild:self.paddle];
    
    // Left boundary
    CGRect screenRect = self.frame;
    CGSize wallSize = CGSizeMake(1, CGRectGetHeight(screenRect));
    CGSize ceilingSize = CGSizeMake(CGRectGetWidth(screenRect), 1);
    SKSpriteNode *leftBoundary = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:wallSize];
    leftBoundary.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftBoundary.size];
    leftBoundary.position = CGPointMake(0, CGRectGetMidY(screenRect));
    leftBoundary.physicsBody.dynamic = NO;
    
    SKSpriteNode *rightBoundary = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:wallSize];
    rightBoundary.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightBoundary.size];
    rightBoundary.position = CGPointMake(CGRectGetMaxX(screenRect), CGRectGetMidY(screenRect));
    rightBoundary.physicsBody.dynamic = NO;
    
    SKSpriteNode *ceilingBoundary = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:ceilingSize];
    ceilingBoundary.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ceilingBoundary.size];
    ceilingBoundary.position = CGPointMake(CGRectGetMidX(screenRect), CGRectGetMaxY(screenRect) - kScoreHeight / 2.0);
    ceilingBoundary.physicsBody.dynamic = NO;
    
    [self addChild:leftBoundary];
    [self addChild:rightBoundary];
    [self addChild:ceilingBoundary];
    
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsBody.collisionBitMask = ballCategory;
    self.physicsBody.contactTestBitMask = 0;
    self.score = 0;
    self.numberOfLives = 3;
  }
  return self;
}

- (void)setupScoreDisplay
{
  self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
  self.scoreLabel.name = @"scoreLabel";
  self.scoreLabel.fontColor = [SKColor whiteColor];
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %03u", 0];
  self.scoreLabel.fontSize = 18.0;
  self.scoreLabel.position = CGPointMake(5 + self.scoreLabel.frame.size.width / 2.0, CGRectGetMaxY(self.frame) - self.scoreLabel.frame.size.height);
  [self addChild:self.scoreLabel];
  
  self.livesLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
  self.livesLabel.name = @"livesLabel";
  self.livesLabel.fontColor = [SKColor whiteColor];
  self.livesLabel.text = [NSString stringWithFormat:@"Lives: %01u", 3];
  self.livesLabel.fontSize = 18.0;
  self.livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  self.livesLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - self.livesLabel.frame.size.width - 5, CGRectGetMaxY(self.frame) - self.livesLabel.frame.size.height);
  [self addChild:self.livesLabel];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self];
  [self movePaddleToPoint:location];
  if (!self.ballIsMoving) {
    [self.ball.physicsBody applyImpulse:CGVectorMake(0.05, -2)];
    self.ballIsMoving = YES;
  }
}

- (void)didMoveToView:(SKView *)view
{
  if (!self.isSetup) {
    [self setupSceneWithBlocks];
    [self setupScoreDisplay];
    self.isSetup = YES;
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self];
  [self movePaddleToPoint:location];
}

- (void)movePaddleToPoint:(CGPoint)point
{
  SKAction *movePaddleAction = [SKAction moveTo:CGPointMake(point.x, self.paddle.position.y) duration:0.1];
  [self.paddle runAction:movePaddleAction];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  SKPhysicsBody *firstBody, *secondBody;
  
  // BALL is bodyA
  if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
  {
    firstBody = contact.bodyB;
    secondBody = contact.bodyA;
  }
  else
  {
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
  }
  if (firstBody.categoryBitMask != ballCategory) {
    if (firstBody.categoryBitMask & paddleCateogry && secondBody.categoryBitMask & ballCategory) {
      CGVector ballVector = self.ball.physicsBody.velocity;
      CGPoint normalPoint = vecNormalize(CGPointMake(ballVector.dx, ballVector.dy));
      CGPoint scaledPoint = vecMult(normalPoint, 0.04);
      [self.ball.physicsBody applyImpulse:CGVectorMake(scaledPoint.x, scaledPoint.y)];
    }
    return;
  }
  // 2
  if ((firstBody.categoryBitMask & ballCategory) != 0 &&
      (secondBody.categoryBitMask & blockCategory) != 0)
  {
    [self ball:(SKSpriteNode *)firstBody.node didCollideWithBlock:(BBGBlock *)secondBody.node];
  }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
  
}

- (void)setupSceneWithBlocks
{
  CGFloat startingX = 0;
  CGFloat startingY = kScoreHeight;
  NSArray *colors = @[[SKColor redColor],
                      [SKColor orangeColor],
                      [SKColor yellowColor],
                      [SKColor greenColor],
                      [SKColor blueColor],
                      [SKColor purpleColor]];
  int blockHeight = 22;
  int col = 0;
  int blockWidth = self.size.width / 12;
  while (startingY < blockHeight * 6) {
    while (startingX < (self.size.width - (blockWidth - 5))) {
      BBGBlock *block = [BBGBlock spriteNodeWithColor:colors[col % colors.count] size:CGSizeMake(blockWidth, blockHeight)];
      block.position = CGPointMake(startingX + blockWidth / 2.0, self.size.height - startingY + blockHeight / 2.0);
      startingX += blockWidth;
      block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
      block.physicsBody.categoryBitMask = blockCategory;
      block.physicsBody.collisionBitMask = 0;
      block.physicsBody.contactTestBitMask = ballCategory;
      block.physicsBody.affectedByGravity = NO;
      block.physicsBody.dynamic = YES;
      [self addChild:block];
      col++;
    }
    startingY += blockHeight;
    startingX = 0;
    col = 0;
  }
}

- (void)ball:(SKSpriteNode *)ball didCollideWithBlock:(BBGBlock *)block
{
  [block removeFromParent];
  self.score++;
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %03u", self.score];
}

- (void)update:(CFTimeInterval)currentTime
{
  if (self.ball.position.y < 0) {
    self.ball.physicsBody.velocity = CGVectorMake(0, 0);
    self.ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.ballIsMoving = NO;
    CGPoint centerPoint = CGRectGetCenter(self.frame);
    centerPoint.y = self.paddle.size.height / 2.0;
    self.paddle.position = centerPoint;
    self.numberOfLives--;
    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %01u", self.numberOfLives];
  }
}

@end
