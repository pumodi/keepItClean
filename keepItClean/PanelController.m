#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "AppDelegate.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 250
#define PANEL_WIDTH 360
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    [self updatePrefs];
    if (self != nil)
    {
        _delegate = delegate;
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [self updatePrefs];

}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self updatePrefs];

    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
    [self updatePrefs];

}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}


//////////////////////////////////////////////////


-(IBAction)messageToWipe:(NSButton *)sender {
    [self updatePrefs];
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
    [self updatePrefs];
    // Asks the user to confirm their schedule
    _areYouSure = [NSAlert alertWithMessageText:@"After a wipe is performed, deleted files will not be recoverable." defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@" Are you sure you want to schedule a desktop wipe?"];
    long buttonChoice = [_areYouSure runModal];
    
    // Saves the date choices in preferences
    if (buttonChoice == 1) {
        [_daysToWipe removeAllObjects];
        if (_monday.state == NSOnState) {
            _prefMon = YES;
        }    else { _prefMon = NO;
        }
        if (_tuesday.state == NSOnState) {
            _prefTues = YES;
        }    else {_prefTues = NO;
        }
        if (_wednesday.state == NSOnState) {
            _prefWed = YES;
        }    else {_prefWed = NO;
        }
        if (_thursday.state == NSOnState) {
            _prefThu = YES;    }    else { _prefThu = NO;
            }
        if (_friday.state == NSOnState) {
            _prefFri = YES;
        }    else {_prefFri = NO;
        }
        if (_saturday.state == NSOnState) {
            _prefSat = YES;
        }
        else {_prefSat = NO;
        }
        if (_sunday.state == NSOnState) {
            _prefSun = YES;
        }
        else {
            _prefSun = NO;
        }
        _timeToWipe = _datePickerTime.dateValue;
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
        _monday.state = NSOffState;
        _tuesday.state = NSOffState;
        _wednesday.state = NSOffState;
        _thursday.state = NSOffState;
        _friday.state = NSOffState;
        _saturday.state = NSOffState;
        _sunday.state = NSOffState;
        _datePickerTime.dateValue = nil;
    }
}

-(IBAction)lockApp:(NSButton *)sender {
    [self updatePrefs];
    [_btnWipeManual setEnabled:NO];
    [_btnSave setEnabled:NO];
    [_monday setEnabled:NO];
    [_tuesday setEnabled:NO];
    [_wednesday setEnabled:NO];
    [_thursday setEnabled:NO];
    [_friday setEnabled:NO];
    [_saturday setEnabled:NO];
    [_sunday setEnabled:NO];
    [_datePickerTime setEnabled:NO];
    [_btnLock setEnabled:NO];
    [_btnUnlock setEnabled:YES];
    [panelPassword makeKeyAndOrderFront:self];
    txtSecurePass.stringValue = @"";
}

-(IBAction)unlockApp:(NSButton *)sender {
    [self updatePrefs];
    [panelPassword makeKeyAndOrderFront:self];
}

-(IBAction)passwordCheck:(NSButton *)sender {
    [self updatePrefs];
    _prefPassword = [_prefs stringForKey:@"password"];
    if ([txtSecurePass.stringValue isEqualToString:_prefPassword]) {
        [self setButtonsEnabled];
        [panelPassword close];
    }
    else {
     //   if (_tries > 0) {
     //       NSAlert *wrongPass = [NSAlert alertWithMessageText:@"You have entered the wrong password" defaultButton:@"Okay" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"You have %d tries remaining", _tries];
            NSAlert *wrongPass = [NSAlert alertWithMessageText:@"You have entered the wrong password" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try again"];
            [wrongPass runModal];
         //   _tries--;
        }
       /* else {
            NSAlert *appQuit = [NSAlert alertWithMessageText:@"You have tried too many times" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Keep it Clean will now quit"];
            long appQuitCode = [appQuit runModal];
            if (appQuitCode == NSAlertFirstButtonReturn) {
                [NSApp terminate:nil];
            }
            else {
                [NSApp terminate:nil];
            }
        }
    }*/
}

-(void)performWipe {
    [self updatePrefs];
    // Removes all files from the Desktop. Does not Trash them, files are not recoverable.
    NSFileManager *desktopWiper = [NSFileManager new];
    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString * desktopPath = [paths objectAtIndex:0];
    [desktopWiper contentsOfDirectoryAtPath:desktopPath error:nil];
    [desktopWiper removeItemAtPath:desktopPath error:nil];
    NSAlert *performed = [NSAlert alertWithMessageText:@"Wipe succesful" defaultButton:@"Awesome" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
    [performed runModal];
}

+(void)timer {
    // Timer that controls the update loop
    NSTimer *timer = [NSTimer new];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(update:)
                                           userInfo:nil
                                            repeats:YES];
}

-(void)update:(NSTimer *)timer {
    [self updatePrefs];
    _calendar = [NSCalendar autoupdatingCurrentCalendar];

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

-(void)setButtonsEnabled {
    [self updatePrefs];
    [_btnWipeManual setEnabled:YES];
    [_btnSave setEnabled:YES];
    [_monday setEnabled:YES];
    [_tuesday setEnabled:YES];
    [_wednesday setEnabled:YES];
    [_thursday setEnabled:YES];
    [_friday setEnabled:YES];
    [_saturday setEnabled:YES];
    [_sunday setEnabled:YES];
    [_datePickerTime setEnabled:YES];
    [_btnLock setEnabled:YES];
    [_btnUnlock setEnabled:NO];
}

-(void)updatePrefs {
    _prefs = [NSUserDefaults standardUserDefaults];
    NSDate *prefTime = [_prefs objectForKey:@"Time to Wipe"];
    _datePickerTime.dateValue = prefTime;
    if (_prefMon) {
        _monday.state = NSOnState;
    }
    else {
        _monday.state = NSOffState;
    }
    if (_prefTues) {
        _tuesday.state = NSOnState;
    }
    else {
        _monday.state = NSOffState;
    }
    if (_prefWed) {
        _wednesday.state = NSOnState;
    }
    else {
        _wednesday.state = NSOffState;
    }
    if (_prefThu) {
        _thursday.state = NSOnState;
    }
    else {
        _thursday.state = NSOffState;
    }
    if (_prefFri) {
        _friday.state = NSOnState;
    }
    else {
        _friday.state = NSOffState;
    }
    if (_prefSat) {
        _saturday.state = NSOnState;
    }
    else {
        _saturday.state = NSOffState;
    }
    if (_prefSun) {
        _sunday.state = NSOnState;
    }
    else {
        _sunday.state = NSOffState;
    }
    _prefPassword = [_prefs stringForKey:@"password"];
    [_prefs synchronize];
}


@end