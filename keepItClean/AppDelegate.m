//
//  AppDelegate.m
//  keepItClean
//
//  Created by Jeff "ServerGuy" Brice on 1/31/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#import "AppDelegate.h"
#import "PanelController.h"

@implementation AppDelegate
@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    self.menubarController = [[MenubarController alloc] init];
    // Registers preferences

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _prefMon = [prefs boolForKey:@"mon"];
    _prefTues = [prefs boolForKey:@"tues"];
    _prefWed = [prefs boolForKey:@"wed"];
    _prefThu = [prefs boolForKey:@"thurs"];
    _prefFri = [prefs boolForKey:@"fri"];
    _prefSat = [prefs boolForKey:@"sat"];
    _prefSun = [prefs boolForKey:@"sun"];
    _prefPassword = [_prefs stringForKey:@"password"];
    
    // Checks if the app has a stored schedule
    _notSaved = [NSAlert alertWithMessageText:@"Password has not been saved" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
    _noPass = [NSAlert alertWithMessageText:@"You did not enter a password" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
    _prefPassword = [prefs stringForKey:@"password"];
    _prefNotFirstRun = [prefs boolForKey:@"firstRun"];
    
    // Checks if the app has a stored password
    if (!_prefNotFirstRun) {
        NSAlert *firstRunPassword = [NSAlert alertWithMessageText:@"This is you first time running keep it clean" defaultButton:@"Ok" alternateButton:@"Close" otherButton:nil informativeTextWithFormat:@"Please enter a password on the next screen"];
        long buttonChoice = [firstRunPassword runModal];
        if (buttonChoice == 1) {
            [_panelFirstPassword makeKeyAndOrderFront:self];
        }
        else {
            [NSApp terminate:nil];
        }
    }
    _firstPass = [NSAlert alertWithMessageText:@"Are you sure you want to use this password?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"In the current version of this app, passwords cannot be changed unless the application is uninstalled"];
    _notSaved = [NSAlert alertWithMessageText:@"Password has not been saved" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
    _noPass = [NSAlert alertWithMessageText:@"You did not enter a password" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
    [PanelController timer];
    [_prefs synchronize];
}

-(IBAction)savePassword:(NSButton *)sender {
    NSAlert *noPass = [NSAlert alertWithMessageText:@"You did not enter a password" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
    if ([_txtFirstSecurePass.stringValue isEqual: @""]) {
        [noPass runModal];
    }
    else {
        long firstPassCode = [_firstPass runModal];
        switch (firstPassCode) {
            case 0: {
                [_notSaved runModal];
                break;}
            case 1:{
                [self passCodeSet];
                [_panelFirstPassword close];
                break;}
            default:{
                [_notSaved runModal];
                break;}
        }
    }
}


-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

-(void)passCodeSet {
    NSString *passwordToSave = _txtFirstSecurePass.stringValue;
    _prefNotFirstRun = YES;
    [_prefs setObject:passwordToSave forKey:@"password"];
    [_prefs setBool:_prefNotFirstRun forKey:@"firstRun"];
    [_prefs synchronize];
    
}

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

@end
