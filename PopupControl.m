//
//  PopupControl.m
//  Speak Queue
//
//  Created by Charles Hawkins on 1/19/11.
//  Copyright 2011 Charles Hawkins. All rights reserved.
//
//  Description: Controls the Popup Enqueue popup window.
//

#import "PopupControl.h"

@implementation PopupControl
- (void)awakeFromNib
{
	voicesArray = [NSMutableArray array];
	[rateSlider setMinValue:90.0];
	[rateSlider setMaxValue:360.0];
	[rateSlider setFloatValue:[[prefs objectForKey:@"DefaultRate"] floatValue]];
	[voiceTable setDataSource:self];
	[popupWindow setFloatingPanel:YES];
	[popupWindow setBecomesKeyOnlyIfNeeded:YES];
    [popupWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
	prefs = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
}

- (void)popupWithText:(NSString*)text withVoices:(NSArray*)voices atRates:(NSMutableDictionary*)rates
{
	textToEnqueue = text;
	if ([prefs boolForKey:@"popupAtMouse"])
	{
		[popupWindow setFrameTopLeftPoint:[NSEvent mouseLocation]];
	}
	[voicesArray removeAllObjects];
	for(NSMenuItem* item in voices)
	{
		[voicesArray addObject:[item title]];
	}
	ratesDictionary = rates;
	[voiceTable reloadData];
	[voiceTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	[voiceTable scrollToBeginningOfDocument:self];
	[popupWindow orderFront:self];
}

- (IBAction) enqueue:(id)sender
{
    if([[prefs objectForKey:@"oneClick"] boolValue] || [sender tag] == 2)
    {
        [popupWindow close];

        NSNumber *rate = [prefs boolForKey:@"PopupRateSlider"]?[NSNumber numberWithFloat:[rateSlider floatValue]]:[ratesDictionary objectForKey:[voicesArray objectAtIndex:[voiceTable selectedRow]]];
        NSLog(@"%@\n%@\n%@\n", [prefs objectForKey:@"PopupRateSlider"], rate, [ratesDictionary objectForKey:[voicesArray objectAtIndex:[voiceTable selectedRow]]]);
        [theMainControl enqueueText:textToEnqueue withVoice:[voicesArray objectAtIndex:[voiceTable selectedRow]] atRate:rate];
	}
    else
    {
        NSNumber *rate = [ratesDictionary objectForKey:[voicesArray objectAtIndex:[voiceTable selectedRow]]];
        [rateSlider setFloatValue:rate?[rate floatValue]:[[prefs objectForKey:@"DefaultRate"] floatValue]];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [voicesArray count];
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex
{
	return [voicesArray objectAtIndex:rowIndex];
}
@end
