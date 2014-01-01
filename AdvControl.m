//
//  AdvControl.m
//  Speak Queue
//
//  Created by Charles Hawkins on 1/21/11.
//  Copyright 2011 Charles Hawkins. All rights reserved.
//
//  Description: Controls the Script Enqueue popup window.
//

#import "AdvControl.h"


@implementation AdvControl
- (void)awakeFromNib
{
	voicesForSpeakers = [NSMutableDictionary dictionary];
	[advWindow setFloatingPanel:YES];
	[advWindow setBecomesKeyOnlyIfNeeded:YES];
    [advWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
	[theTable setDataSource:self];
	prefs = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
}

- (void)popupWithText:(NSString*)text withVoices:(NSArray*)voicesArray atRates:(NSDictionary*)voiceRates
/* This sets up and displays the popup window.  MainControl calls this when the hotkey is pressed. */
{
	if ([prefs boolForKey:@"popupAtMouse"])
	{
		[advWindow setFrameTopLeftPoint:[NSEvent mouseLocation]];
	}
	if(voices)
		[voices removeAllObjects];
	else
		voices = [NSMutableArray arrayWithCapacity:[voicesArray count]+1];
	[voices addObject:@"(Not a Speaker)"];
	for(NSMenuItem* item in voicesArray)
	{
		[voices addObject:[item title]];
	}
	rates = voiceRates;
	
	/* Parse in the text */
	
	NSArray *lines = [text componentsSeparatedByString:@"\n"];
	parsedLines = [NSMutableArray arrayWithCapacity:[lines count]];
	NSMutableSet *speakersSet = [NSMutableSet set];
	for (NSString *line in lines)
	{
		if([line rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@" \t\n"] invertedSet]].location != NSNotFound)
		{
			NSArray *dividedByColons = [line componentsSeparatedByString:@":"];
			if([dividedByColons count] > 2)
			{	
				NSRange restOfLine = (NSRange){1,[dividedByColons count]-1};
				[parsedLines addObject:[NSArray arrayWithObjects:[dividedByColons objectAtIndex:0],[[dividedByColons subarrayWithRange:restOfLine] componentsJoinedByString:@":"], nil]];
			}
			else if([dividedByColons count] > 0)
				[parsedLines addObject:dividedByColons];
			if([dividedByColons count] > 1)
				[speakersSet addObject:[dividedByColons objectAtIndex:0]];
		}
	}
	speakers = [[NSArray arrayWithObject:@"(Narrator)"] arrayByAddingObjectsFromArray:[speakersSet allObjects]];

	/* Create the voice popup */
	
	NSPopUpButtonCell *voicesCell = [[theTable tableColumnWithIdentifier:@"Voice"] dataCell];
	[voicesCell removeAllItems];
	[voicesCell addItemsWithTitles:voices];

	if(selectedVoices)
		[selectedVoices removeAllObjects];
	else
		selectedVoices = [NSMutableArray arrayWithCapacity:[speakers count]];
	[voicesForSpeakers removeAllObjects];
	for (id i in speakers)
	{	
		[selectedVoices addObject:[NSNumber numberWithInt:1]];
		[voicesForSpeakers setObject:[voices objectAtIndex:1] forKey:i];
	}
	[theTable reloadData];
	[advWindow orderFront:self];
}

- (IBAction)enqueueButton:(id)sender
{
	[advWindow close];
	NSString *lastVoice = [voices objectAtIndex:1];
	for(int i=0; i<[parsedLines count]; i++)
	{
		NSArray *line = [parsedLines objectAtIndex:i];
		NSString *voice;
		if([line count] == 1)
		{
			voice = [voicesForSpeakers objectForKey:@"(Narrator)"];
			if([voice isEqualToString:@"(Not a Speaker)"])
				voice = lastVoice;
		}
		else
		{
			voice = [voicesForSpeakers objectForKey:[line objectAtIndex:0]];
		}
		if([voice isEqualToString:@"(Not a Speaker)"])
		{
			voice = [voicesForSpeakers objectForKey:@"(Narrator)"];
			if([voice isEqualToString:@"(Not a Speaker)"])
				voice = lastVoice;
			line = [NSArray arrayWithObject: [NSString stringWithFormat:@"%@:%@", [line objectAtIndex:0], [line objectAtIndex:1]]];
		}
		NSNumber *rate = [rates objectForKey:voice];
		lastVoice = voice;
		[theMainControl enqueueText:[line lastObject] withVoice:voice atRate:rate];
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [speakers count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"Speaker"])
		return [speakers objectAtIndex:rowIndex];
	else
		return [selectedVoices objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"Voice"])
	{	
		[selectedVoices replaceObjectAtIndex:rowIndex withObject:anObject];
		[voicesForSpeakers setObject:[voices objectAtIndex:[anObject intValue]] forKey:[speakers objectAtIndex:rowIndex]];
	}
}
@end
