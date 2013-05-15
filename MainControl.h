//
//  MainControl.h
//  TalQ
//
//  Created by Charles Hawkins on 8/4/10.
//  Copyright 2010 Charles Hawkins. All rights reserved.
//
#ifndef MAINCONTROL
#define MAINCONTROL
#import <Cocoa/Cocoa.h>
#import "SpeechQueue.h"
#import "PopupControl.h"
#import "PrefsControl.h"

enum {
	hotKeyIDQuick = 1,
	hotKeyIDPopup = 2,
	hotKeyIDAdv = 3,
    hotKeyIDPause = 4,
    hotKeyIDNext = 5,
    hotKeyIDBack = 6
};

@class SpeechQueue;
@class AdvControl;
@class PopupControl;
@class PrefsControl;

@interface MainControl : NSResponder <NSTableViewDelegate> {
	NSString *selectedVoice;
	NSMutableDictionary *voiceRates;
    NSMutableDictionary *voiceNameToIdentifier;
    NSMutableArray *listOfVoiceIdentifiers;
	IBOutlet SpeechQueue *theQueue;	/* Queue of items to speak */
	IBOutlet AdvControl *theAdv;
	IBOutlet PopupControl *thePopup;
	IBOutlet PrefsControl *thePrefs;
	IBOutlet NSPopUpButton *voicePopup;
	IBOutlet NSSlider *rateSlider;
	IBOutlet NSMenuItem *appMenuItem; /* Nothing else I try works for changing the app menu to the new name */
	IBOutlet NSMenu	*appMenu;
	IBOutlet NSTextField *statusBar;
    IBOutlet NSSegmentedControl *controls;
    IBOutlet NSTableView *theTable;
    IBOutlet NSButton *buttonRemove;
    IBOutlet NSMenuItem *menuRemove;
    IBOutlet NSWindow *theWindow;
	NSImage *playIcon;
	NSImage *pauseIcon;
	NSUserDefaults *prefs;
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyRef gPopupHotKeyRef;
	EventHotKeyRef gAdvHotKeyRef;
    EventHotKeyRef gPauseHotKeyRef;
    EventHotKeyRef gNextHotKeyRef;
    EventHotKeyRef gBackHotKeyRef;
    int PauseUnpauseAction; /* Used to tell the pauseUnpause function what to do (0 = back, 1 = pause/unpause, 2 = next */
}
- (void)awakeFromNib;
- (void)loadVoiceListClearingFirst:(bool)clearFirst;
- (void)setupHotkeys;
- (void)initKeyDictinoary;
- (void)handleHotKey;
- (void)handlePopupHotKey;
- (void)handleAdvHotKey;
- (void)pauseUnpauseHotkey:(int)action;
- (void)sendCopyCommand;
- (void)resetRates;
- (IBAction)chooseVoice:(id)sender;
- (IBAction)pauseUnpause:(id)sender;
- (IBAction)clearQueue:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)changedRate:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (void)setStatus:(NSString*)status;
- (int)enqueueText:(NSString*)theText withVoice:(NSString*)theVoice atRate:(NSNumber*)rate;
- (void)unregisterHotkeys;
- (NSString*)getIdentifierForVoice:(NSString*)voiceName;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (BOOL)acceptsFirstResponder;
- (void)keyDown:(NSEvent *)theEvent;
@end

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData);
OSStatus MyHotKeyPopupHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData);
CGEventRef keyTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon);
NSString *hotkeyString(int hotkeyCode, int modsCode);
int cocoaToCarbonModMask(int cocoaModMask);
#endif
