//
//  BackgroundView.h
//  keepItClean
//
//  Created by Admin on 2/4/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#define ARROW_WIDTH 1
#define ARROW_HEIGHT 1

@interface BackgroundView : NSView
{
    NSInteger _arrowX;
}

@property (nonatomic, assign) NSInteger arrowX;

@end