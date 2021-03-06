//
//  SpeechQueue.h
//  TalQ
//
//  Created by Charles Hawkins on 8/10/10.
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

#ifndef SPEECHQUEUE
#define SPEECHQUEUE
#import <Cocoa/Cocoa.h>
#import "MainControl.h"

@class MainControl;

@interface SpeechQueue : NSObject <NSTableViewDataSource, NSSpeechSynthesizerDelegate> {
	NSMutableArray *textQueue;
	NSMutableArray *voicesQueue;
	NSMutableArray *ratesQueue;
	NSSpeechSynthesizer *synth;
	IBOutlet NSTableView *theTable;
	IBOutlet MainControl *theMainControl;
	BOOL paused;
	BOOL shouldResetOnUnpause;
	BOOL shouldKeepQueueItem;
	BOOL shouldStartSpeakingOnUnpause;
	NSThread *stopSpeakingThreads;
	NSLock *arrayLock;	/* For thread safety while modifying the arrays */
	NSUserDefaults *prefs;
	NSURL *saveURL;
}
-(void)awakeFromNib;	/* inits the synth and the arrays */
-(NSArray*)availableVoices;	/* gets a list of available voices */

/* Queue and speaking management methods */
-(int)enqueueText:(NSString*)theText withVoice:(NSString*)theVoice atRate:(NSNumber*)rate;	/* Adds text to the speech queue with voice */
-(void)deleteItem;
-(void)speakNextQueueItem; /* (Re)starts speaking first item in the queue.  Does not unpause */
-(void)skipNextQueueItem;	/* Stops speaking first item in queue and removes it.  Does not unpause */
-(void)pauseSpeaking;	/* Pauses speech */
-(void)unpauseSpeaking;	/* Continue paused speaking */
-(void)clearQueue;
-(BOOL)isSpeaking;	/* Currently speaking.  Should be true if there are items in the queue and it is not paused */
-(BOOL)isPaused;	/* Speaking is paused.  Will not return true if unpaused but not speaking due to empty queue */

/* Methods for NSTableViewDataSource */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex;

/* Methods for NSSpeechSynthesizerDelegate */
- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)success;

-(void)threadedFinishedSpeaking:(NSObject*)nothing;

@end
#endif