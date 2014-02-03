//
//  AppDelegate.h
//  keepItClean
//
//  Created by Jeff "ServerGuy" Brice on 1/31/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSButton *btnSave;
    IBOutlet NSButton *btnWipeManual;
    IBOutlet NSButton *sunday;
    IBOutlet NSButton *monday;
    IBOutlet NSButton *tuesday;
    IBOutlet NSButton *wednesday;
    IBOutlet NSButton *thursday;
    IBOutlet NSButton *friday;
    IBOutlet NSButton * saturday;
    IBOutlet NSDatePicker *datePickerTime;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) NSUserDefaults *prefs;
@property (strong) NSMutableArray *daysToWipe;
@property (strong) NSDate *timeToWipe;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) BOOL prefMon;
@property (nonatomic) BOOL prefTues;
@property (nonatomic) BOOL prefWed;
@property (nonatomic) BOOL prefThu;
@property (nonatomic) BOOL prefFri;
@property (nonatomic) BOOL prefSat;
@property (nonatomic) BOOL prefSun;
@property (nonatomic) NSAlert *areYouSure;


@end
