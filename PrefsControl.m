//
//  PrefsControl.m
//  Speak Queue
//
//  Created by Charles Hawkins on 1/20/11.
//  Copyright 2011 - 2014 Charles Hawkins.

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

#import "PrefsControl.h"


@implementation PrefsControl

- (void)awakeFromNib
{
	prefs = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	[prefsEnqueueHotkey setStringValue: hotkeyString([prefs integerForKey:@"hotkeyEnqueue"],[prefs integerForKey:@"modsEnqueue"])];
	[prefsPopupHotkey setStringValue: hotkeyString([prefs integerForKey:@"hotkeyPopup"],[prefs integerForKey:@"modsPopup"])];
	[prefsAdvHotkey setStringValue: hotkeyString([prefs integerForKey:@"hotkeyAdv"],[prefs integerForKey:@"modsAdv"])];
    [prefsPauseHotkey setStringValue: hotkeyString([prefs integerForKey:@"hotkeyPause"],[prefs integerForKey:@"modsPause"])];
    [prefsNextHotkey setStringValue: hotkeyString([prefs integerForKey:@"hotkeyNext"],[prefs integerForKey:@"modsNext"])];
    [prefsBackHotkey setStringValue: hotkeyString([prefs integerForKey:@"hotkeyBack"],[prefs integerForKey:@"modsBack"])];
	if((replace = [prefs objectForKey:@"replace"]))
        replace = [NSMutableArray arrayWithArray:replace];
    else
		replace = [NSMutableArray array];
	if((replaceWith = [prefs objectForKey:@"replaceWith"]))
        replaceWith = [NSMutableArray arrayWithArray:replaceWith];
    else
		replaceWith = [NSMutableArray array];
    if((caseSensitive = [prefs objectForKey:@"caseSensitive"]))
        caseSensitive = [NSMutableArray arrayWithArray:caseSensitive];
    else
		caseSensitive = [NSMutableArray array];
	[buttonRemove setEnabled:NO];
	[theTable reloadData];
}

- (IBAction)enqueueHotkeyWindow:(id)sender
{
	hotkeyTag = [sender tag];
	switch(hotkeyTag)
	{
		case hotKeyIDQuick:
			[grabHotkey setStringValue:[prefsEnqueueHotkey stringValue]];
			hotkeyTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyEnqueue"];
			modsTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsEnqueue"];
			break;
		case hotKeyIDPopup:
			[grabHotkey setStringValue:[prefsPopupHotkey stringValue]];
			hotkeyTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyPopup"];
			modsTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsPopup"];
			break;
		case hotKeyIDAdv:
			[grabHotkey setStringValue:[prefsAdvHotkey stringValue]];
			hotkeyTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyAdv"];
			modsTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsAdv"];
			break;
        case hotKeyIDPause:
			[grabHotkey setStringValue:[prefsPauseHotkey stringValue]];
			hotkeyTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyPause"];
			modsTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsPause"];
			break;
        case hotKeyIDNext:
			[grabHotkey setStringValue:[prefsNextHotkey stringValue]];
			hotkeyTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyNext"];
			modsTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsNext"];
			break;
        case hotKeyIDBack:
			[grabHotkey setStringValue:[prefsBackHotkey stringValue]];
			hotkeyTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyBack"];
			modsTmp = [[NSUserDefaults standardUserDefaults] integerForKey:@"modsBack"];
			break;
	}
	NSEvent *(^handleGrabbedHotkey)(NSEvent*) = ^(NSEvent *keyEvent)
	{
		modsTmp = cocoaToCarbonModMask([keyEvent modifierFlags]);
		hotkeyTmp = [keyEvent keyCode];
		[grabHotkey setStringValue: hotkeyString(hotkeyTmp, modsTmp)];
		return (NSEvent*)nil;
	};
	[NSApp beginSheet:hotkeySheet modalForWindow:prefsWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
	[theMainControl unregisterHotkeys];
	hotkeyEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:handleGrabbedHotkey];
}

- (IBAction)hotkeyWindowOk:(id)sender
{
	switch(hotkeyTag)
	{
		case hotKeyIDQuick:		/* The "Enqueue" Hotkey */
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hotkeyTmp] forKey:@"hotkeyEnqueue"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:modsTmp] forKey:@"modsEnqueue"];
			[prefsEnqueueHotkey setStringValue:[grabHotkey stringValue]];
			break;
		case hotKeyIDPopup:		/* The "Popup" Hotkey */
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hotkeyTmp] forKey:@"hotkeyPopup"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:modsTmp] forKey:@"modsPopup"];
			[prefsPopupHotkey setStringValue:[grabHotkey stringValue]];
			break;
		case hotKeyIDAdv:		/* The "Popup" Hotkey */
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hotkeyTmp] forKey:@"hotkeyAdv"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:modsTmp] forKey:@"modsAdv"];
			[prefsAdvHotkey setStringValue:[grabHotkey stringValue]];
			break;
        case hotKeyIDPause:		/* The "Popup" Hotkey */
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hotkeyTmp] forKey:@"hotkeyPause"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:modsTmp] forKey:@"modsPause"];
			[prefsPauseHotkey setStringValue:[grabHotkey stringValue]];
			break;
        case hotKeyIDNext:		/* The "Popup" Hotkey */
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hotkeyTmp] forKey:@"hotkeyNext"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:modsTmp] forKey:@"modsNext"];
			[prefsNextHotkey setStringValue:[grabHotkey stringValue]];
			break;
        case hotKeyIDBack:		/* The "Popup" Hotkey */
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hotkeyTmp] forKey:@"hotkeyBack"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:modsTmp] forKey:@"modsBack"];
			[prefsBackHotkey setStringValue:[grabHotkey stringValue]];
			break;
	}
	[NSApp endSheet:hotkeySheet];
}

- (IBAction)hotkeyWindowCancel:(id)sender
{
	[NSApp endSheet:hotkeySheet];
}

- (IBAction)hotkeyWindowClear:(id)sender
{
	hotkeyTmp = -999;
	[grabHotkey setStringValue:@""];
}
- (IBAction)reloadVoiceList:(id)sender
{
    [theMainControl loadVoiceListClearingFirst:YES];
}
- (IBAction)resetRates:(id)sender
{
    [theMainControl resetRates];
    [theMainControl changedRate:defaultRateSlider];
}
-(void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
	[NSEvent removeMonitor:hotkeyEventMonitor];
	[theMainControl setupHotkeys];
}

- (void)showPrefsWindow
{
	[prefsWindow makeKeyAndOrderFront:self];
}


- (IBAction)addButton:(id)sender
{
	[replace addObject:@"find"];
	[replaceWith addObject:@"replace"];
    [caseSensitive addObject:[NSNumber numberWithBool:YES]];
	[theTable reloadData];
	[theTable scrollRowToVisible:[replace count]-1];
	[theTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[replace count]-1] byExtendingSelection:NO];
	[prefs setObject:replace forKey:@"replace"];
	[prefs setObject:replaceWith forKey:@"replaceWith"];
    [prefs setObject:caseSensitive forKey:@"caseSensitive"];
}
- (IBAction)removeButton:(id)sender
{
	void (^deleteEntries)(NSUInteger, BOOL*) = ^(NSUInteger idx, BOOL *stop)
	{
		[replace removeObjectAtIndex:idx];
		[replaceWith removeObjectAtIndex:idx];
        [caseSensitive removeObjectAtIndex:idx];
	};
	[[theTable selectedRowIndexes] enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:deleteEntries];
	[prefs setObject:replace forKey:@"replace"];
	[prefs setObject:replaceWith forKey:@"replaceWith"];
    [prefs setObject:caseSensitive forKey:@"caseSensitive"];
	[theTable reloadData];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [replace count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"Replace"])
		return [replace objectAtIndex:rowIndex];
	else if([[aTableColumn identifier] isEqualToString:@"ReplaceWith"])
		return [replaceWith objectAtIndex:rowIndex];
    else if([[aTableColumn identifier] isEqualToString:@"Case"])
        return [caseSensitive objectAtIndex:rowIndex];
    else return nil;
}
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"Replace"])
	{	
		[replace replaceObjectAtIndex:rowIndex withObject:anObject];
		[prefs setObject:replace forKey:@"replace"];
	}
	else if([[aTableColumn identifier] isEqualToString:@"ReplaceWith"])
	{
		[replaceWith replaceObjectAtIndex:rowIndex withObject:anObject];
		[prefs setObject:replaceWith forKey:@"replaceWith"];
	}
	else if([[aTableColumn identifier] isEqualToString:@"Case"])
	{
		[caseSensitive replaceObjectAtIndex:rowIndex withObject:anObject];
		[prefs setObject:caseSensitive forKey:@"caseSensitive"];
	}
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[buttonRemove setEnabled:(BOOL)[[theTable selectedRowIndexes] count]];
}
@end
