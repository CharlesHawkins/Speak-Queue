//
//  SpeechQueue.m
//  TalQ
//
//  Created by Charles Hawkins on 8/10/10.
//  Copyright 2010 - 2014 Charles Hawkins. All rights reserved.
//

#import "SpeechQueue.h"


@implementation SpeechQueue

-(void)awakeFromNib {
	prefs = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	arrayLock = [NSLock	new];
	synth = [[NSSpeechSynthesizer new] initWithVoice:nil];
	textQueue = [NSMutableArray arrayWithCapacity:20];
	voicesQueue = [NSMutableArray arrayWithCapacity:20];
	ratesQueue = [NSMutableArray arrayWithCapacity:20];
	stopSpeakingThreads = [[NSThread new] init];
	paused = NO;
	shouldResetOnUnpause = NO;
	shouldKeepQueueItem = NO;
	shouldStartSpeakingOnUnpause = NO;
	[synth setDelegate:self];
}

-(NSArray*)availableVoices {
	return [NSSpeechSynthesizer availableVoices];
}

/* Queue and speaking management methods */
-(int)enqueueText:(NSString*)text withVoice:(NSString*)voice atRate:(NSNumber*) rate{
	[arrayLock lock];
	NSArray *replace;
	NSString *ProcString;
	if([prefs boolForKey:@"pauseAtNewlines"])
    {
		ProcString = [text stringByReplacingOccurrencesOfString:@"\n" withString:@".  \n"];
		ProcString = [ProcString stringByReplacingOccurrencesOfString:@"\".  \n" withString:@"\"  "];
        ProcString = [ProcString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
	else
		ProcString = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	if((replace = [prefs objectForKey:@"replace"]))
	{
		NSArray *replaceWith = [prefs objectForKey:@"replaceWith"];
        NSArray *caseSentitive = [prefs objectForKey:@"caseSensitive"];
		for(int i=0; i<[replace count]; i++)
		{
			ProcString = [ProcString stringByReplacingOccurrencesOfString:[replace objectAtIndex:i] withString:[replaceWith objectAtIndex:i] options:([[caseSentitive objectAtIndex:i] boolValue]?NSLiteralSearch:NSCaseInsensitiveSearch) range:(NSRange){0,[ProcString length]}];
            //ProcString = [ProcString stringByReplacingOccurrencesOfString:[replace objectAtIndex:i] withString:[replaceWith objectAtIndex:i]];
		}
	}
	[textQueue addObject:ProcString];
	[voicesQueue addObject:voice];
	[ratesQueue addObject:rate];
	[theTable reloadData];
	[arrayLock unlock];
	if([textQueue count] == 1)
	{
		[self speakNextQueueItem];
	}
	return 0;
}
-(void)deleteItem
{
    int itemNumber = [theTable selectedRow];
    if(itemNumber == 0)
    {
        [synth stopSpeaking]; /* This causes didFinishSpeaking to be sent; it will handle dequeuing, etc. */
    }
    else
    {
        [arrayLock lock];
        [textQueue removeObjectAtIndex:itemNumber];
        [voicesQueue removeObjectAtIndex:itemNumber];
        [ratesQueue removeObjectAtIndex:itemNumber];
        [arrayLock unlock];
    }
    if(itemNumber >= [textQueue count])
        [theTable deselectAll:self];
    [theTable reloadData];
}

-(void)speakNextQueueItem {
	if ([synth isSpeaking])
	{	
		shouldKeepQueueItem = YES;
		[synth stopSpeaking];
	}
	else if (!paused && [textQueue count] > 0){
		[arrayLock lock];
		[synth setVoice:[theMainControl getIdentifierForVoice:[voicesQueue objectAtIndex:0]]];
		[synth setRate:[[ratesQueue objectAtIndex:0] floatValue]];
		[synth startSpeakingString:[textQueue objectAtIndex:0]]; 
		[theMainControl setStatus:@"Speaking"];
		[arrayLock unlock];
	}
	else if (paused) {
		shouldStartSpeakingOnUnpause = YES;
	}
	else {
		[theMainControl setStatus:@"Idle"];
	}


}

-(void)skipNextQueueItem {
	[synth stopSpeaking];	/* This causes didFinishSpeaking to be sent; it will handle dequeuing, etc. */
}

-(void)pauseSpeaking {
	if ([textQueue count] > 0) {
		[synth pauseSpeakingAtBoundary:NSSpeechImmediateBoundary];
	}
	else {
		shouldStartSpeakingOnUnpause = YES;
	}
	paused = YES;
	[theMainControl setStatus:@"Paused"];
}

-(void)unpauseSpeaking {
	[synth continueSpeaking];
	[theMainControl setStatus:@"Speaking"];
	if (paused && shouldStartSpeakingOnUnpause) {
		paused = NO;
		[self speakNextQueueItem];
		shouldStartSpeakingOnUnpause = NO;
	}
	else {
		paused = NO;
	}
}

- (void)clearQueue {
	[synth stopSpeaking];
	[arrayLock lock];
	[voicesQueue removeAllObjects];
	[ratesQueue removeAllObjects];
	[textQueue removeAllObjects];
	[theTable reloadData];
	[theMainControl setStatus:@"Idle"];
	[arrayLock unlock];
}

-(BOOL)isSpeaking {
	return [synth isSpeaking];
}

-(BOOL)isPaused {
	return paused;
}

/* Methods for NSTableViewDataSource */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [textQueue count];
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger) rowIndex {
	if(rowIndex > [textQueue count])
		return @"Nothing here\n";
	if ([[aTableColumn identifier] isEqualToString:@"Voice"]) {
		return [voicesQueue objectAtIndex:rowIndex];
	}
    if ([[aTableColumn identifier] isEqualToString:@"Rate"]) {
		return [ratesQueue objectAtIndex:rowIndex];
	}
	return [textQueue objectAtIndex:rowIndex];
}

/* Methods for NSSpeechSynthesizerDelegate */
- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)success {
	[NSThread detachNewThreadSelector:@selector(threadedFinishedSpeaking:) toTarget: self withObject:nil];
}

-(void)threadedFinishedSpeaking:(NSObject*)nothing {
	[arrayLock lock];

	if (!shouldKeepQueueItem) {
		if ([textQueue count] > 0)
		{
			[voicesQueue removeObjectAtIndex:0];
			[textQueue removeObjectAtIndex:0];
			[ratesQueue removeObjectAtIndex:0];
			[theTable reloadData];
			
		}
	}
	else {
		shouldKeepQueueItem = NO;
	}
	
	if (!paused && [textQueue count] >0) {
		[synth setVoice:[theMainControl getIdentifierForVoice:[voicesQueue objectAtIndex:0]]];
		[synth setRate:[[ratesQueue objectAtIndex:0] floatValue]];
		[synth startSpeakingString:[textQueue objectAtIndex:0]];
		[theMainControl setStatus:@"Speaking"];
	}
	else if(!paused){
		[theMainControl setStatus:@"Idle"];
	}

	[arrayLock unlock];
}
@end
