//
//  AppDelegate.m
//  keepItClean
//
//  Created by Jeff "ServerGuy" Brice on 1/31/14.
//  Copyright (c) 2014 Cat Cannon Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    // Registers preferences
    _tries = 3;
    _prefs = [NSUserDefaults standardUserDefaults];
    _prefMon = [_prefs boolForKey:@"mon"];
    _prefTues = [_prefs boolForKey:@"tues"];
    _prefWed = [_prefs boolForKey:@"wed"];
    _prefThu = [_prefs boolForKey:@"thurs"];
    _prefFri = [_prefs boolForKey:@"fri"];
    _prefSat = [_prefs boolForKey:@"sat"];
    _prefSun = [_prefs boolForKey:@"sun"];
    _prefPassword = [_prefs stringForKey:@"password"];
    _prefNotFirstRun = [_prefs boolForKey:@"firstRun"];
    
    // Checks if the app has a stored password
    if (!_prefNotFirstRun) {
        NSAlert *firstRunPassword = [NSAlert alertWithMessageText:@"This is you first time running keep it clean" defaultButton:@"Ok" alternateButton:@"Close" otherButton:nil informativeTextWithFormat:@"Please enter a password on the next screen"];
        long buttonChoice = [firstRunPassword runModal];
            if (buttonChoice == 1) {
                [panelFirstPassword makeKeyAndOrderFront:self];
                [self updatePrefs];
            }
            else {
                [NSApp terminate:nil];
            }
        }
    else {
        [panelPassword makeKeyAndOrderFront:self];
        [self updatePrefs];
    }
    
    // Checks if the app has a stored schedule
    _firstPass = [NSAlert alertWithMessageText:@"Are you sure you want to use this password?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"In the current version of this app, passwords cannot be changed unless the application is uninstalled"];
    _notSaved = [NSAlert alertWithMessageText:@"Password has not been saved" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
    _noPass = [NSAlert alertWithMessageText:@"You did not enter a password" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];

    
    // Starts the update loop
    _calendar = [NSCalendar autoupdatingCurrentCalendar];
    [self timer];
}

-(IBAction)messageToWipe:(NSButton *)sender {
    // Asks the user to confirm a wipe
    _areYouSure = [NSAlert alertWithMessageText:@"After a wipe is performed, deleted files will not be recoverable." defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@" Are you sure you want to schedule a desktop wipe?"];
    long buttonChoice = [_areYouSure runModal];
    
    // Sends a message to the performWipe method
    if (buttonChoice == NSAlertDefaultReturn) {
        [self performWipe];
    }
    // Does not send a message and alerts the user that a wipe will not be performed
    else {
        NSAlert *notPerformed;
        notPerformed = [NSAlert alertWithMessageText:@"Wipe not performed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
        [notPerformed runModal];
    }
}

-(IBAction)saveSchedule:(NSButton *)sender {
    // Asks the user to confirm their schedule
    _areYouSure = [NSAlert alertWithMessageText:@"After a wipe is performed, deleted files will not be recoverable." defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@" Are you sure you want to schedule a desktop wipe?"];
    long buttonChoice = [_areYouSure runModal];
    
    // Saves the date choices in preferences
    if (buttonChoice == 1) {
        [_daysToWipe removeAllObjects];
        if (monday.state == NSOnState) {
            _prefMon = YES;
        }    else { _prefMon = NO;
        }
        if (tuesday.state == NSOnState) {
            _prefTues = YES;
        }    else {_prefTues = NO;
        }
        if (wednesday.state == NSOnState) {
            _prefWed = YES;
        }    else {_prefWed = NO;
        }
        if (thursday.state == NSOnState) {
            _prefThu = YES;    }    else { _prefThu = NO;
            }
        if (friday.state == NSOnState) {
            _prefFri = YES;
        }    else {_prefFri = NO;
        }
        if (saturday.state == NSOnState) {
            _prefSat = YES;
        }
        else {_prefSat = NO;
        }
        if (sunday.state == NSOnState) {
            _prefSun = YES;
        }
        else {
            _prefSun = NO;
        }
        _timeToWipe = datePickerTime.dateValue;
        [_prefs setObject:_timeToWipe forKey:@"Time to Wipe"];
        [_prefs setBool:_prefMon forKey:@"mon"];
        [_prefs setBool:_prefTues forKey:@"tues"];
        [_prefs setBool:_prefWed forKey:@"wed"];
        [_prefs setBool:_prefThu forKey:@"thurs"];
        [_prefs setBool:_prefFri forKey:@"fri"];
        [_prefs setBool:_prefSat forKey:@"sat"];
        [_prefs setBool:_prefSun forKey:@"sun"];
        [_prefs synchronize];
    }
    // Sets the buttons off if user cancels the schedule
    else if (buttonChoice == 2){
        monday.state = NSOffState;
        tuesday.state = NSOffState;
        wednesday.state = NSOffState;
        thursday.state = NSOffState;
        friday.state = NSOffState;
        saturday.state = NSOffState;
        sunday.state = NSOffState;
        datePickerTime.dateValue = nil;
    }
}

-(IBAction)savePassword:(NSButton *)sender {
    if ([txtFirstSecurePass.stringValue isEqual: @""]) {
        [_noPass runModal];
    }
    else {
        long firstPassCode = [_firstPass runModal];
        switch (firstPassCode) {
            case 0: {
                [_notSaved runModal];
                break;}
            case 1:{
                [self passCodeSet];
                break;}
            default:{
                [_notSaved runModal];
                break;}
        }
    }
}

-(IBAction)passwordCheck:(NSButton *)sender {
    NSString *passwordToCheck = [_prefs stringForKey:@"password"];
    if ([txtSecurePass.stringValue isEqualToString:passwordToCheck]) {
        [self setEnabled];
        [panelPassword close];
    }
    else {
        if (_tries > 0) {
        NSAlert *wrongPass = [NSAlert alertWithMessageText:@"You have entered the wrong password" defaultButton:@"Okay" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"You have %d tries remaining", _tries];
        [wrongPass runModal];
        _tries--;
        }
        else {
            NSAlert *appQuit = [NSAlert alertWithMessageText:@"You have tried too many times" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Keep it Clean will now quit"];
            long appQuitCode = [appQuit runModal];
            if (appQuitCode == NSAlertFirstButtonReturn) {
                [NSApp terminate:nil];
            }
            else {
                [NSApp terminate:nil];
            }
        }
    }
}

-(IBAction)lockApp:(NSButton *)sender {
    [btnWipeManual setEnabled:NO];
    [btnSave setEnabled:NO];
    [monday setEnabled:NO];
    [tuesday setEnabled:NO];
    [wednesday setEnabled:NO];
    [thursday setEnabled:NO];
    [friday setEnabled:NO];
    [saturday setEnabled:NO];
    [sunday setEnabled:NO];
    [datePickerTime setEnabled:NO];
    [btnLock setEnabled:NO];
    [panelPassword makeKeyAndOrderFront:self];
    txtSecurePass.stringValue = @"";
    txtFirstSecurePass.stringValue = @"";
}

-(void)performWipe {
    // Removes all files from the Desktop. Does not Trash them, files are not recoverable.
    NSFileManager *desktopWiper = [NSFileManager new];
    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString * desktopPath = [paths objectAtIndex:0];
    [desktopWiper contentsOfDirectoryAtPath:desktopPath error:nil];
    [desktopWiper removeItemAtPath:desktopPath error:nil];
    NSAlert *performed = [NSAlert alertWithMessageText:@"Wipe succesful" defaultButton:@"Awesome" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
    [performed runModal];
}

-(void)timer {
    // Timer that controls the update loop
    NSTimer *timer = [NSTimer new];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(update:)
                                           userInfo:nil
                                            repeats:YES];
}

-(void)update:(NSTimer *)timer {
    // Gets the current date and saves the weekday
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    // Gets the current date and saves it as Hours:Minutes
    NSDateComponents *savedTime;
    savedTime = [_calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:currentDate];
    [savedTime setHour:[savedTime hour]];
    [savedTime setMinute:[savedTime minute]];
    
    // Gets the scheduled wipe time and saves it as Hours:Minutes
    NSDateComponents *timeComponents;
    timeComponents = [_calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:_timeToWipe];
    [timeComponents setHour:[timeComponents hour]];
    [timeComponents setMinute:[timeComponents minute]];
    
    // Checks that the current time and scheduled time match. If they do, checks that the current weekday is on the schedule and performs a wipe.
    if (timeComponents.hour == savedTime.hour && timeComponents.minute == savedTime.minute) {
        if (comps.weekday == 1  && _prefSun) {
            [self performWipe];
        }
        else if (comps.weekday == 2 && _prefMon) {
            [self performWipe];
        }
        else if (comps.weekday == 3 && _prefTues) {
            [self performWipe];
        }
        else if (comps.weekday == 4 && _prefWed) {
            [self performWipe];
        }
        else if (comps.weekday == 5 && _prefThu) {
            [self performWipe];
        }
        else if (comps.weekday == 6 && _prefFri) {
            [self performWipe];
        }
        else if (comps.weekday == 7 && _prefSat) {
            [self performWipe];
        }
    }
}

-(void)setEnabled {
    [btnWipeManual setEnabled:YES];
    [btnSave setEnabled:YES];
    [monday setEnabled:YES];
    [tuesday setEnabled:YES];
    [wednesday setEnabled:YES];
    [thursday setEnabled:YES];
    [friday setEnabled:YES];
    [saturday setEnabled:YES];
    [sunday setEnabled:YES];
    [datePickerTime setEnabled:YES];
    [btnLock setEnabled:YES];
    txtSecurePass.stringValue = @"";
    txtFirstSecurePass.stringValue = @"";
}

-(void)updatePrefs {
    NSDate *prefTime = [_prefs objectForKey:@"Time to Wipe"];
    datePickerTime.dateValue = prefTime;
    if (_prefMon) {
        monday.state = NSOnState;
    }
    else {
        monday.state = NSOffState;
    }
    if (_prefTues) {
        tuesday.state = NSOnState;
    }
    else {
        monday.state = NSOffState;
    }
    if (_prefWed) {
        wednesday.state = NSOnState;
    }
    else {
        wednesday.state = NSOffState;
    }
    if (_prefThu) {
        thursday.state = NSOnState;
    }
    else {
        thursday.state = NSOffState;
    }
    if (_prefFri) {
        friday.state = NSOnState;
    }
    else {
        friday.state = NSOffState;
    }
    if (_prefSat) {
        saturday.state = NSOnState;
    }
    else {
        saturday.state = NSOffState;
    }
    if (_prefSun) {
        sunday.state = NSOnState;
    }
    else {
        sunday.state = NSOffState;
    }
    [_prefs synchronize];
}

-(void)passCodeSet {
    _prefPassword = txtFirstSecurePass.stringValue;
    _prefNotFirstRun = YES;
    [_prefs setObject:_prefPassword forKey:@"password"];
    [_prefs setBool:_prefNotFirstRun forKey:@"firstRun"];
    [_prefs synchronize];
    [self setEnabled];
    [panelFirstPassword close];
}
@end
