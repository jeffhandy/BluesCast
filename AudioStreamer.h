//
//  AudioStreamer.h
//  StreamingAudioPlayer
//
//  Created by Matt Gallagher on 27/09/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
// Modified by Mike Jablonski

#ifdef TARGET_OS_IPHONE                 
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif TARGET_OS_IPHONE                 

#include <pthread.h>
#include <AudioToolbox/AudioToolbox.h>

//#include "AlertRun.h"

#define kNumAQBufs 10                                                    // number of audio queue buffers we allocate
#define kAQBufSize 32 * 1024            // number of bytes in each audio queue buffer
#define kAQMaxPacketDescs 512           // number of packet descriptions in our array

//NSString * const ASStatusChangedNotification;

@interface AudioStreamer : NSObject
{
    
	id delegate;
	
	// called on the delegate when the metadata string is updated
	SEL didUpdateMetaDataSelector;
	
	// called on the delegate when the header NAME string is updated
	SEL didUpdateHeaderNameSelector;
	
	// called on the delegate when the header GENRE string is updated
	SEL didUpdateHeaderGenreSelector;
	
	// called on the delegate when the header URL string is updated
	SEL didUpdateHeaderURLSelector;
	
	// called on the delegate when the header BITRATE string is updated
	SEL didUpdateHeaderBitRateSelector;
	
	// called on the delegate when an error happens
	SEL didErrorSelector;
	
	// called on the delegate when we receive a 302 redirect
	SEL didRedirectSelector;
	
	// called on the delegate when we want to update buffer count status
	SEL bufferStatusSelector;
	
	NSURL *url;
	BOOL isPlaying;
	BOOL redirect;
	BOOL foundIcyStart;
	BOOL foundIcyEnd;
	BOOL parsedHeaders;
	
	NSMutableString *metaDataString;                        // the metaDataString
	NSString *headerName;                        // the parsed Header name
	NSString *headerGenre;                        // the parsed Header genre
	NSString *headerURL;                        // the parsed Header URL
	NSString *headerBitRate;                       // the parsed Header bitrate
	
@public
	AudioFileStreamID audioFileStream;              // the audio file stream parser
	
	AudioQueueRef audioQueue;                                                                                                                               // the audio queue
	AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];               // audio queue buffers
	
	AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];    // packet descriptions for enqueuing audio
	
	unsigned int fillBufferIndex;           // the index of the audioQueueBuffer that is being filled
	size_t bytesFilled;                                                     // how many bytes have been filled
	size_t packetsFilled;                                           // how many packets have been filled
	size_t bytesToDate;                                                     // how many bytes have been filled since stream start
	
	unsigned int metaDataInterval;                                  // how many data bytes between meta data
	unsigned int metaDataBytesRemaining;    // how many bytes of metadata remain to be read
	unsigned int dataBytesRead;                                                     // how many bytes of data have been read
	
	bool inuse[kNumAQBufs];                 // flags to indicate that a buffer is still in use
	bool started;                                                                   // flag to indicate that the queue has been started
	bool failed;                                                                    // flag to indicate an error occurred
	bool finished;                                                          // flag to inidicate that termination is requested
	// the audio queue is not necessarily complete until
	// isPlaying is also false.
	bool discontinuous;     // flag to trigger bug-avoidance
	
	pthread_mutex_t mutex;                  // a mutex to protect the inuse flags
	pthread_cond_t cond;                            // a condition varable for handling the inuse flags
	pthread_mutex_t mutex2;         // a mutex to protect the AudioQueue buffer     
	pthread_mutex_t mutexMeta;
	
	CFReadStreamRef stream;
	NSTimer *bufferTimer;
	NSTimer *rateTimer;
	
	int rateReadingCount;
	float averageStreamingRate;
	float percentBuffersUsed;
	
	// XML parser vars
	NSMutableArray *locationsArray;
	NSMutableString *currentStringValue;
	
}

@property (nonatomic, retain) NSURL *url;
@property BOOL isPlaying;
@property BOOL redirect;
@property BOOL foundIcyStart;
@property BOOL foundIcyEnd;
@property BOOL parsedHeaders;
@property (nonatomic, copy) NSMutableString *metaDataString;
@property (nonatomic, copy) NSString *headerName;
@property (nonatomic, copy) NSString *headerGenre;
@property (nonatomic, copy) NSString *headerURL;
@property (nonatomic, copy) NSString *headerBitRate;
@property (assign) id delegate;
@property (assign) SEL didUpdateMetaDataSelector;
@property (assign) SEL didErrorSelector;
@property (assign) SEL didRedirectSelector;

@property (assign) SEL didUpdateHeaderNameSelector;
@property (assign) SEL didUpdateHeaderGenreSelector;
@property (assign) SEL didUpdateHeaderURLSelector;
@property (assign) SEL didUpdateHeaderBitRateSelector;
@property (assign) SEL bufferStatusSelector;

@property (nonatomic, assign) AudioQueueRef audioQueue;
@property (nonatomic, assign) NSTimer *bufferTimer;
@property (nonatomic, assign) NSTimer *rateTimer;
@property (readwrite) int rateReadingCount;
@property (readwrite) float averageStreamingRate;
@property (readwrite) float percentBuffersUsed;




- (id)initWithURL:(NSURL *)newURL;
- (void)start;
- (void)stop;

// Called when the metadata is updated - defaults to: @selector(metaDataUpdated:)
- (void)updateMetaData:(NSString *)metaData;

// Called when the header NAME is updated - defaults to: @selector(headerNameUpdated:)
- (void)updateHeaderName:(NSString *)data;

// Called when the header GENRE is updated - defaults to: @selector(headerGenreUpdated:)
- (void)updateHeaderGenre:(NSString *)data;

// Called when the header URL is updated - defaults to: @selector(headerURLUpdated:)
- (void)updateHeaderURL:(NSString *)data;

// Called when the header BITRATE is updated - defaults to: @selector(headerBitRateUpdated:)
- (void)updateHeaderBitRate:(NSString *)data;



// Called when an error happens - defaults to: @selector(streamError:)
- (void)audioStreamerError;

// Called when we receive a 302 redirect to another url
- (void)redirectStreamError:(NSURL*)redirectURL;

- (void) checkAvailableBuffers: (NSTimer *) timer;

@end


