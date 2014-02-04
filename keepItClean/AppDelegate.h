//
//  AppDelegate.h
//  keepItClean
//
//  Created by Jeff "ServerGuy" Brice on 1/31/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenubarController.h"
#import "PanelController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic) NSString *prefPassword;
@property (nonatomic) BOOL prefNotFirstRun;
@property (nonatomic) IBOutlet NSPanel *panelFirstPassword;
@property (nonatomic) IBOutlet NSTextField *txtFirstSecurePass;
@property (nonatomic) NSAlert *noPass;
@property (nonatomic) NSAlert *firstPass;
@property (nonatomic) NSAlert *notSaved;
@property (nonatomic) NSUserDefaults *prefs;
@property (nonatomic) BOOL prefMon;
@property (nonatomic) BOOL prefTues;
@property (nonatomic) BOOL prefWed;
@property (nonatomic) BOOL prefThu;
@property (nonatomic) BOOL prefFri;
@property (nonatomic) BOOL prefSat;
@property (nonatomic) BOOL prefSun;

- (IBAction)togglePanel:(id)sender;


@end
