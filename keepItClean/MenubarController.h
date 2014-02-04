//
//  MenubarController.h
//  keepItClean
//
//  Created by Admin on 2/4/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#define STATUS_ITEM_VIEW_WIDTH 24.0

#pragma mark -

@class StatusItemView;

@interface MenubarController : NSObject {
@private
    StatusItemView *_statusItemView;
}

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) StatusItemView *statusItemView;

@end