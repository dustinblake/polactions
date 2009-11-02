/*
	This file is part of the PolActions set of Automator actions.
	Copyright (C) 2008-2009 Pierre-Olivier Latour <info@pol-online.net>
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "Action.h"
#import "Keychain.h"
#import "NSURL+Parameters.h"
#import "SystemInfo.h"
#import "MD5.h"

/* http://www.evernote.com/about/developer/api/evernote-api.htm */
#import "THTTPClient.h"
#import "TBinaryProtocol.h"
#import "UserStore.h"
#import "NoteStore.h"

#import "../../EvernoteConsumerID.h"

#define kServer @"www.evernote.com"

#define LOCALIZED_STRING(__STRING__) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(__STRING__) value:(__STRING__) table:nil]

@implementation EvernoteUpload

- (id) initWithDefinition:(NSDictionary*)dictionary fromArchive:(BOOL)archived
{
	if((self = [super initWithDefinition:dictionary fromArchive:archived])) {
		_identifier = [[NSString alloc] initWithFormat:@"%@/%@; Mac OS X %@", [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleExecutable"], [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"], [[SystemInfo sharedSystemInfo] systemProductVersion]];
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
	}
	
	return self;
}

- (void) dealloc
{
	[_dateFormatter release];
	[_identifier release];
	
	[super dealloc];
}

- (id) runWithInput:(id)input fromAction:(AMAction*)anAction error:(NSDictionary**)errorInfo
{
	NSDictionary*				standardMimeTypes = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"EvernoteStandardTypes"];
	NSString*					defaultMimeType = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"EvernoteDefaultType"];
	NSString*					username = [[self parameters] objectForKey:@"username"];
	NSString*					password = [[self parameters] objectForKey:@"password"];
	NSString*					notebookName = [[self parameters] objectForKey:@"notebook"];
	NSFileManager*				manager = [NSFileManager defaultManager];
	NSMutableArray*				output = input;
	EDAMAuthenticationResult*	authentication = nil;
	EDAMNotebook*				notebook = nil;
	NSString*					path;
	BOOL						isDirectory;
	THTTPClient*				transport;
	TBinaryProtocol*			protocol;
	EDAMUserStoreClient*		store;
	EDAMNoteStoreClient*		client;
	EDAMNote*					note;
	EDAMResource*				resource;
	EDAMResourceAttributes*		attributes;
	EDAMData*					data;
	NSString*					mimeType;
	NSData*						rawData;
	MD5							md5;
	NSString*					hash;
	NSString*					content;
	EDAMNote*					result;
	CGImageSourceRef			imageSource;
	CFDictionaryRef				imageProperties;
	int16_t						width,
								height;
	NSString*					make;
	NSString*					model;
	EDAMTimestamp				timestamp;
	NSString*					string;
	
	//Retrieve username and password from parameters or directly from Evernote's application settings if absent
	if([username length]) {
		if(![password length]) {
			*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Evernote account password is required") forKey:OSAScriptErrorMessage];
			return nil;
		}
	}
	else {
		username = [[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:[@"~/Library/Preferences/com.evernote.Evernote.plist" stringByExpandingTildeInPath]] mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL] objectForKey:@"username"];
		if(![username length]) {
			*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to retrieve username for Evernote account") forKey:OSAScriptErrorMessage];
			return nil;
		}
		
		password = [[[Keychain sharedKeychain] URLWithPasswordForURL:[NSURL URLWithString:@"https://Evernote@evernote.com"]] passwordByReplacingPercentEscapes];
		if(![password length]) {
			*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to retrieve password for Evernote account") forKey:OSAScriptErrorMessage];
			return nil;
		}
	}
	
	//Check API version compatibility with Evernote servers and authenticate
	transport = [[THTTPClient alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/edam/user", kServer]]];
	protocol = [[TBinaryProtocol alloc] initWithTransport:transport];
	[transport release];
	store = [[[EDAMUserStoreClient alloc] initWithProtocol:protocol] autorelease];
	[protocol release];
	@try {
		if([store checkVersion:_identifier :[EDAMUserStoreConstants EDAM_VERSION_MAJOR] :[EDAMUserStoreConstants EDAM_VERSION_MINOR]])
		authentication = [store authenticate:username :password :kConsumerKey :kConsumerSecret];
	}
	@catch(NSException* exception) {
		NSLog(@"<EXCEPTION>\n%@", exception);
	}
	if(authentication == nil) {
		*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to authenticate with Evernote") forKey:OSAScriptErrorMessage];
		return nil;
	}
#ifdef __DEBUG__
	NSLog(@"\n%@", [authentication user]);
#endif
	
	//Retrieve target notebook
	transport = [[THTTPClient alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/edam/note/%@", [[authentication user] privilege] > PrivilegeLevel_NORMAL ? @"https" : @"http", kServer, [[authentication user] shardId]]]];
	protocol = [[TBinaryProtocol alloc] initWithTransport:transport];
	[transport release];
	client = [[[EDAMNoteStoreClient alloc] initWithProtocol:protocol] autorelease];
	[protocol release];
	@try {
		if([notebookName length]) {
			for(notebook in [client listNotebooks:[authentication authenticationToken]]) {
				if([[notebook name] caseInsensitiveCompare:notebookName] == NSOrderedSame)
				break;
			}
		}
		else
		notebook = [client getDefaultNotebook:[authentication authenticationToken]];
	}
	@catch(NSException* exception) {
		NSLog(@"<EXCEPTION>\n%@", exception);
	}
	if(notebook == nil) {
		*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to retrieve notebook from Evernote") forKey:OSAScriptErrorMessage];
		return nil;
	}
#ifdef __DEBUG__
	NSLog(@"\n%@", notebook);
#endif
	
	//Process each input file and add it as a new note to the target notebook
	if(![input isKindOfClass:[NSArray class]])
	input = [NSArray arrayWithObject:input];
	for(path in input) {
		result = nil;
		if([manager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
			mimeType = [standardMimeTypes objectForKey:[[path pathExtension] lowercaseString]];
			if(mimeType == nil)
			mimeType = defaultMimeType;
			
			rawData = [[NSData alloc] initWithContentsOfFile:path options:(NSMappedRead | NSUncachedRead) error:NULL];
			if(rawData) {
				md5 = MD5WithBytes([rawData bytes], [rawData length]);
				hash = [MD5ToString(&md5) lowercaseString];
				width = 0;
				height = 0;
				make = nil;
				model = nil;
				timestamp = 0;
				if([mimeType hasPrefix:@"image/"]) {
					imageSource = CGImageSourceCreateWithData((CFDataRef)rawData, NULL);
					if(imageSource) {
						imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
						if(imageProperties) {
#ifdef __DEBUG__
							NSLog(@"\n%@", imageProperties);
#endif
							width = MAX([[(NSDictionary*)imageProperties objectForKey:(id)kCGImagePropertyPixelWidth] shortValue], 0);
							height = MAX([[(NSDictionary*)imageProperties objectForKey:(id)kCGImagePropertyPixelHeight] shortValue], 0);
							make = [[(NSDictionary*)imageProperties objectForKey:(id)kCGImagePropertyTIFFDictionary] objectForKey:(id)kCGImagePropertyTIFFMake];
							if(([make length] < [EDAMLimitsConstants EDAM_ATTRIBUTE_LEN_MIN]) || ([make length] > [EDAMLimitsConstants EDAM_ATTRIBUTE_LEN_MAX]))
							make = nil;
							else
							make = [[make retain] autorelease];
							model = [[(NSDictionary*)imageProperties objectForKey:(id)kCGImagePropertyTIFFDictionary] objectForKey:(id)kCGImagePropertyTIFFModel];
							if(([model length] < [EDAMLimitsConstants EDAM_ATTRIBUTE_LEN_MIN]) || ([model length] > [EDAMLimitsConstants EDAM_ATTRIBUTE_LEN_MAX]))
							model = nil;
							else
							model = [[model retain] autorelease];
							if((string = [[(NSDictionary*)imageProperties objectForKey:(id)kCGImagePropertyExifDictionary] objectForKey:(id)kCGImagePropertyExifDateTimeOriginal]))
							timestamp = [[_dateFormatter dateFromString:string] timeIntervalSince1970] * 1000.0;
							CFRelease(imageProperties);
						}
						CFRelease(imageSource);
					}
				}
				if(timestamp == 0)
				timestamp = [[[manager attributesOfItemAtPath:path error:NULL] objectForKey:NSFileCreationDate] timeIntervalSince1970] * 1000.0;
#ifdef __DEBUG__
				NSLog(@"\n%@ [%@ | %i | %@ | %@ | %ix%i | %@ | %@]", path, mimeType, [rawData length], hash, [NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)timestamp / 1000.0)], width, height, make, model);
#endif
				
				//FIXME: Extract geo-localization info
				data = [[EDAMData alloc] initWithBodyHash:[NSData dataWithBytes:&md5 length:sizeof(MD5)] size:[rawData length] body:rawData];
				attributes = [[EDAMResourceAttributes alloc] initWithSourceURL:nil timestamp:timestamp latitude:0.0 longitude:0.0 altitude:0.0 cameraMake:make cameraModel:model clientWillIndex:NO recoType:nil fileName:[path lastPathComponent] attachment:NO];
				resource = [[EDAMResource alloc] initWithGuid:0 noteGuid:0 data:data mime:mimeType width:width height:height duration:0 active:0 recognition:0 attributes:attributes updateSequenceNum:0 alternateData:nil];
				content = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\"><en-note><en-media type=\"%@\" hash=\"%@\"/></en-note>", mimeType, hash];
				note = [[EDAMNote alloc] initWithGuid:0 title:[[path lastPathComponent] stringByDeletingPathExtension] content:content contentHash:nil contentLength:0 created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:[notebook guid] tagGuids:nil resources:nil attributes:nil tagNames:nil];
				[note setResources:[NSArray arrayWithObject:resource]];
				
				@try {
					result = [client createNote:[authentication authenticationToken] :note];
				}
				@catch(NSException* exception) {
					NSLog(@"<EXCEPTION>\n%@", exception);
				}
				
				[note release];
				[resource release];
				[attributes release];
				[data release];
				[rawData release];
			}
		}
		if(result == nil) {
			if(*errorInfo == nil)
			*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Some files could not be processed") forKey:OSAScriptErrorMessage];
		}
	}
	
	return output;
}

@end
