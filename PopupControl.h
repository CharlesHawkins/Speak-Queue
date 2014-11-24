//
//  PopupControl.h
//  Speak Queue
//
//  Created by Charles Hawkins on 1/19/11.
//  Copyright 2011 - 2014 Charles Hawkins.
//
//  Description: Controls the Popup Enqueue popup window.  When MainControl gets some text to enqueue it
//  calls popupWithText:withVoices:atRates:.  This method sets up and displays the popup window.
//  When the user selects a voice, enqueue: is called.  This method closes the window and passes the text
//  (with the selected voice and rate) back to MainConrol via enqueueText:withVoice:atRate, which then enqueues it.
//
//  This class acts as the data source for the popup's NSTableView that displays the list of voices.
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

#ifndef POPUPCONTROL
#define POPUPCONTROL
#import <Cocoa/Cocoa.h>
#import "MainControl.h"

@class MainControl;

@interface PopupControl : NSObject <NSTableViewDataSource>
{
	IBOutlet NSPanel *popupWindow;
	IBOutlet MainControl *theMainControl;
	IBOutlet NSSlider *rateSlider;
	IBOutlet NSTableView *voiceTable;
	NSMutableDictionary *ratesDictionary;
	NSMutableArray *voicesArray;
	NSString *textToEnqueue;
	NSUserDefaults *prefs;
}
- (void)awakeFromNib;
- (void)popupWithText:(NSString*)text withVoices:(NSArray*)voices atRates:(NSMutableDictionary*)rates;
- (IBAction) enqueue:(id)sender;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex;
@end
#endif
