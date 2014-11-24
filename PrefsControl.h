//
//  PrefsControl.h
//  Speak Queue
//
//  Created by Charles Hawkins on 1/20/11.
//  Copyright 2011 - 2014 Charles Hawkins.
//
//  Description: PrefsControl manages the preferences window.  This mainly means managing
//  the hotkey-setting NSSheet and grabbing the hotkeys the user enters.  Key events while
//  the hotkey-setting sheet is up trigger the ^handleGrabbedHotkey block located in enqueueHotkeyWindow:.
//  Hotkeys are saved to NSUserDefaults as they are entered.  When the sheet ends, MainControl
//  is passed [setupHotkeys] which gets the keys from the user defaults and sets up its listeners.
//

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

#import <Cocoa/Cocoa.h>
#import "MainControl.h"

@class MainControl;

@interface PrefsControl : NSObject <NSTableViewDataSource, NSTabViewDelegate> {
	IBOutlet MainControl *theMainControl;
	IBOutlet NSTextField *prefsEnqueueHotkey;
	IBOutlet NSTextField *prefsPopupHotkey;
	IBOutlet NSTextField *prefsAdvHotkey;
    IBOutlet NSTextField *prefsPauseHotkey;
    IBOutlet NSTextField *prefsNextHotkey;
    IBOutlet NSTextField *prefsBackHotkey;
	IBOutlet NSTextField *grabHotkey;
	IBOutlet NSPanel *hotkeySheet;
	IBOutlet NSWindow *prefsWindow;
	IBOutlet NSTableView *theTable;
	IBOutlet NSButton *buttonRemove;
    IBOutlet NSSlider *defaultRateSlider;
	NSUserDefaults *prefs;
	int hotkeyTmp;
	int modsTmp;
	int hotkeyTag;
	id hotkeyEventMonitor;
	NSMutableArray *replace;
	NSMutableArray *replaceWith;
    NSMutableArray *caseSensitive;
}

- (void)awakeFromNib;
- (IBAction)enqueueHotkeyWindow:(id)sender;
- (IBAction)hotkeyWindowOk:(id)sender;
- (IBAction)hotkeyWindowCancel:(id)sender;
- (IBAction)hotkeyWindowClear:(id)sender;
- (IBAction)reloadVoiceList:(id)sender;
- (IBAction)resetRates:(id)sender;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)showPrefsWindow;

- (IBAction)addButton:(id)sender;
- (IBAction)removeButton:(id)sender;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
@end
