//
//  MainControl.h
//  TalQ
//
//  Created by Charles Hawkins on 8/4/10.
//  Copyright 2010 - 2014 Charles Hawkins.

/*      This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

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
