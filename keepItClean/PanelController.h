//
//  PanelController.h
//  keepItClean
//
//  Created by Admin on 2/4/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#import "BackgroundView.h"
#import "StatusItemView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
    IBOutlet NSButton *btnEnterPassword;
    IBOutlet NSPanel *panelPassword;
    IBOutlet NSTextField *txtSecurePass;
    IBOutlet NSMenuItem *changePassword;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic) IBOutlet NSButton *btnSave;
@property (nonatomic) IBOutlet NSButton *btnWipeManual;
@property (nonatomic) IBOutlet NSButton *sunday;
@property (nonatomic) IBOutlet NSButton *monday;
@property (nonatomic) IBOutlet NSButton *tuesday;
@property (nonatomic) IBOutlet NSButton *wednesday;
@property (nonatomic) IBOutlet NSButton *thursday;
@property (nonatomic) IBOutlet NSButton *friday;
@property (nonatomic) IBOutlet NSButton * saturday;
@property (nonatomic) IBOutlet NSButton *btnLock;
@property (nonatomic) IBOutlet NSButton*btnUnlock;
@property (nonatomic) IBOutlet NSDatePicker *datePickerTime;

@property (strong) NSMutableArray *daysToWipe;
@property (strong) NSDate *timeToWipe;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSString *prefPassword;
@property (nonatomic) NSAlert *areYouSure;
@property (nonatomic) NSAlert *notSaved;
@property (nonatomic) NSAlert *noPass;
@property (nonatomic) int tries;
@property (nonatomic) BOOL prefMon;
@property (nonatomic) BOOL prefTues;
@property (nonatomic) BOOL prefWed;
@property (nonatomic) BOOL prefThu;
@property (nonatomic) BOOL prefFri;
@property (nonatomic) BOOL prefSat;
@property (nonatomic) BOOL prefSun;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
+(void)timer;

@end