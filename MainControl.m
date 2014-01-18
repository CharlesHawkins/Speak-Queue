//
//  MainControl.m
//  TalQ
//
//  Created by Charles Hawkins on 8/4/10.
//  Copyright 2010 - 2014 Charles Hawkins. All rights reserved.
//

#import "MainControl.h"
#import "AdvControl.h"

NSDictionary *keyDictionary;

const double minSpeakingRate = 90.0;
const double maxSpeakingRate = 360.0;

@implementation MainControl
- (id) init
{
	NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:[NSNumber numberWithInt:38] forKey:@"hotkeyEnqueue"];
	[defaultPrefs setObject:[NSNumber numberWithInt:cmdKey+controlKey] forKey:@"modsEnqueue"];
	[defaultPrefs setObject:[NSNumber numberWithInt:38] forKey:@"hotkeyPopup"];
	[defaultPrefs setObject:[NSNumber numberWithInt:cmdKey+optionKey+controlKey] forKey:@"modsPopup"];
	[defaultPrefs setObject:[NSNumber numberWithInt:38] forKey:@"hotkeyAdv"];
	[defaultPrefs setObject:[NSNumber numberWithInt:cmdKey+optionKey+shiftKey] forKey:@"modsAdv"];
    [defaultPrefs setObject:[NSNumber numberWithInt:0x31] forKey:@"hotkeyPause"];
	[defaultPrefs setObject:[NSNumber numberWithInt:cmdKey+controlKey] forKey:@"modsPause"];
    [defaultPrefs setObject:[NSNumber numberWithInt:0x7c] forKey:@"hotkeyNext"];
	[defaultPrefs setObject:[NSNumber numberWithInt:cmdKey+controlKey] forKey:@"modsNext"];
    [defaultPrefs setObject:[NSNumber numberWithInt:0x7b] forKey:@"hotkeyBack"];
	[defaultPrefs setObject:[NSNumber numberWithInt:cmdKey+controlKey] forKey:@"modsBack"];
    [defaultPrefs setObject:[NSNumber numberWithFloat:215.0f] forKey:@"DefaultRate"];
    [defaultPrefs setObject:[NSDictionary dictionary] forKey:@"Rates"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self initKeyDictinoary];
	return self;
}

- (void)awakeFromNib
{
	if(!prefs)
	{
		prefs = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
		
		/* Set up the global hotkey that enqueues the current selection */
		[self setupHotkeys];
		
		/* Populate the list of available voices and set them to the default speaking rate */
        [self loadVoiceListClearingFirst:NO];
		/* Initialize the rate slider */
		[rateSlider setMinValue:minSpeakingRate];
		[rateSlider setMaxValue:maxSpeakingRate];
		[rateSlider setFloatValue:[[prefs objectForKey:@"DefaultRate"] floatValue]];
		[rateSlider setNumberOfTickMarks:5];
		
		/* Load icons */
		playIcon = [NSImage imageNamed:@"PlayTemplate.pdf"];
		pauseIcon = [NSImage imageNamed:@"Pause.png"];
		
		[voicePopup selectItemAtIndex:0];
		[self chooseVoice:voicePopup];
		
		[statusBar setStringValue:@"Idle"];
        [theTable setDelegate:self];
		/* Tap to find keycodes */
        [theWindow makeFirstResponder:self];
        [theTable setNextResponder:self];
        
	}
}

- (void)loadVoiceListClearingFirst:(bool)clearFirst
{
    voiceNameToIdentifier = [NSMutableDictionary dictionary];
    if(!clearFirst && (listOfVoiceIdentifiers = [NSMutableArray arrayWithArray:[prefs objectForKey:@"voiceArray"]]))
    {
        NSArray *listOfAvailableVoiceIdentifiers = [NSSpeechSynthesizer availableVoices];
        NSSet *setOfVoiceIdentifiers = [NSSet setWithArray:listOfVoiceIdentifiers];
        NSSet *setOfAvailableVoiceIdentifiers = [NSSet setWithArray:listOfAvailableVoiceIdentifiers];
        for (NSString *currentVoiceIdentifier in listOfVoiceIdentifiers)
        {
            if(![setOfAvailableVoiceIdentifiers containsObject:currentVoiceIdentifier])
                [listOfVoiceIdentifiers removeObject:currentVoiceIdentifier];
        }
        for (NSString *currentVoiceIdentifier in listOfAvailableVoiceIdentifiers)
        {
            if(![setOfVoiceIdentifiers containsObject:currentVoiceIdentifier])
                [listOfVoiceIdentifiers addObject:currentVoiceIdentifier];
        }
    }
    else
        listOfVoiceIdentifiers = [NSMutableArray arrayWithArray:[NSSpeechSynthesizer availableVoices]];
    NSMutableArray *listOfVoiceNames = [NSMutableArray arrayWithCapacity:[listOfVoiceIdentifiers count]];

    for (NSString *currentVoiceIdentifier in listOfVoiceIdentifiers)
    {
        NSArray *voiceIdentifierComponents = [currentVoiceIdentifier componentsSeparatedByString:@"."];
        NSString *voiceName = [[voiceIdentifierComponents objectAtIndex:5] capitalizedString];
        [listOfVoiceNames addObject:voiceName];
        [voiceNameToIdentifier setObject:currentVoiceIdentifier forKey:voiceName];
    }
    
    [voicePopup removeAllItems];
    [voicePopup addItemsWithTitles:listOfVoiceNames];
    selectedVoice = [listOfVoiceNames objectAtIndex:0];
    voiceRates = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"Rates"]];
    [rateSlider setFloatValue:[[voiceRates objectForKey:selectedVoice] floatValue]];
}

- (void)setupHotkeys
{
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	if(!gMyHotKeyRef)
	{	
		InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,(__bridge void*)self, NULL);
	}

	gMyHotKeyID.signature='htk1';
	gMyHotKeyID.id=hotKeyIDQuick;
	NSInteger hotkeyEnqueue = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyEnqueue"];
	NSInteger modsEnqueue = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsEnqueue"];
	if(hotkeyEnqueue != -999)
	{
		RegisterEventHotKey(hotkeyEnqueue, modsEnqueue, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
	}
	gMyHotKeyID.signature='htk2';
	gMyHotKeyID.id=hotKeyIDPopup;
	NSInteger hotkeyPopup = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyPopup"];
	NSInteger modsPopup = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsPopup"];
	if(hotkeyPopup != -999)
	{
		RegisterEventHotKey(hotkeyPopup, modsPopup, gMyHotKeyID, GetApplicationEventTarget(), 0, &gPopupHotKeyRef);
	}
	gMyHotKeyID.signature='htk3';
	gMyHotKeyID.id=hotKeyIDAdv;
	NSInteger hotkeyAdv = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyAdv"];
	NSInteger modsAdv = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsAdv"];
	if(hotkeyAdv != -999)
	{
		RegisterEventHotKey(hotkeyAdv, modsAdv, gMyHotKeyID, GetApplicationEventTarget(), 0, &gAdvHotKeyRef);
	}
    gMyHotKeyID.signature='htk4';
	gMyHotKeyID.id=hotKeyIDPause;
	NSInteger hotkeyPause = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyPause"];
	NSInteger modsPause = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsPause"];
	if(hotkeyPause != -999)
	{
		RegisterEventHotKey(hotkeyPause, modsPause, gMyHotKeyID, GetApplicationEventTarget(), 0, &gPauseHotKeyRef);
	}
    gMyHotKeyID.signature='htk5';
	gMyHotKeyID.id=hotKeyIDNext;
	NSInteger hotkeyNext = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyNext"];
	NSInteger modsNext = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsNext"];
	if(hotkeyNext != -999)
	{
		RegisterEventHotKey(hotkeyNext, modsNext, gMyHotKeyID, GetApplicationEventTarget(), 0, &gNextHotKeyRef);
	}
    gMyHotKeyID.signature='htk6';
	gMyHotKeyID.id=hotKeyIDBack;
	NSInteger hotkeyBack = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyBack"];
	NSInteger modsBack = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsBack"];
	if(hotkeyBack != -999)
	{
		RegisterEventHotKey(hotkeyBack, modsBack, gMyHotKeyID, GetApplicationEventTarget(), 0, &gBackHotKeyRef);
	}
}

- (void)initKeyDictinoary
{
	if (!keyDictionary)
	{
		keyDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
						 @"A", [NSNumber numberWithInt: 0x00],
						 @"S", [NSNumber numberWithInt: 0x01],
						 @"D", [NSNumber numberWithInt: 0x02],
						 @"F", [NSNumber numberWithInt: 0x03],
						 @"H", [NSNumber numberWithInt: 0x04],
						 @"G", [NSNumber numberWithInt: 0x05],
						 @"Z", [NSNumber numberWithInt: 0x06],
						 @"X", [NSNumber numberWithInt: 0x07],
						 @"C", [NSNumber numberWithInt: 0x08],
						 @"V", [NSNumber numberWithInt: 0x09],
						 @"B", [NSNumber numberWithInt: 0x0B],
						 @"Q", [NSNumber numberWithInt: 0x0C],
						 @"W", [NSNumber numberWithInt: 0x0D],
						 @"E", [NSNumber numberWithInt: 0x0E],
						 @"R", [NSNumber numberWithInt: 0x0F],
						 @"Y", [NSNumber numberWithInt: 0x10],
						 @"T", [NSNumber numberWithInt: 0x11],
						 @"1", [NSNumber numberWithInt: 0x12],
						 @"2", [NSNumber numberWithInt: 0x13],
						 @"3", [NSNumber numberWithInt: 0x14],
						 @"4", [NSNumber numberWithInt: 0x15],
						 @"6", [NSNumber numberWithInt: 0x16],
						 @"5", [NSNumber numberWithInt: 0x17],
						 @"Equal", [NSNumber numberWithInt: 0x18],
						 @"9", [NSNumber numberWithInt: 0x19],
						 @"7", [NSNumber numberWithInt: 0x1A],
						 @"Minus", [NSNumber numberWithInt: 0x1B],
						 @"8", [NSNumber numberWithInt: 0x1C],
						 @"0", [NSNumber numberWithInt: 0x1D],
						 @"RightBracket", [NSNumber numberWithInt: 0x1E],
						 @"O", [NSNumber numberWithInt: 0x1F],
						 @"U", [NSNumber numberWithInt: 0x20],
						 @"LeftBracket", [NSNumber numberWithInt: 0x21],
						 @"I", [NSNumber numberWithInt: 0x22],
						 @"P", [NSNumber numberWithInt: 0x23],
						 @"L", [NSNumber numberWithInt: 0x25],
						 @"J", [NSNumber numberWithInt: 0x26],
						 @"Quote", [NSNumber numberWithInt: 0x27],
						 @"K", [NSNumber numberWithInt: 0x28],
						 @"Semicolon", [NSNumber numberWithInt: 0x29],
						 @"Backslash", [NSNumber numberWithInt: 0x2A],
						 @"Comma", [NSNumber numberWithInt: 0x2B],
						 @"Slash", [NSNumber numberWithInt: 0x2C],
						 @"N", [NSNumber numberWithInt: 0x2D],
						 @"M", [NSNumber numberWithInt: 0x2E],
						 @"Period", [NSNumber numberWithInt: 0x2F],
						 @"Grave", [NSNumber numberWithInt: 0x32],
						 @"KeypadDecimal", [NSNumber numberWithInt: 0x41],
						 @"KeypadMultiply", [NSNumber numberWithInt: 0x43],
						 @"KeypadPlus", [NSNumber numberWithInt: 0x45],
						 @"KeypadClear", [NSNumber numberWithInt: 0x47],
						 @"KeypadDivide", [NSNumber numberWithInt: 0x4B],
						 @"KeypadEnter", [NSNumber numberWithInt: 0x4C],
						 @"KeypadMinus", [NSNumber numberWithInt: 0x4E],
						 @"KeypadEquals", [NSNumber numberWithInt: 0x51],
						 @"Keypad0", [NSNumber numberWithInt: 0x52],
						 @"Keypad1", [NSNumber numberWithInt: 0x53],
						 @"Keypad2", [NSNumber numberWithInt: 0x54],
						 @"Keypad3", [NSNumber numberWithInt: 0x55],
						 @"Keypad4", [NSNumber numberWithInt: 0x56],
						 @"Keypad5", [NSNumber numberWithInt: 0x57],
						 @"Keypad6", [NSNumber numberWithInt: 0x58],
						 @"Keypad7", [NSNumber numberWithInt: 0x59],
						 @"Keypad8", [NSNumber numberWithInt: 0x5B],
						 @"Keypad9", [NSNumber numberWithInt: 0x5C],
						 @"Return", [NSNumber numberWithInt: 0x24],
						 @"Tab", [NSNumber numberWithInt: 0x30],
						 @"Space", [NSNumber numberWithInt: 0x31],
						 @"Delete", [NSNumber numberWithInt: 0x33],
						 @"Escape", [NSNumber numberWithInt: 0x35],
						 @"Command", [NSNumber numberWithInt: 0x37],
						 @"Shift", [NSNumber numberWithInt: 0x38],
						 @"CapsLock", [NSNumber numberWithInt: 0x39],
						 @"Option", [NSNumber numberWithInt: 0x3A],
						 @"Control", [NSNumber numberWithInt: 0x3B],
						 @"RightShift", [NSNumber numberWithInt: 0x3C],
						 @"RightOption", [NSNumber numberWithInt: 0x3D],
						 @"RightControl", [NSNumber numberWithInt: 0x3E],
						 @"Function", [NSNumber numberWithInt: 0x3F],
						 @"F17", [NSNumber numberWithInt: 0x40],
						 @"VolumeUp", [NSNumber numberWithInt: 0x48],
						 @"VolumeDown", [NSNumber numberWithInt: 0x49],
						 @"Mute", [NSNumber numberWithInt: 0x4A],
						 @"F18", [NSNumber numberWithInt: 0x4F],
						 @"F19", [NSNumber numberWithInt: 0x50],
						 @"F20", [NSNumber numberWithInt: 0x5A],
						 @"F5", [NSNumber numberWithInt: 0x60],
						 @"F6", [NSNumber numberWithInt: 0x61],
						 @"F7", [NSNumber numberWithInt: 0x62],
						 @"F3", [NSNumber numberWithInt: 0x63],
						 @"F8", [NSNumber numberWithInt: 0x64],
						 @"F9", [NSNumber numberWithInt: 0x65],
						 @"F11", [NSNumber numberWithInt: 0x67],
						 @"F13", [NSNumber numberWithInt: 0x69],
						 @"F16", [NSNumber numberWithInt: 0x6A],
						 @"F14", [NSNumber numberWithInt: 0x6B],
						 @"F10", [NSNumber numberWithInt: 0x6D],
						 @"F12", [NSNumber numberWithInt: 0x6F],
						 @"F15", [NSNumber numberWithInt: 0x71],
						 @"Help", [NSNumber numberWithInt: 0x72],
						 @"Home", [NSNumber numberWithInt: 0x73],
						 @"PageUp", [NSNumber numberWithInt: 0x74],
						 @"ForwardDelete", [NSNumber numberWithInt: 0x75],
						 @"F4", [NSNumber numberWithInt: 0x76],
						 @"End", [NSNumber numberWithInt: 0x77],
						 @"F2", [NSNumber numberWithInt: 0x78],
						 @"PageDown", [NSNumber numberWithInt: 0x79],
						 @"F1", [NSNumber numberWithInt: 0x7A],
						 @"LeftArrow", [NSNumber numberWithInt: 0x7B],
						 @"RightArrow", [NSNumber numberWithInt: 0x7C],
						 @"DownArrow", [NSNumber numberWithInt: 0x7D],
						 @"UpArrow", [NSNumber numberWithInt: 0x7E],
						 nil];
		
	}
	
}

- (void)handleHotKey    /* The quick enqueue hotkey (originally the only hotkey) */
{
   // NSArray *oldContents = [[NSPasteboard generalPasteboard] pasteboardItems];
    //NSLog(@"Might restore pasteboard to: %@\n", oldContents);
	[[NSPasteboard generalPasteboard] clearContents];	/* Clear the clipboard; otherwise we'll be fooled by what's already in there */
	
	[self sendCopyCommand];
	for(int giveup = 0; giveup < 12 && [[[NSPasteboard generalPasteboard] types] count] == 0; giveup++) {		/* Yeah, it's a spin-lock, sorry :( */
		usleep(100000);
	}
	NSArray *pbItems = [[NSPasteboard generalPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
	if([pbItems count] > 0)
	{
        NSLog(@"Rate: %f\n", [rateSlider floatValue]);
		[theQueue enqueueText:[pbItems objectAtIndex:0] withVoice:selectedVoice atRate:[NSNumber numberWithFloat:[rateSlider floatValue]]];
	}
    /*if([prefs boolForKey:@"PreserveClipboard"])
    {
        NSLog(@"Restoring pasteboard to: %@\n", oldContents);
        [[NSPasteboard generalPasteboard] clearContents];
        if (![[NSPasteboard generalPasteboard] writeObjects:oldContents])
        {
            NSLog(@"Couldn't restore pasteboard :(\n");
        }
    }*/
}

- (void)handlePopupHotKey
{
    NSArray *oldContents = [[NSPasteboard generalPasteboard] pasteboardItems];
	[[NSPasteboard generalPasteboard] clearContents];	/* Clear the clipboard; otherwise we'll be fooled by what's already in there */
	
	[self sendCopyCommand];
	for(int giveup = 0; giveup < 12 && [[[NSPasteboard generalPasteboard] types] count] == 0; giveup++) {		/* Yeah, it's a spin-lock, sorry :( */
		usleep(100000);
	}
	NSArray *pbItems = [[NSPasteboard generalPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
	if([pbItems count] > 0)
	{
		if(!thePopup)
			[NSBundle loadNibNamed:@"PopupWindow" owner:self];
		[thePopup popupWithText:[pbItems objectAtIndex:0] withVoices:[voicePopup itemArray] atRates:voiceRates];
	}
    if([prefs boolForKey:@"PreserveClipboard"])
    {
        [[NSPasteboard generalPasteboard] writeObjects:oldContents];
    }

}

- (void)handleAdvHotKey
{
    NSArray *oldContents = [[NSPasteboard generalPasteboard] pasteboardItems];
	[[NSPasteboard generalPasteboard] clearContents];	/* Clear the clipboard; otherwise we'll be fooled by what's already in there */
	
	[self sendCopyCommand];
	for(int giveup = 0; giveup < 12 && [[[NSPasteboard generalPasteboard] types] count] == 0; giveup++) {		/* Yeah, it's a spin-lock, sorry :( */
		usleep(100000);
	}
	NSArray *pbItems = [[NSPasteboard generalPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
	if([pbItems count] > 0)
	{
		if(!theAdv)
			[NSBundle loadNibNamed:@"AdvPopup" owner:self];
		[theAdv popupWithText:[pbItems objectAtIndex:0] withVoices:[voicePopup itemArray] atRates:voiceRates];
	}
    if([prefs boolForKey:@"PreserveClipboard"])
    {
        [[NSPasteboard generalPasteboard] writeObjects:oldContents];
    }

}

- (void)sendCopyCommand
{
	CGEventRef dnC = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)8, true);	//The 'C' key
	CGEventRef upC = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)8, false);
	CGEventSetFlags(dnC, 0x100108);	//This sets the flags so Cmd (and only Cmd) is down
	CGEventSetFlags(upC, 0x100108);
	CGEventPost(kCGHIDEventTap,dnC);
	CGEventPost(kCGHIDEventTap,upC);
}
- (void)resetRates
{
    voiceRates = [NSMutableDictionary dictionaryWithCapacity:[listOfVoiceIdentifiers count]];
    [prefs setObject:voiceRates forKey:@"Rates"];
}
- (void)setStatus:(NSString *)status
{
	[statusBar setStringValue:status];
}

- (IBAction)chooseVoice:(id)sender
{
	selectedVoice = [sender titleOfSelectedItem];
    NSNumber *rate = [voiceRates objectForKey:selectedVoice];
	[rateSlider setFloatValue:rate?[rate floatValue]:[[prefs objectForKey:@"DefaultRate"] floatValue]];
	if([prefs boolForKey:@"moveVoicesToTop"])
	{
		[voicePopup removeItemWithTitle:selectedVoice];
		[voicePopup insertItemWithTitle:selectedVoice atIndex:0];
		[voicePopup selectItemWithTitle:selectedVoice];
        NSString *selectedVoiceIdentifier = [voiceNameToIdentifier objectForKey:selectedVoice];
        [listOfVoiceIdentifiers removeObject:selectedVoiceIdentifier];
        [listOfVoiceIdentifiers insertObject:selectedVoiceIdentifier atIndex:0];
        [prefs setObject:listOfVoiceIdentifiers forKey:@"voiceArray"];
	}

	
	//[rateSlider setNeedsDisplay:YES];
}

- (IBAction)pauseUnpause:(id)sender
{
    [self pauseUnpauseHotkey:[[sender class] isSubclassOfClass:[NSSegmentedControl class]]?[sender selectedSegment]:[sender tag]];
}
- (void)pauseUnpauseHotkey:(int)action
{
    switch (action) {
        case 0:
            [theQueue speakNextQueueItem];
            break;
        case 1:
            if([theQueue isPaused])
            {
                [theQueue unpauseSpeaking];
                [controls setImage:pauseIcon forSegment:1];
                
            }
            else {
                [theQueue pauseSpeaking];
                [controls setImage:playIcon forSegment:1];
            }
            break;
        case 2:
            [theQueue skipNextQueueItem];
            break;
            
            
        default:
            break;
    }
}

- (IBAction)clearQueue:(id)sender
{
	[theQueue clearQueue];
}

- (IBAction)showPrefs:(id)sender
{
	if(!thePrefs)
		[NSBundle loadNibNamed:@"PrefsWindow" owner:self];
	[thePrefs showPrefsWindow];
}

- (IBAction)deleteItem:(id)sender
{
    [theQueue deleteItem];
}

- (IBAction)changedRate:(id)sender
{
    [voiceRates setObject:[NSNumber numberWithFloat:[sender floatValue]] forKey:selectedVoice];
    [prefs setObject:voiceRates forKey:@"Rates"];
    [rateSlider setFloatValue:[sender floatValue]];
}

- (int)enqueueText:(NSString*)theText withVoice:(NSString*)theVoice atRate:(NSNumber*)rate
{
    if(!rate)
    {
        if(!(rate = [prefs objectForKey:theVoice]))
            rate = [prefs objectForKey:@"DefaultRate"];
    }
	if([prefs boolForKey:@"moveVoicesToTop"])
	{
		[voicePopup removeItemWithTitle:theVoice];
		[voicePopup insertItemWithTitle:theVoice atIndex:0];
		[voicePopup selectItemWithTitle:theVoice];
        NSString *selectedVoiceIdentifier = [voiceNameToIdentifier objectForKey:theVoice];
        [listOfVoiceIdentifiers removeObject:selectedVoiceIdentifier];
        [listOfVoiceIdentifiers insertObject:selectedVoiceIdentifier atIndex:0];
        [prefs setObject:listOfVoiceIdentifiers forKey:@"voiceArray"];
	}
	selectedVoice = theVoice;
    NSLog(@"enqueueText, rate is %@\n", rate);
    [rateSlider setFloatValue:[rate floatValue]];
	return [theQueue enqueueText:theText withVoice:theVoice atRate:rate];
}

- (void)unregisterHotkeys
{
	UnregisterEventHotKey(gMyHotKeyRef);
	UnregisterEventHotKey(gPopupHotKeyRef);
	UnregisterEventHotKey(gAdvHotKeyRef);
    UnregisterEventHotKey(gPauseHotKeyRef);
    UnregisterEventHotKey(gNextHotKeyRef);
    UnregisterEventHotKey(gBackHotKeyRef);
}
- (NSString*)getIdentifierForVoice:(NSString*)voiceName
{
    return [voiceNameToIdentifier objectForKey:voiceName];
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    BOOL canDelete = (BOOL)[[theTable selectedRowIndexes] count];
	[buttonRemove setEnabled:canDelete];
    [menuRemove setEnabled:canDelete];
}
- (BOOL)acceptsFirstResponder
{
    return YES;
}
- (BOOL)becomeFirstResponder
{
    return YES;
}
- (void)keyDown:(NSEvent *)theEvent
{
    unsigned short code = [theEvent keyCode];
    switch (code) {
        case 49:    /* Space */
            [self pauseUnpause:buttonRemove];   /* buttonRemove has tag 1, so the pause / unpause action will be triggered */
        case 51:    /* Delete */
            if([buttonRemove isEnabled])
                [self deleteItem: buttonRemove];
        default:
            [super keyDown:theEvent];
    }
}
@end

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData)
{
	EventHotKeyID hkCom;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkCom),NULL,&hkCom);
	switch(hkCom.id)
	{
		case hotKeyIDQuick:
			[((__bridge id)userData) handleHotKey]; break;
		case hotKeyIDPopup:
			[((__bridge id)userData) handlePopupHotKey]; break;
		case hotKeyIDAdv:
			[((__bridge id)userData) handleAdvHotKey]; break;
        case hotKeyIDPause:
            [((__bridge id)userData) pauseUnpauseHotkey:1]; break;
        case hotKeyIDNext:
            [((__bridge id)userData) pauseUnpauseHotkey:2]; break;
        case hotKeyIDBack:
            [((__bridge id)userData) pauseUnpauseHotkey:0]; break;
	}
	return noErr;
}
OSStatus MyHotKeyPopupHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData)
{
	[((__bridge id)userData) handlePopupHotKey];
	return noErr;
}
CGEventRef keyTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
	UniCharCount u, max = 10;
	UniChar *kbStr = malloc(sizeof(UniChar)*max);
	CGEventKeyboardGetUnicodeString(event, max, &u, kbStr);
	return event;
}

NSString *hotkeyString(int hotkeyCode, int modsCode)
{
	if (hotkeyCode == -999) {
		return @"";
	}
	NSMutableString *hkString = [NSMutableString stringWithCapacity:34];
	if (modsCode&cmdKey)
		[hkString appendString:@"Cmd+"];
	if (modsCode&optionKey)
		[hkString appendString:@"Opt+"];
	if (modsCode&controlKey)
		[hkString appendString:@"Ctrl+"];
	if (modsCode&shiftKey)
		[hkString appendString:@"Shift+"];
	[hkString appendString:[keyDictionary objectForKey:[NSNumber numberWithInt:hotkeyCode]]];
	return hkString;
}


int cocoaToCarbonModMask(int cocoaModMask)
{
	return ((cocoaModMask&NSCommandKeyMask)?cmdKey:0)+((cocoaModMask&NSAlternateKeyMask)?optionKey:0)+((cocoaModMask&NSControlKeyMask)?controlKey:0)+((cocoaModMask&NSShiftKeyMask)?shiftKey:0);
}
