//
//  AdvControl.h
//  Speak Queue
//
//  Created by Charles Hawkins on 1/21/11.
//  Copyright 2011 - 2014 Charles Hawkins. All rights reserved.
//
//  Description: Controls the Script Enqueue popup window.  When MainControl gets some text to enqueue
//  it calls popupWithText:withVoices:atRates:.  This method sets up and displays the popup window.
//  When the user clicks "Queue Up" it calls enqueueButton:, which closes the window and passes each line
//  of text (with the selected voices and rate) back to MainControl via enqueueText:withVoice:atRate, which
//  enqueues them.
//
//  This class acts as the data source for the popup's NSTableView that displays the speakers and voices.
//

#import <Cocoa/Cocoa.h>
#import "MainControl.h"

@class MainControl;

@interface AdvControl : NSObject <NSTableViewDataSource> {
	NSMutableArray *parsedLines;	/* Each element is an array for the given line separated into speaker and line */
	NSMutableDictionary *voicesForSpeakers;	/* Maps speakers to voices selected by the user */
	NSMutableArray *voices;
	NSArray *narratorVoices;		/* Voices list that excludes "(Not a Speaker)" */
	NSDictionary *rates;
	NSArray *speakers;				/* For populating the list of speakers */
	NSMutableArray *selectedVoices;
	IBOutlet NSTableView *theTable;
	IBOutlet MainControl *theMainControl;
	IBOutlet NSPanel *advWindow;
	NSUserDefaults *prefs;
}
- (void)awakeFromNib;
- (void)popupWithText:(NSString*)text withVoices:(NSArray*)voicesArray atRates:(NSDictionary*)voicesRates;
- (IBAction)enqueueButton:(id)sender;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
@end
