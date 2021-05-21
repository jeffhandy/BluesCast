//
//  AudioStreamer.m
//  StreamingAudioPlayer
//
//  Created by Matt Gallagher on 27/09/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
// Modified by Mike Jablonski

#import "AudioStreamer.h"
#ifdef TARGET_OS_IPHONE                
#import <CFNetwork/CFNetwork.h>
#endif

#define PRINTERROR(LABEL)       printf("%s err %4.4s %d\n", LABEL, (char *)&err, (int)err)




#pragma mark CFReadStream Callback Function Prototypes

void ReadStreamCallBack(
						CFReadStreamRef stream,
						CFStreamEventType eventType,
						void* dataIn);

#pragma mark Audio Callback Function Prototypes

void MyAudioQueueOutputCallback(void* inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);
void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);
void MyPropertyListenerProc(    void *                                                  inClientData,
							AudioFileStreamID                               inAudioFileStream,
							AudioFileStreamPropertyID               inPropertyID,
							UInt32 *                                                ioFlags);
void MyPacketsProc(                             void *                                                  inClientData,
				   UInt32                                                  inNumberBytes,
				   UInt32                                                  inNumberPackets,
				   const void *                                    inInputData,
				   AudioStreamPacketDescription    *inPacketDescriptions);
OSStatus MyEnqueueBuffer(AudioStreamer* myData);

#ifdef TARGET_OS_IPHONE                
void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState);
#endif

#pragma mark Audio Callback Function Implementations

//
// MyPropertyListenerProc
//
// Receives notification when the AudioFileStream has audio packets to be
// played. In response, this function creates the AudioQueue, getting it
// ready to begin playback (playback won't begin until audio packets are
// sent to the queue in MyEnqueueBuffer).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// kAudioQueueProperty_IsRunning listening added.
//
void MyPropertyListenerProc(    void *                                                  inClientData,
							AudioFileStreamID                               inAudioFileStream,
							AudioFileStreamPropertyID               inPropertyID,
							UInt32 *                                                ioFlags)
{      
	// this is called by audio file stream when it finds property values
	AudioStreamer* myData = (AudioStreamer*)inClientData;
	OSStatus err = noErr;
	
	switch (inPropertyID) {
		case kAudioFileStreamProperty_ReadyToProducePackets :
		{
			myData->discontinuous = true;
			
			// get the cookie size
			UInt32 cookieSize;
			Boolean writable;
			
			
			// the file stream parser is now ready to produce audio packets.
			// get the stream format.
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if (err) { PRINTERROR("get kAudioFileStreamProperty_DataFormat"); myData->failed = true; break; }
			
			
			// fix for AAC
			
			//
			//
			UInt32 formatListSize;
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, &writable);
			if (!err) {
				//NSLog(@"formatListSize %d\n", formatListSize);
				
				// get the FormatList data
				void* formatListData = calloc(1, formatListSize);
				err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, formatListData);
				if (err) { PRINTERROR("get kAudioFilePropertyFormatList"); free(formatListData); break; }
				
				// Scan through all the supported formats and look for HE AAC
				for (int x = 0; x < formatListSize; x += sizeof(AudioFormatListItem)){
					AudioStreamBasicDescription *pasbd = formatListData + x;
					
					//NSLog(@"rate: %lf  Format:%c%c%c%c  FramesPerPacket:%d  bytesPerFrame:%d ChannelsperFrame:%d\r\n",
						//  pasbd->mSampleRate, (pasbd->mFormatID>>24)&255, (pasbd->mFormatID>>16)&255, (pasbd->mFormatID>>8)&255, (pasbd->mFormatID)&255,
						//  pasbd->mFramesPerPacket, pasbd->mBytesPerFrame, pasbd->mChannelsPerFrame);
					
					if (pasbd->mFormatID == kAudioFormatMPEG4AAC_HE){
						//NSLog(@"Found HE AAC!");
						// HE AAC isn't supported on the simulator for some reason
						if (!TARGET_IPHONE_SIMULATOR){
							//NSLog(@"AAC memcpy");
							memcpy(&asbd, pasbd, sizeof(asbd));
						}
						break;
					}    
				}
				free(formatListData);
			}	
			
			
			
			
			
			
			
			
			
			// AAC+ streams need this
			//asbd.mFormatID = kAudioFormatMPEG4AAC_HE;
			
			// create the audio queue
			err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, myData, NULL, NULL, 0, &myData->audioQueue);
			if (err) { PRINTERROR("AudioQueueNewOutput"); myData->failed = true; break; }
			
			// listen to the "isRunning" property
			err = AudioQueueAddPropertyListener(myData->audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, myData);
			if (err) { PRINTERROR("AudioQueueAddPropertyListener"); myData->failed = true; break; }
			
			// allocate audio queue buffers
			for (unsigned int i = 0; i < kNumAQBufs; ++i) {
				err = AudioQueueAllocateBuffer(myData->audioQueue, kAQBufSize, &myData->audioQueueBuffer[i]);
				if (err) { PRINTERROR("AudioQueueAllocateBuffer"); myData->failed = true; break; }
			}
			
			// get the cookie size
			//UInt32 cookieSize;
			///Boolean writable;
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
			if (err) { PRINTERROR("info kAudioFileStreamProperty_MagicCookieData"); break; }
			
			// get the cookie data
			void* cookieData = calloc(1, cookieSize);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
			if (err) { PRINTERROR("get kAudioFileStreamProperty_MagicCookieData"); free(cookieData); break; }
			
			// set the cookie on the queue.
			err = AudioQueueSetProperty(myData->audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
			free(cookieData);
			if (err) { PRINTERROR("set kAudioQueueProperty_MagicCookie"); break; }
			break;
		}
			
		case kAudioFileStreamProperty_FormatList:
		{
			Boolean outWriteable;
			UInt32 formatListSize;
			
			//NSLog(@"AAC+ stream");
			
			
			// Get the size of the format list
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream,
												 kAudioFileStreamProperty_FormatList, &formatListSize, &outWriteable);
			if (err) { // handle error }
				
				// Get the list of formats itself
				AudioFormatListItem *formatList = malloc(formatListSize);
				err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, formatList);
				if (err) { // handle error }
					
					// Look through the list of formats to find HE-AAC if present
					for (int i = 0;
						 i * sizeof(AudioFormatListItem) < formatListSize;
						 i += sizeof(AudioFormatListItem))
					{
						AudioStreamBasicDescription pasbd = formatList[i].mASBD;
						if (pasbd.mFormatID == kAudioFormatMPEG4AAC_HE)
						{
							// We've found HE-AAC, remember this to tell the audio queue
							// when we construct it.
#if !TARGET_IPHONE_SIMULATOR
							//asbd = pasbd;
#endif
							break;
						}                                
					}
					free(formatList);
				}
			}
		}
				
	}
}



//
// MyPacketsProc
//
// When the AudioStream has packets to be played, this function gets an
// idle audio buffer and copies the audio packets into it. The calls to
// MyEnqueueBuffer won't return until there are buffers available (or the
// playback has been stopped).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
void MyPacketsProc(                             void *                                                  inClientData,
				   UInt32                                                  inNumberBytes,
				   UInt32                                                  inNumberPackets,
				   const void *                                    inInputData,
				   AudioStreamPacketDescription    *inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	AudioStreamer* myData = (AudioStreamer*)inClientData;
	
	// we have successfully read the first packests from the audio stream, so
	// clear the "discontinuous" flag
	myData->discontinuous = false;
	
		
	if(![myData.bufferTimer isValid]) {
	
	    myData.bufferTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:myData selector:@selector(checkAvailableBuffers:)
														userInfo:myData repeats:YES];
		
		//[NSTimer scheduledTimerWithTimeInterval:2 target:myData selector:@selector(failedAlert)
		//							   userInfo:nil repeats:NO];

	}
	
	
	// the following code assumes we're streaming VBR data. for CBR data, the second branch is used.
	if (inPacketDescriptions)
	{
		for (int i = 0; i < inNumberPackets; ++i) {
			SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
			SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
			
			// If the audio was terminated before this point, then
			// exit.
			if (myData->finished)
			{
				return;
			}
			
			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			size_t bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
			if (bufSpaceRemaining < packetSize) {
				MyEnqueueBuffer(myData);
			}
			
			pthread_mutex_lock(&myData->mutex2);
			
			// If the audio was terminated while waiting for a buffer, then
			// exit.
			if (myData->finished)
			{
				pthread_mutex_unlock(&myData->mutex2);
				return;
			}
			
			// copy data to the audio queue buffer
			AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
			memcpy((char*)fillBuf->mAudioData + myData->bytesFilled, (const char*)inInputData + packetOffset, packetSize);
			
			pthread_mutex_unlock(&myData->mutex2);
			
			// fill out packet description
			myData->packetDescs[myData->packetsFilled] = inPacketDescriptions[i];
			myData->packetDescs[myData->packetsFilled].mStartOffset = myData->bytesFilled;
			// keep track of bytes filled and packets filled
			myData->bytesFilled += packetSize;
			myData->bytesToDate += packetSize;
			myData->packetsFilled += 1;
			
			// if that was the last free packet description, then enqueue the buffer.
			size_t packetsDescsRemaining = kAQMaxPacketDescs - myData->packetsFilled;
			if (packetsDescsRemaining == 0) {
				MyEnqueueBuffer(myData);
			}
		}      
	}
	else
	{
		size_t offset = 0;
		while (inNumberBytes)
		{
			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			size_t bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
			if (bufSpaceRemaining < inNumberBytes) {
				MyEnqueueBuffer(myData);
			}
			
			pthread_mutex_lock(&myData->mutex2);
			
			// If the audio was terminated while waiting for a buffer, then
			// exit.
			if (myData->finished)
			{
				pthread_mutex_unlock(&myData->mutex2);
				return;
			}
			
			// copy data to the audio queue buffer
			AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
			bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
			size_t copySize;
			if (bufSpaceRemaining < inNumberBytes)
			{
				copySize = bufSpaceRemaining;
			}
			else
			{
				copySize = inNumberBytes;
			}
			memcpy((char*)fillBuf->mAudioData + myData->bytesFilled, (const char*)(inInputData + offset), copySize);
			
			
			pthread_mutex_unlock(&myData->mutex2);
			
			// keep track of bytes filled and packets filled
			myData->bytesFilled += copySize;
			myData->packetsFilled = 0;
			inNumberBytes -= copySize;
			offset += copySize;
		}
	}
}

//
// MyEnqueueBuffer
//
// Called from MyPacketsProc and connectionDidFinishLoading to pass filled audio
// bufffers (filled by MyPacketsProc) to the AudioQueue for playback. This
// function does not return until a buffer is idle for further filling or
// the AudioQueue is stopped.
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
OSStatus MyEnqueueBuffer(AudioStreamer* myData)
{
	OSStatus err = noErr;
	myData->inuse[myData->fillBufferIndex] = true;          // set in use flag
	
	// enqueue buffer
	AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
	fillBuf->mAudioDataByteSize = myData->bytesFilled;
	
	if (myData->packetsFilled)
	{
		err = AudioQueueEnqueueBuffer(myData->audioQueue, fillBuf, myData->packetsFilled, myData->packetDescs);
	}
	else
	{
		err = AudioQueueEnqueueBuffer(myData->audioQueue, fillBuf, 0, NULL);
	}
	
	if (err) { PRINTERROR("AudioQueueEnqueueBuffer"); myData->failed = true; return err; }   
	
	// start the queue if it has not been started already
	
	//JTH Hack - don't start playing until we've filled at least 5 buffers
	
	//NSLog(@"started is %d", myData->started);
	//NSLog(@"buffer index: %d", myData->fillBufferIndex);
	//if (!myData->started) {  
	if (!myData->started && myData->fillBufferIndex >= 4) {         
		err = AudioQueueStart(myData->audioQueue, NULL);
		if (err) { PRINTERROR("AudioQueueStart"); myData->failed = true; return err; }          
		myData->started = true;
	}
	
	// go to next buffer
	if (++myData->fillBufferIndex >= kNumAQBufs) myData->fillBufferIndex = 0;
	
	myData->bytesFilled = 0;                // reset bytes filled
	myData->packetsFilled = 0;              // reset packets filled
	
	// wait until next buffer is not in use
	pthread_mutex_lock(&myData->mutex);
	while (myData->inuse[myData->fillBufferIndex] && !myData->finished)
	{
		pthread_cond_wait(&myData->cond, &myData->mutex);
	}
	pthread_mutex_unlock(&myData->mutex);
	
	return err;
}


//
// MyFindQueueBuffer
//
// Returns the index of the specified buffer in the audioQueueBuffer array.
//
// This function is unchanged from Apple's example in AudioFileStreamExample.
//
int MyFindQueueBuffer(AudioStreamer* myData, AudioQueueBufferRef inBuffer)
{
	
	//JTH Hack -- let's determine number of free buffers at all times
	
	int buffersInUse = 0;
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (myData->inuse[i] == true) {
			
			buffersInUse++;
		}
	}
	//NSLog(@"buffers Used: %d", buffersInUse);
	
	
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (inBuffer == myData->audioQueueBuffer[i]) {
			//NSLog(@"playing buffer: %d", i);
			return i;
		}
	}
	return -1;
}

//
// MyAudioQueueOutputCallback
//
// Called from the AudioQueue when playback of specific buffers completes. This
// function signals from the AudioQueue thread to the AudioStream thread that
// the buffer is idle and available for copying data.
//
// This function is unchanged from Apple's example in AudioFileStreamExample.
//
void MyAudioQueueOutputCallback(        void*                                   inClientData,
								AudioQueueRef                   inAQ,
								AudioQueueBufferRef             inBuffer)
{
	// this is called by the audio queue when it has finished decoding our data.
	// The buffer is now free to be reused.
	AudioStreamer* myData = (AudioStreamer*)inClientData;
	unsigned int bufIndex = MyFindQueueBuffer(myData, inBuffer);
	
	// signal waiting thread that the buffer is free.
	pthread_mutex_lock(&myData->mutex);
	myData->inuse[bufIndex] = false;
	pthread_cond_signal(&myData->cond);
	pthread_mutex_unlock(&myData->mutex);
}

//
// MyAudioQueueIsRunningCallback
//
// Called from the AudioQueue when playback is started or stopped. This
// information is used to toggle the observable "isPlaying" property and
// set the "finished" flag.
//
void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	AudioStreamer *myData = (AudioStreamer *)inUserData;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (myData.isPlaying)
	{
		myData->finished = true;
		myData.isPlaying = false;
		
		
		//if([myData.bufferTimer isKindOfClass:[NSTimer class]] && [myData.bufferTimer isValid]) 
		//if([myData.bufferTimer isKindOfClass:[NSTimer class]])
		//    [myData.bufferTimer invalidate];
		//if([myData.rateTimer isKindOfClass:[NSTimer class]] && [myData.rateTimer isValid]) 
		//if([myData.rateTimer isKindOfClass:[NSTimer class]]) 
		 //   [myData.rateTimer invalidate];
		//NSLog(@"bufferTimer invalidate!");
		
#ifdef TARGET_OS_IPHONE                
		AudioSessionSetActive(false);
#endif
	}
	else
	{
		myData.isPlaying = true;
		//NSLog(@"bufferTimer start!");
		
		//JTH hack -- start timer thats calls up every 0.5 seconds buffer status
		//myData.bufferTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:myData selector:@selector(checkAvailableBuffers:)
		//							   userInfo:myData repeats:YES];
		
		myData.rateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:myData selector:@selector(checkStreamRate:)
															userInfo:myData repeats:YES];

		
		//
		// Note about this bug avoidance quirk:
		//
		// On cleanup of the AudioQueue thread, on rare occasions, there would
		// be a crash in CFSetContainsValue as a CFRunLoopObserver was getting
		// removed form the CFRunLoop.
		//
		// After lots of testing, it appeared that the audio thread was
		// attempting to remove CFRunLoop observers from the CFRunLoop after the
		// thread had already deallocated the run loop.
		//
		// By creating an NSRunLoop for the AudioQueue thread, it changes the
		// thread destruction order and seems to avoid this crash bug -- or
		// at least I haven't had it since (nasty hard to reproduce error!)
		//
		[NSRunLoop currentRunLoop];
	}
	
	[pool release];
}

#ifdef TARGET_OS_IPHONE                
//
// MyAudioSessionInterruptionListener
//
// Invoked if the audio session is interrupted (like when the phone rings)
//
void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
}
#endif

#pragma mark CFReadStream Callback Function Implementations

//
// ReadStreamCallBack
//
// This is the callback for the CFReadStream from the network connection. This
// is where all network data is passed to the AudioFileStream.
//
// Invoked when an error occurs, the stream ends or we have data to read.
//
void ReadStreamCallBack
(
 CFReadStreamRef stream,
 CFStreamEventType eventType,
 void* dataIn
)
{
	AudioStreamer *myData = (AudioStreamer *)dataIn;
	
	if (eventType == kCFStreamEventErrorOccurred)
	{
		//NSLog(@"kCFStreamEventErrorOccurred");
		//Hack -- turn off event interruption of stream
		myData->failed = YES;
	}
	else if (eventType == kCFStreamEventEndEncountered)
	{
		//NSLog(@"kCFStreamEventEndEncountered");
		if (myData->failed || myData->finished)
		{
			return;
		}
		
		//
		// If there is a partially filled buffer, pass it to the AudioQueue for
		// processing
		//
		if (myData->bytesFilled)
		{
			MyEnqueueBuffer(myData);
		}
		
		
		//
		// If the AudioQueue started, then flush it (to make certain everything
		// sent thus far will be processed) and subsequently stop the queue.
		//
		if (myData->started)
		{
			OSStatus err = AudioQueueFlush(myData->audioQueue);
			if (err) { PRINTERROR("AudioQueueFlush"); return; }
			
			err = AudioQueueStop(myData->audioQueue, false);
			if (err) { PRINTERROR("AudioQueueStop"); return; }
			
			CFReadStreamClose(stream);
			CFRelease(stream);
			myData->stream = nil;
		}
		else
		{
			//
			// If we have reached the end of the file without starting, then we
			// have failed to find any audio in the file. Abort.
			//
			myData->failed = YES;
		}
	}
	else if (eventType == kCFStreamEventHasBytesAvailable)
	{
		//NSLog(@"kCFStreamEventHasBytesAvailable");
		if (myData->failed || myData->finished)
		{
			return;
		}
		
		//
		// Read the bytes from the stream
		//
		UInt8 bytes[kAQBufSize];
		UInt8 bytesNoMetaData[kAQBufSize];
		CFIndex length = CFReadStreamRead(stream, bytes, kAQBufSize);
		int lengthNoMetaData = 0;
		
		if (length == -1)
		{
			myData->failed = YES;
			return;
		}
		
		//
		// Parse the bytes read by sending them through the AudioFileStream
		//
		if (length > 0)
		{
			int streamStart = 0;
			
			// Read the HTTP response and get the meta data interval
			if (myData->metaDataInterval == 0)
			{
				CFHTTPMessageRef myResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
				UInt32 statusCode = CFHTTPMessageGetResponseStatusCode(myResponse);
				
				//CFStringRef myStatusLine = CFHTTPMessageCopyResponseStatusLine(myResponse);
				
				if (statusCode == 200)          // "OK" (this is true even for ICY)
				{
					
					//NSLog(@"************ 200 received!");
					//NSLog(@"myResponse = %@",myResponse);
					
					//myData.foundIcyStart = YES;
					
					// check if this is a ICY 200 OK response
					NSString *icyCheck = [[[NSString alloc] initWithBytes:bytes length:10 encoding:NSUTF8StringEncoding] autorelease];
					if (icyCheck != nil && [icyCheck caseInsensitiveCompare:@"ICY 200 OK"] == NSOrderedSame)
					{
						myData.foundIcyStart = YES;
						//NSLog(@"ICY 200 OK");                          
					}
					else
					{
						
						// Not an ICY response
						//NSString *metaInt;
						NSString *metaInt = (NSString *) CFHTTPMessageCopyHeaderFieldValue(myResponse, CFSTR("Icy-Metaint"));    
						NSString *metaURL = (NSString *) CFHTTPMessageCopyHeaderFieldValue(myResponse, CFSTR("Icy-Url"));
						NSString *metaName = (NSString *) CFHTTPMessageCopyHeaderFieldValue(myResponse, CFSTR("Icy-Name"));
						NSString *metaGenre = (NSString *) CFHTTPMessageCopyHeaderFieldValue(myResponse, CFSTR("Icy-Genre"));
						NSString *metaRate = (NSString *) CFHTTPMessageCopyHeaderFieldValue(myResponse, CFSTR("Icy-Br"));
						
						[myData updateHeaderName:metaName];
						[myData updateHeaderGenre:metaGenre];
						[myData updateHeaderURL:metaURL];
						[myData updateHeaderBitRate:metaRate];
						
						//NSLog(@"myURL = %@",metaURL);
						
						myData->metaDataInterval = [metaInt intValue];
						[metaInt release];
						if (metaInt)
						{
							//NSLog(@"MetaInt: %@", metaInt);
							myData.parsedHeaders = YES;
						}
					}
				}
				else if (statusCode == 302)
				{
					// Redirect!
					myData.redirect = YES;
					//NSLog(@"Redirect to another URL.");
					
					NSString *escapedValue =
					[(NSString *)CFURLCreateStringByAddingPercentEscapes(
																		 nil,
																		 CFHTTPMessageCopyHeaderFieldValue(myResponse, CFSTR("Location")),
																		 NULL,
																		 NULL,
																		 kCFStringEncodingUTF8)
					 autorelease];
					
					myData.url = [NSURL URLWithString:escapedValue];
					myData->failed = YES;
				}
				else
				{
					// Invalid
				}
			}
			
			if (myData.foundIcyStart && !myData.foundIcyEnd)
			{
				char c1 = '\0';
				char c2 = '\0';
				char c3 = '\0';
				char c4 = '\0';
				int lineStart = streamStart;
				while (YES)
				{
					if (streamStart + 3 > length)
					{
						break;
					}
					
					c1 = bytes[streamStart];
					c2 = bytes[streamStart+1];
					c3 = bytes[streamStart+2];
					c4 = bytes[streamStart+3];
					
					if (c1 == '\r' && c2 == '\n')
					{              
						// get the full string
						NSString *fullString = [[[NSString alloc] initWithBytes:bytes length:streamStart encoding:NSUTF8StringEncoding] autorelease];
						
						// get the substring for this line
						NSString *line = [fullString substringWithRange:NSMakeRange(lineStart, (streamStart-lineStart))];
						//NSLog(@"Header Line: %@.", line);
						
						// check if this is icy-metaint & grab other header data
						NSArray *lineItems = [line componentsSeparatedByString:@":"];
						if ([lineItems count] > 1)
						{
							if ([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-metaint"] == NSOrderedSame)
							{
								myData->metaDataInterval = [[lineItems objectAtIndex:1] intValue];
								//NSLog(@"ICY MetaInt: %d", myData->metaDataInterval);
							} else if ([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-name"] == NSOrderedSame) 
							{
								myData.headerName = [[NSString alloc] initWithString: (NSString*)[lineItems objectAtIndex:1]];
								[myData updateHeaderName:myData.headerName];
								
							} else if ([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-genre"] == NSOrderedSame)	
							{
								myData.headerGenre = [[NSString alloc] initWithString: (NSString*)[lineItems objectAtIndex:1]];
								[myData updateHeaderGenre:myData.headerGenre];
								
							} else if ([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-url"] == NSOrderedSame)
							{	
								NSMutableString *temp = [[NSMutableString alloc] initWithString:(NSString*)[lineItems objectAtIndex:1]];
								[temp appendFormat:@":"];
								[temp appendFormat:(NSString*)[lineItems objectAtIndex:2]];
								myData.headerURL = [[NSString alloc] initWithString: temp];
								[myData updateHeaderURL:myData.headerURL];
								[temp release];
							
							} else if ([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-br"] == NSOrderedSame)
							{
								myData.headerBitRate = [[NSString alloc] initWithString: (NSString*)[lineItems objectAtIndex:1]];
								[myData updateHeaderBitRate:myData.headerBitRate];
							}
								
								
						}
						
						// this is the end of a line, the new line starts in 2
						lineStart = streamStart+2; // (c3)
						
						if (c3 == '\r' && c4 == '\n')
						{
							myData.foundIcyEnd = YES;
							break;
						}
					}
					
					streamStart++;
				} // end while
				
				if (myData.foundIcyEnd)
				{
					streamStart = streamStart + 4;
					//NSLog(@"Found End.");  
					myData.parsedHeaders = YES;
				}
			}
			
			if (myData.parsedHeaders)
			{
				// look at each byte
				for (int i=streamStart; i < length; i++)
				{
					// is this a metadata byte?
					if (myData->metaDataBytesRemaining > 0)
					{
						//NSLog(@"meta: %c", bytes[i]);
						[myData.metaDataString appendFormat:@"%c", bytes[i]];
						
						myData->metaDataBytesRemaining -= 1;
						
						if (myData->metaDataBytesRemaining == 0)
						{
							//NSLog(@"MetaData: %@.", myData.metaDataString);
							[myData updateMetaData:myData.metaDataString];
							
							myData->dataBytesRead = 0;
						}
						continue;
					}
					
					// is this the interval byte?
					if (myData->metaDataInterval > 0 && myData->dataBytesRead == myData->metaDataInterval)
					{
						myData->metaDataBytesRemaining = bytes[i] * 16;
						//NSLog(@"Found interval. Meta Length: %d", myData->metaDataBytesRemaining);
						
						[myData.metaDataString setString:@""];
						
						if (myData->metaDataBytesRemaining == 0)
						{
							myData->dataBytesRead = 0;
						}
						else
						{
							//NSLog(@"Found interval. Meta Length: %d", myData->metaDataBytesRemaining);
						}
						
						continue;
					}
					
					// this is a data byte
					myData->dataBytesRead += 1;
					
					// copy the data to the new buffer
					bytesNoMetaData[lengthNoMetaData] = bytes[i];
					lengthNoMetaData += 1;
				} // end for
				
				// pthread_mutex_unlock(&myData->mutexMeta);
			}       // end if parsedHeaders
			
			if (myData->discontinuous)
			{
				/*
				 * SHOUTcast can send the interval byte by itself. In that case lengthNoMetaData is 0, but
				 * the interval byte should not be sent to the audio queue. The check for a metaDataInterval == 0
				 * will make sure that we don't ever send in the interval byte on a stream with metadata
				 */
				
				if (lengthNoMetaData > 0)
				{
					//NSLog(@"Parsing no meta bytes (Discontinuous).");
					OSStatus err = AudioFileStreamParseBytes(myData->audioFileStream, lengthNoMetaData, bytesNoMetaData, kAudioFileStreamParseFlag_Discontinuity);
					if (err) { PRINTERROR("AudioFileStreamParseBytes"); myData->failed = true;}
				}
				else if (myData->metaDataInterval == 0) // make sure this isn't a stream with metadata
				{
					//NSLog(@"Parsing normal bytes (Discontinuous).");
					OSStatus err = AudioFileStreamParseBytes(myData->audioFileStream, length, bytes, kAudioFileStreamParseFlag_Discontinuity);
					if (err) { PRINTERROR("AudioFileStreamParseBytes"); myData->failed = true;}                                    
				}
			}
			else
			{
				if (lengthNoMetaData > 0)
				{
					//NSLog(@"Parsing no meta bytes.");
					OSStatus err = AudioFileStreamParseBytes(myData->audioFileStream, lengthNoMetaData, bytesNoMetaData, 0);
					if (err) { PRINTERROR("AudioFileStreamParseBytes"); myData->failed = true; }                                    
				}
				else if (myData->metaDataInterval == 0) // make sure this isn't a stream with metadata
				{
					//NSLog(@"Parsing normal bytes.");
					OSStatus err = AudioFileStreamParseBytes(myData->audioFileStream, length, bytes, 0);
					if (err) { PRINTERROR("AudioFileStreamParseBytes"); myData->failed = true; }
				}
			} // end discontinuous
			
		} // end if length > 0
		
	} // end kCFStreamEventHasBytesAvailable
}


@implementation AudioStreamer

@synthesize url;
@synthesize isPlaying;
@synthesize redirect;
@synthesize foundIcyStart;
@synthesize foundIcyEnd;
@synthesize parsedHeaders;
@synthesize metaDataString;
@synthesize headerName;
@synthesize headerGenre;
@synthesize headerURL;
@synthesize headerBitRate;
@synthesize delegate;
@synthesize didUpdateMetaDataSelector;
@synthesize didErrorSelector;
@synthesize didRedirectSelector;

@synthesize didUpdateHeaderNameSelector;
@synthesize didUpdateHeaderGenreSelector;
@synthesize didUpdateHeaderURLSelector;
@synthesize didUpdateHeaderBitRateSelector;
@synthesize bufferStatusSelector;

@synthesize audioQueue;
@synthesize bufferTimer, rateTimer, percentBuffersUsed;

//@synthesize audioQueue;

//
// initWithURL
//
// Init method for the object.
//
- (id)initWithURL:(NSURL *)newUrl
{
	self = [super init];
	if (self != nil)
	{
		url = [newUrl retain];
		metaDataString = [[NSMutableString alloc] initWithString:@""];
		
		didUpdateMetaDataSelector = @selector(metaDataUpdated:);
		
		didUpdateHeaderNameSelector = @selector(headerNameUpdated:);
		didUpdateHeaderGenreSelector = @selector(headerGenreUpdated:);
		didUpdateHeaderURLSelector = @selector(headerURLUpdated:);
		didUpdateHeaderBitRateSelector = @selector(headerBitRateUpdated:);
		
		didErrorSelector = @selector(streamError);
		didRedirectSelector = @selector(streamRedirect:);
		
		bufferStatusSelector = @selector(bufferStatus:);
		delegate = nil;
		
		rateReadingCount = 0;
		averageStreamingRate = 0;
	}
	return self;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[url release];
	[metaDataString release];
	[headerName release];
	[headerGenre release];
	[headerURL release];
	[headerBitRate release];
	[super dealloc];
}

//
// checkBuffers
//
// counst number of available buffers
//

-(void) checkAvailableBuffers: (NSTimer *) timer
{
	
	//AudioStreamer* myData = [timer userinfo];
	
	//JTH Hack -- let's determine number of free buffers at all times
	
	float buffersInUse = 0;
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (self->inuse[i] == true) {
			
			buffersInUse++;
		}
	}
	
	percentBuffersUsed = (float) (buffersInUse / kNumAQBufs);
	NSNumber *buffersPercentNumber = [[NSNumber alloc] initWithFloat:percentBuffersUsed];
	[self updateBufferStatus:buffersPercentNumber];
	[buffersPercentNumber release];
	
	//return buffersInUse;
	//NSLog(@"@@@@@ buffers Used: %f", percentBuffersUsed);
	
}

-(void) checkStreamRate: (NSTimer *) timer
{
	
	//AudioStreamer* myData = [timer userinfo];
	
	//JTH Hack -- let's determine number of free buffers at all times
	
	//NSLog(@"bytes downloaded: %d", self->bytesToDate);
	int secs = 3;
	
	unsigned int rate = ((self->bytesToDate / secs) * 8) / 1024;
	//NSLog(@"stream rate (kbps): %d", rate);
	
	
	
	self->rateReadingCount++;
	
	//calculate average rate
	// we'll skip first 2 readings because they seem to be inaccurate with ntwok buffering
/*	if(self->rateReadingCount > 2 ) {
		
		
		// self->rateReadingCount -2 + 1 - ("-2" is because we skip first two readings)
		
		float newAverageRate = ((self->averageStreamingRate * (self->rateReadingCount - 3)) + rate) / (self->rateReadingCount -2);
		self->averageStreamingRate = newAverageRate;
		//NSLog(@"AVG stream rate (kbps): %f", newAverageRate);
		
		int newAverageRateInt = newAverageRate;
		
		//if(rate < (0.9 * [headerBitRate floatValue]) && self->percentBuffersUsed < 0.1) {
		if(rate < 200) {
		
            //NSNumber *rateParsed = [NSNumberFormatter numberFromString:headerBitRate];
		    NSString* msg =[[NSString alloc] initWithFormat: 
						@"Your average download rate is %d (kbps).  This blues cast needs a speed of at least %d (kbps).  Try a station with lower rate.",
						newAverageRateInt, [headerBitRate intValue]];
		    //[rateTimer invalidate];
		    //[bufferTimer invalidate];
		AlertRun* alert = [[AlertRun alloc] initWithTitle:@"Connection Too Slow" message:msg delegate:self cancelButtonTitle:@"OK" callBack:@selector(dataFailed)];
		//AlertRun* alert = [[AlertRun alloc] initWithTitle:@"Connecion Too Slow" message:msg delegate:self cancelButtonTitle:@"OK" callBack:nil];

		    [alert show];
		    [msg release];
		    [alert release];
		}
		
				
	}*/
		
	self->bytesToDate = 0;
	
	
	
	
	/*float buffersInUse = 0;
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (self->inuse[i] == true) {
			
			buffersInUse++;
		}
	}
	
	float percentBuffersUsed = (float) (buffersInUse / kNumAQBufs);
	NSNumber *buffersPercentNumber = [[NSNumber alloc] initWithFloat:percentBuffersUsed];
	[self updateBufferStatus:buffersPercentNumber];
	[buffersPercentNumber release];*/
	
	//return buffersInUse;
	//NSLog(@"@@@@@ buffers Used: %f", percentBuffersUsed);
	
}

/*-(void) failedAlert  {
	NSString* msg =[[NSString alloc] initWithFormat: 
					@"Your average download rate is %d (kbps).  This blues cast needs a speed of at least %d (kbps).  Try a station with lower rate.",
					50, 100];
	//[rateTimer invalidate];
	//[bufferTimer invalidate];
	AlertRun* alert = [[AlertRun alloc] initWithTitle:@"Connection Too Slow" message:msg delegate:self cancelButtonTitle:@"OK" callBack:@selector(dataFailed)];
	//AlertRun* alert = [[AlertRun alloc] initWithTitle:@"Connecion Too Slow" message:msg delegate:self cancelButtonTitle:@"OK" callBack:nil];

	[alert show];
	[msg release];
	[alert release];
}*/


-(void) dataFailed {
	
	NSLog(@"dataFailed!");
	
	//self->failed = true;
}

/*- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	NSLog(@"clicked! -1");
	
	if (buttonIndex == [alertView cancelButtonIndex])
	{
		NSLog(@"clicked! 0");
		
		
		
		SEL mySelector = [(AlertRun*)alertView callBack];
		//SEL mySelector = [UIAlertView callBack];
		
		
		if(mySelector == nil) return;
		
		
		// create a signature from the selector
		NSMethodSignature* sig = nil;
		sig = [[self class] instanceMethodSignatureForSelector:mySelector];
		NSLog(@"clicked! 1");
		
		NSInvocation*  myInvocation = nil;
		myInvocation = [NSInvocation invocationWithMethodSignature:sig];
		NSLog(@"clicked! 2");
		[myInvocation setTarget:self];
		[myInvocation setSelector:mySelector];
		NSLog(@"clicked! 3");
		[myInvocation invoke];
		NSLog(@"clicked! 4");
		
	} else {
		
		//quit game
		exit(0);
		
	}
}*/



//
// startInternal
//
// This is the start method for the AudioStream thread. This thread is created
// because it will be blocked when there are no audio buffers idle (and ready
// to receive audio data).
//
// Activity in this thread:
//      - Creation and cleanup of all AudioFileStream and AudioQueue objects
//      - Receives data from the CFReadStream
//      - AudioFileStream processing
//      - Copying of data from AudioFileStream into audio buffers
//  - Stopping of the thread because of end-of-file
//      - Stopping due to error or failure
//
// Activity *not* in this thread:
//      - AudioQueue playback and notifications (happens in AudioQueue thread)
//  - Actual download of NSURLConnection data (NSURLConnection's thread)
//      - Creation of the AudioStreamer (other, likely "main" thread)
//      - Invocation of -start method (other, likely "main" thread)
//      - User/manual invocation of -stop (other, likely "main" thread)
//
// This method contains bits of the "main" function from Apple's example in
// AudioFileStreamExample.
//
- (void)startInternal
{
	//
	// Retains "self". This means that we can't be deleted while playback is
	// using our buffers. It also means that releasing an AudioStreamer while
	// it is playing won't stop playback. This is a bit weird but, oh well.
	//
	[self retain];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// allocate a buffer for XML parser
	currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
	locationsArray = [[NSMutableArray alloc] init];
	
#ifdef TARGET_OS_IPHONE                
	//
	// Set the audio session category so that we continue to play if the
	// iPhone/iPod auto-locks.
	//
	AudioSessionInitialize (
							NULL,                          // 'NULL' to use the default (main) run loop
							NULL,                          // 'NULL' to use the default run loop mode
							MyAudioSessionInterruptionListener,  // a reference to your interruption callback
							self                       // data to pass to your interruption listener callback
							);
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (
							 kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory
							 );
	AudioSessionSetActive(true);
#endif
	
	//
	// Attempt to guess the file type from the URL. Reading the MIME type
	// from the CFReadStream would be a better approach since lots of
	// URL's don't have the right extension.
	//
	// If you have a fixed file-type, you may want to hardcode this.
	//
	AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
	NSString *fileExtension = [[url path] pathExtension];
	if ([fileExtension isEqual:@"mp3"])
	{
		fileTypeHint = kAudioFileMP3Type;
	}
	else if ([fileExtension isEqual:@"wav"])
	{
		fileTypeHint = kAudioFileWAVEType;
	}
	else if ([fileExtension isEqual:@"aifc"])
	{
		fileTypeHint = kAudioFileAIFCType;
	}
	else if ([fileExtension isEqual:@"aiff"])
	{
		fileTypeHint = kAudioFileAIFFType;
	}
	else if ([fileExtension isEqual:@"m4a"])
	{
		fileTypeHint = kAudioFileM4AType;
	}
	else if ([fileExtension isEqual:@"mp4"])
	{
		fileTypeHint = kAudioFileMPEG4Type;
	}
	else if ([fileExtension isEqual:@"caf"])
	{
		fileTypeHint = kAudioFileCAFType;
	}
	else if ([fileExtension isEqual:@"aac"])
	{
		fileTypeHint = kAudioFileAAC_ADTSType;
	}
	
	// initialize a mutex and condition so that we can block on buffers in use.
	pthread_mutex_init(&mutex, NULL);
	pthread_cond_init(&cond, NULL);
	pthread_mutex_init(&mutex2, NULL);
	
	pthread_mutex_init(&mutexMeta, NULL);
	dataBytesRead = 0;
	
	// create an audio file stream parser
	OSStatus err = AudioFileStreamOpen(self, MyPropertyListenerProc, MyPacketsProc,
									   fileTypeHint, &audioFileStream);
	if (err) { PRINTERROR("AudioFileStreamOpen"); goto cleanup; }
	
	/************************************************************/
	// If we have a URL with an ".m3u" or ".xspf" suffix,  we need to first
	// 1) request file
	// 2) parse
	// 3) use one of multiple listed URLs and pass to our CFHTTPMessageCreateRequest() method
	
	NSString *urlString = [url absoluteString];
	
	
	/************************************************************/
	// handle .m3u files
	/************************************************************/
	if([urlString hasSuffix: @"m3u"]) {
	
		//NSLog(@"Has M3U suffix!");
		
		NSError *err = [[[NSError alloc] init] autorelease];
		NSString *myTxtFile = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
		if(err.code != 0) {
			NSLog(@"Could not request M3U file!");
		} else {
			//NSLog(@"MSU contents: %@", myTxtFile);
			
			NSArray *lines = [myTxtFile componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			
			NSString *urlLine = [lines objectAtIndex:0];
			//NSLog(@"urlLine: %@", urlLine);
			
			NSString *escapedValue =
			[(NSString *)CFURLCreateStringByAddingPercentEscapes(
																 nil,
																 (CFStringRef)urlLine,
																 NULL,
																 NULL,
																 kCFStringEncodingUTF8)
			 autorelease];
			
			url = [NSURL URLWithString:escapedValue];
			
		}
	}
	
	/************************************************************/
	// handle .xspf files
	/************************************************************/
	
	if([urlString hasSuffix: @"xspf"]) {
		
		//NSLog(@"Has XSPF suffix!");
		
		NSXMLParser *addressParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		// Deliberately ignore the error: with most HTML it will be filled with
		// numerous "tidy" warnings.
		[addressParser setDelegate:self];
		[addressParser setShouldResolveExternalEntities:YES];
		int success = [addressParser parse];
		if(success) {
			NSLog(@"parse success");
			
		} else {
			NSLog(@"parse failed");
			
		}
		
		NSString *urlLine =[locationsArray objectAtIndex:0];

		//NSLog(@"urlLine: %@", urlLine);
		
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)urlLine,
															 NULL,
															 NULL,
															 kCFStringEncodingUTF8)
		 autorelease];
		
		url = [NSURL URLWithString:escapedValue];
	
	}

	
	
	//
	// Create the GET request
	//
	CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET", (CFURLRef)url, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Icy-MetaData"), CFSTR("1"));
	CFHTTPMessageSetHeaderFieldValue(message, CFSTR("User-Agent"), (CFStringRef)@"BluesCast");
	
	
	stream = CFReadStreamCreateForHTTPRequest(NULL, message);
	CFRelease(message);
	if (!CFReadStreamOpen(stream))
	{
		CFRelease(stream);
		goto cleanup;
    }
	
	//
	// Set our callback function to receive the data
	//
	CFStreamClientContext context = {0, self, NULL, NULL, NULL};
	CFReadStreamSetClient(
						  stream,
						  kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
						  ReadStreamCallBack,
						  &context);
	CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	
	//
	// Process the run loop until playback is finished or failed.
	//
	do
	{
		CFRunLoopRunInMode(
						   kCFRunLoopDefaultMode,
						   0.25,
						   false);
		
		if (failed)
		{
			[self stop];
			
#ifdef TARGET_OS_IPHONE
			/*
			 UIAlertView *alert =
			 [[UIAlertView alloc]
			 initWithTitle:NSLocalizedStringFromTable(@"Audio Error", @"Errors", nil)
			 message:NSLocalizedStringFromTable(@"Attempt to play streaming audio failed.", @"Errors", nil)
			 delegate:self
			 cancelButtonTitle:@"OK"
			 otherButtonTitles: nil];
			 [alert
			 performSelector:@selector(show)
			 onThread:[NSThread mainThread]
			 withObject:nil
			 waitUntilDone:YES];
			 [alert release];
			 */
			if (redirect)
			{
				[self redirectStreamError:url];
			}
			else
			{
				[self audioStreamerError];
			}
#else
			NSAlert *alert =
			[NSAlert
			 alertWithMessageText:NSLocalizedString(@"Audio Error", @"")
			 defaultButton:NSLocalizedString(@"OK", @"")
			 alternateButton:nil
			 otherButton:nil
			 informativeTextWithFormat:@"Attempt to play streaming audio failed."];
			[alert
			 performSelector:@selector(runModal)
			 onThread:[NSThread mainThread]
			 withObject:nil waitUntilDone:NO];
#endif
			
			break;
		}
	} while (isPlaying || !finished);
	
cleanup:
	
	
	//
	// Cleanup the read stream if it is still open
	//
	if (stream)
	{
		CFReadStreamClose(stream);
        CFRelease(stream);
		stream = nil;
	}
	
	//
	// Close the audio file strea,
	//
	err = AudioFileStreamClose(audioFileStream);
	if (err) { PRINTERROR("AudioFileStreamClose"); goto cleanup; }
	
	//
	// Dispose of the Audio Queue
	//
	if (started)
	{
		err = AudioQueueDispose(audioQueue, true);
		if (err) { PRINTERROR("AudioQueueDispose"); goto cleanup; }
		
	}
	
	[pool release];
	[self release];
}

// Subclasses can override this method to perform handling in the same thread
// If not overidden, it will call the didUpdateMetaDataSelector on the delegate (by default metaDataUpdated:)`
- (void)updateMetaData:(NSString *)metaData
{
	
	//NSLog(@"calling updateMetaData!\n");
	
	if (didUpdateMetaDataSelector && [delegate respondsToSelector:didUpdateMetaDataSelector]) {
		
		
		[delegate performSelectorOnMainThread:didUpdateMetaDataSelector withObject:metaData waitUntilDone:YES];        
	}
}

- (void)updateHeaderName:(NSString *)data
{
	
	if (didUpdateHeaderNameSelector && [delegate respondsToSelector:didUpdateHeaderNameSelector]) {
		
		
		[delegate performSelectorOnMainThread:didUpdateHeaderNameSelector withObject:data waitUntilDone:YES];        
	}
}

- (void)updateHeaderGenre:(NSString *)data
{
	
	if (didUpdateHeaderGenreSelector && [delegate respondsToSelector:didUpdateHeaderGenreSelector]) {
		
		[delegate performSelectorOnMainThread:didUpdateHeaderGenreSelector withObject:data waitUntilDone:YES];        
	}
}

- (void)updateHeaderURL:(NSString *)data
{
	
	if (didUpdateHeaderURLSelector && [delegate respondsToSelector:didUpdateHeaderURLSelector]) {
		
		[delegate performSelectorOnMainThread:didUpdateHeaderURLSelector withObject:data waitUntilDone:YES];        
	}
}

- (void)updateHeaderBitRate:(NSString *)data
{
	
	if (didUpdateHeaderBitRateSelector && [delegate respondsToSelector:didUpdateHeaderBitRateSelector]) {
			
		[delegate performSelectorOnMainThread:didUpdateHeaderBitRateSelector withObject:data waitUntilDone:YES];        
	}
}

- (void)updateBufferStatus:(NSNumber *)buffersPercent
{
	
	if (bufferStatusSelector && [delegate respondsToSelector:bufferStatusSelector]) {
		
		[delegate performSelectorOnMainThread:bufferStatusSelector withObject:buffersPercent waitUntilDone:YES];        
	}
}



- (void)audioStreamerError
{
	
	NSLog(@"audioStreamerError called!");
	
	[self updateBufferStatus:0];
	
	if (didErrorSelector && [delegate respondsToSelector:didErrorSelector]) {
		[delegate performSelectorOnMainThread:didErrorSelector withObject:nil waitUntilDone:YES];
	}
}

- (void)redirectStreamError:(NSURL*)redirectURL;
{
	if (didRedirectSelector && [delegate respondsToSelector:didRedirectSelector]) {
		[delegate performSelectorOnMainThread:didRedirectSelector withObject:redirectURL waitUntilDone:YES];
	}
}

//
// start
//
// Calls startInternal in a new thread.
//
- (void)start
{
	[NSThread detachNewThreadSelector:@selector(startInternal) toTarget:self withObject:nil];
}

//
// stop
//
// This method can be called to stop downloading/playback before it completes.
// It is automatically called when an error occurs.
//
// If playback has not started before this method is called, it will toggle the
// "isPlaying" property so that it is guaranteed to transition to true and
// back to false
//
- (void)stop
{
	//NSLog(@"AudioStreamer stop.");
	if (stream)
	{
		CFReadStreamClose(stream);
        CFRelease(stream);
		stream = nil;
		
		//NSLog(@"AudioStreamer closed stream.");
		if (finished)
		{
			return;
		}
		
		if (started)
		{
			//
			// Set finished to true *before* we call stop. This is to handle our
			// third thread...
			//      - This method is called from main (UI) thread
			//      - The AudioQueue thread (which owns the AudioQueue buffers nad
			//              will delete them as soon as we call AudioQueueStop)
			//      - URL connection thread is copying data from AudioStream to
			//              AudioQueue buffer
			// We set this flag to tell the URL connection thread to stop
			// copying.
			//
			pthread_mutex_lock(&mutex2);
			finished = true;
			
			OSStatus err = AudioQueueStop(audioQueue, true);
			if (err) { PRINTERROR("AudioQueueStop"); }
			pthread_mutex_unlock(&mutex2);
			
			pthread_mutex_lock(&mutex);
			pthread_cond_signal(&cond);
			pthread_mutex_unlock(&mutex);
			
			//NSLog(@"AudioStreamer stopped queue.");
		}
		else
		{
			self.isPlaying = true;
			self.isPlaying = false;
			finished = true;
		}
	}
}

// Don't need tart of element parse
//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//NSLog(@"calling parser");
	
    if ( [elementName isEqualToString:@"location"]) {
		
		//NSLog(@"currentStringValue = %@", currentStringValue);
		//NSString *tmp = [currentStringValue getString];
		NSString *tmp = [[NSString alloc] initWithString: currentStringValue];
		[locationsArray addObject: tmp];
		[tmp release];
		
        return;
		
    }
	
		
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	[currentStringValue setString: string];
   	
	//NSLog(@"found chars = %@", currentStringValue );
	
}

@end






