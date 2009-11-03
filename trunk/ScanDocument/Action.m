/*
	This file is part of the PolActions collection of Automator actions.
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

#import <TWAIN/TWAIN.h> 
#define ICAP_FILMTYPE 2000
#define TWFT_POSITIVE 0
#define TWFT_NEGATIVE 1

#define USE_NATIVE_RESOLUTION 0

#import "Action.h"

#define kInchesToCentimeters 2.54

#define LOCALIZED_STRING(__STRING__) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(__STRING__) value:(__STRING__) table:nil]

typedef enum {
	kMode_BW,
	kMode_Gray,
	kMode_RGB
} Mode;

typedef enum {
	kFormat_JPEG,
	kFormat_PNG,
	kFormat_TIFF
} Format;

typedef enum {
	kUnits_Inches,
	kUnits_Centimeters
} Units;

static NSString* _Modes[] = {@"CMYK", @"Gray", @"RGB"};
static NSString* _Extensions[] = {@"jpeg", @"png", @"tiff"};
static const CFStringRef* _Types[] = {&kUTTypeJPEG, &kUTTypePNG, &kUTTypeTIFF};

#ifdef IMAGE_CAPTURE_CORE_AVAILABLE
@interface ScanDocument () <ICDeviceBrowserDelegate, ICScannerDeviceDelegate>
#else
@interface ScanDocument ()
#endif
- (void) _didFinish;
@end

static void _ICAP_SetOneValue(NSMutableDictionary* info, NSString* key, id value)
{
	[info setObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"TWON_ONEVALUE", @"type", nil] forKey:key];
}

static void _ICAP_SetLightPath(NSMutableDictionary* info, int path)
{
	_ICAP_SetOneValue(info, @"ICAP_LIGHTPATH", [NSNumber numberWithInt:path]);
}

/* TWFT_POSITIVE | TWFT_NEGATIVE */
static void _ICAP_SetFilmType(NSMutableDictionary* info, int type)
{
	_ICAP_SetOneValue(info, @"ICAP_FILMTYPE", [NSNumber numberWithInt:type]);
}

/* TWPC_CHUNKY | TWPC_PLANAR */
static void _ICAP_SetPlanarChunky(NSMutableDictionary* info, int chunky)
{
	_ICAP_SetOneValue(info, @"ICAP_PLANARCHUNKY", [NSNumber numberWithInt:chunky]);
}

/* TWPT_BW | TWPT_GRAY | TWPT_RGB */
static void _ICAP_SetPixelType(NSMutableDictionary* info, int type)
{
	_ICAP_SetOneValue(info, @"ICAP_PIXELTYPE", [NSNumber numberWithInt:type]);
}

static void _ICAP_SetPixelDepth(NSMutableDictionary* info, int depth)
{
	_ICAP_SetOneValue(info, @"ICAP_BITDEPTH", [NSNumber numberWithInt:depth]);
}

static void _ICAP_SetResolutionX(NSMutableDictionary* info, double resolution)
{
	_ICAP_SetOneValue(info, @"ICAP_XRESOLUTION", [NSNumber numberWithDouble:resolution]);
}

static void _ICAP_SetResolutionY(NSMutableDictionary* info, double resolution)
{
	_ICAP_SetOneValue(info, @"ICAP_YRESOLUTION", [NSNumber numberWithDouble:resolution]);
}

static void _ICAP_SetResolution(NSMutableDictionary* info, double resolution)
{
	_ICAP_SetResolutionX(info, resolution);
	_ICAP_SetResolutionY(info, resolution);
}

static void _ICAP_SetScalingX(NSMutableDictionary* info, double scaling)
{
	_ICAP_SetOneValue(info, @"ICAP_XSCALING", [NSNumber numberWithDouble:scaling]);
}

static void _ICAP_SetScalingY(NSMutableDictionary* info, double scaling)
{
	_ICAP_SetOneValue(info, @"ICAP_YSCALING", [NSNumber numberWithDouble:scaling]);
}

static void _ICAP_SetScaling(NSMutableDictionary* info, double scaling)
{
	_ICAP_SetScalingX(info, scaling);
	_ICAP_SetScalingY(info, scaling);
}

static id _ICAP_GetOneValue(NSDictionary* info, NSString* key)
{
	NSDictionary*			cap;
	
	if((cap = [info objectForKey:key])) {
		if([[cap objectForKey: @"type"] isEqualToString: @"TWON_ONEVALUE"])
		return [cap objectForKey: @"value"];
	}
	
	return nil;
}

#if USE_NATIVE_RESOLUTION

static double _ICAP_GetNativeResolutionX(NSDictionary* info)
{
	return [_ICAP_GetOneValue(info, @"ICAP_XNATIVERESOLUTION") doubleValue];
}

static double _ICAP_GetNativeResolutionY(NSDictionary* info)
{
	return [_ICAP_GetOneValue(info, @"ICAP_YNATIVERESOLUTION") doubleValue];
}

#endif

static double _ICAP_GetPhysicalWidth(NSDictionary* info)
{
	return [_ICAP_GetOneValue(info, @"ICAP_PHYSICALWIDTH") doubleValue];
}

static double _ICAP_GetPhysicalHeight(NSDictionary* info)
{
	return [_ICAP_GetOneValue(info, @"ICAP_PHYSICALHEIGHT") doubleValue];
}

#ifdef IMAGE_CAPTURE_CORE_AVAILABLE

static NSDictionary* _DictionaryFromError(NSError* error)
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[error code]], OSAScriptErrorNumber, [error localizedDescription], OSAScriptErrorMessage, nil];
}

#endif

@implementation ScanDocument

#ifdef IMAGE_CAPTURE_CORE_AVAILABLE

- (void) didRemoveDevice:(ICDevice*)device
{
	;
}

- (void) device:(ICDevice*)device didCloseSessionWithError:(NSError*)error
{
	[self _didFinish]; //FIXME: Any error is ignored
}

- (void) scannerDevice:(ICScannerDevice*)scanner didCompleteScanWithError:(NSError*)error
{
	//Make sure scan was successful
	if(error == nil) {
		if(![[NSFileManager defaultManager] fileExistsAtPath:_result]) {
			[_result release];
			_result = [[NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to retrieve resulting image file") forKey:OSAScriptErrorMessage] retain];
		}
	}
	else {
		[_result release];
		_result = [_DictionaryFromError(error) retain];
	}
	
	//Close session
	[_scanner requestCloseSession];
}

- (void) device:(ICDevice*)device didOpenSessionWithError:(NSError*)error
{
	//Make sure the session was open successfully
	if(error) {
		_result = [_DictionaryFromError(error) retain];
		[self _didFinish];
		return;
	}
}

- (void) deviceDidBecomeReady:(ICDevice*)device
{
	ICScannerFunctionalUnit*			functionalUnit = [_scanner selectedFunctionalUnit];
	double								resolution = [[[self parameters] objectForKey:@"dpi"] doubleValue];
	Format								format = [[[self parameters] objectForKey:@"format"] intValue];
	Mode								mode = [[[self parameters] objectForKey:@"mode"] intValue];
	Units								units = [[[self parameters] objectForKey:@"units"] intValue];
	double								originX = [[[self parameters] objectForKey:@"originX"] doubleValue],
										originY = [[[self parameters] objectForKey:@"originY"] doubleValue],
										width = [[[self parameters] objectForKey:@"width"] doubleValue],
										height = [[[self parameters] objectForKey:@"height"] doubleValue];
	NSSize								maxSize;
	NSString*							path;
	
#ifdef __DEBUG__
	NSLog(@"\n%@\n%@", _scanner, functionalUnit);
#endif
	
	//Make sure all dimensions are in inches
	functionalUnit.measurementUnit = ICScannerMeasurementUnitInches;
	
	//Set scan parameters
	maxSize = functionalUnit.physicalSize;
	if(units == kUnits_Centimeters) {
		originX /= kInchesToCentimeters;
		originY /= kInchesToCentimeters;
		width /= kInchesToCentimeters;
		height /= kInchesToCentimeters;
	}
	originX = MIN(MAX(originX, 0.0), maxSize.width);
	originY = MIN(MAX(originY, 0.0), maxSize.height);
	width = MIN(MAX(width > 0.0 ? width : maxSize.width, 0.0), maxSize.width - originX);
	height = MIN(MAX(height > 0.0 ? height : maxSize.height, 0.0), maxSize.height - originY);
	functionalUnit.scanArea = NSMakeRect(originX, originY, width, height);
	functionalUnit.resolution = [functionalUnit.supportedResolutions indexGreaterThanOrEqualToIndex:resolution]; //FIXME: We don't scan at the exact requested resolution
	if(functionalUnit.resolution == NSNotFound)
	functionalUnit.resolution = [functionalUnit.supportedResolutions firstIndex];
	switch(mode) {
		
		case kMode_BW:
		functionalUnit.pixelDataType = ICScannerPixelDataTypeBW;
		functionalUnit.bitDepth = ICScannerBitDepth1Bit;
		break;
		
		case kMode_Gray:
		functionalUnit.pixelDataType = ICScannerPixelDataTypeGray;
		functionalUnit.bitDepth = ICScannerBitDepth8Bits;
		break;
		
		case kMode_RGB:
		functionalUnit.pixelDataType = ICScannerPixelDataTypeRGB;
		functionalUnit.bitDepth = ICScannerBitDepth8Bits;
		break;
		
	}
	path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d-%H%M%S" timeZone:nil locale:nil] stringByAppendingPathExtension:_Extensions[format]]];
	_scanner.transferMode = ICScannerTransferModeFileBased;
	_scanner.downloadsDirectory = [NSURL fileURLWithPath:[path stringByDeletingLastPathComponent]];
	_scanner.documentName = [[path lastPathComponent] stringByDeletingPathExtension];
	_scanner.documentUTI = (id)*_Types[format];
	
	//Perform scan...
	_result = [path copy];
	[_scanner requestScan];
}

- (void) deviceBrowser:(ICDeviceBrowser*)browser didAddDevice:(ICDevice*)device moreComing:(BOOL)moreComing
{
	//Use the first found scanner
	if(_scanner == nil) {
		_scanner = [device retain];
		[_scanner setDelegate:self];
		[_scanner requestOpenSession];
	}
}

- (void) deviceBrowser:(ICDeviceBrowser*)browser didRemoveDevice:(ICDevice*)device moreGoing:(BOOL)moreGoing
{
	;
}

- (void) willFinishRunning
{
	[_scanner setDelegate:nil];
	[_scanner release];
	_scanner = nil;
	
	[_browser stop];
	[_browser setDelegate:nil];
	[_browser release];
	_browser = nil;
}

- (void) _abort
{
	if(_scanner == nil) {
		_result = [[NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to find any connected scanner") forKey:OSAScriptErrorMessage] retain];
		[self _didFinish];
	}
}

/* Called on main thread */
- (void) _performICScan
{
	//Look for connected scanners
	_browser = [ICDeviceBrowser new];
	[_browser setDelegate:self];
	[_browser setBrowsedDeviceTypeMask:(ICDeviceLocationTypeMaskLocal | ICDeviceTypeMaskScanner)];
	[_browser start];
	
	//Make sure we abort if no scanner was found within a few seconds
	[self performSelector:@selector(_abort) withObject:nil afterDelay:2.0]; //FIXME: Is this the best method?
}

#endif

/* Called on main thread */
- (void) _performTWAINScan
{
	double								resolution = [[[self parameters] objectForKey:@"dpi"] doubleValue];
	Format								format = [[[self parameters] objectForKey:@"format"] intValue];
	Mode								mode = [[[self parameters] objectForKey:@"mode"] intValue];
	Units								units = [[[self parameters] objectForKey:@"units"] intValue];
	double								originX = [[[self parameters] objectForKey:@"originX"] doubleValue],
										originY = [[[self parameters] objectForKey:@"originY"] doubleValue],
										width = [[[self parameters] objectForKey:@"width"] doubleValue],
										height = [[[self parameters] objectForKey:@"height"] doubleValue];
	ICAObject							scanner = 0;
	ICAScannerSessionID					sessionID = 0;
#if USE_NATIVE_RESOLUTION
	double								resolutionX = 0.0,
										resolutionY = 0.0;
#endif
	double								maxSizeW = 0.0,
										maxSizeH = 0.0;
	NSString*							path = nil;
	NSDictionary*						errorInfo = nil;
	ICAGetDeviceListPB					pb1 = {};
    ICACopyObjectPropertyDictionaryPB	pb2 = {};
	ICAScannerOpenSessionPB				pb3 = {};
	ICAScannerCloseSessionPB			pb4 = {};
	ICAScannerGetParametersPB			pb5 = {};
	ICAScannerSetParametersPB			pb6 = {};
	ICAScannerStartPB					pb7 = {};
	ICAScannerStatusPB					pb8 = {};
	ICAScannerInitializePB				pb9 = {};
	CFDictionaryRef						properties;
	NSDictionary*						device;
	NSMutableDictionary*				scanArea;
	NSMutableDictionary*				parameters;
	
	//Retrive first connected scanner
	if(ICAGetDeviceList(&pb1, NULL) == noErr) {
		pb2.object = pb1.object;
		pb2.theDict = (CFDictionaryRef*)(&properties);
		if(ICACopyObjectPropertyDictionary(&pb2, NULL) == noErr) {
			for(device in [(NSDictionary*)properties objectForKey:(NSString*)kICADevicesArrayKey]) {
				if([[device objectForKey:@"device type"] isEqualToString:(NSString*)kICADeviceTypeScanner]) { //kICADeviceTypeKey
#ifdef __DEBUG__
					NSLog(@"%@", [device objectForKey:@"ifil"]); //kICAObjectNameKey
#endif
					scanner = [[device objectForKey: @"icao"] unsignedIntValue]; //kICAObjectKey
					break;
				}
			}
			CFRelease(properties);
		}
	}
	
	//Open scanner session and scan document
	if(scanner) {
		pb3.object = scanner;
        if(ICAScannerOpenSession(&pb3, NULL) == noErr) {
			sessionID = pb3.sessionID;
			
			pb9.sessionID = sessionID;
			if(ICAScannerInitialize(&pb9, NULL) == noErr) {
				pb5.sessionID = sessionID;
				pb5.theDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
				if(ICAScannerGetParameters(&pb5, NULL) == noErr) {
					device = [(NSDictionary*)pb5.theDict objectForKey:@"device"];
#ifdef __DEBUG__
					NSLog(@"\n%@", device);
#endif
#if USE_NATIVE_RESOLUTION
					resolutionX = _ICAP_GetNativeResolutionX(device);
					resolutionY = _ICAP_GetNativeResolutionY(device);
#endif
					maxSizeW = _ICAP_GetPhysicalWidth(device);
					maxSizeH = _ICAP_GetPhysicalHeight(device);
				}
			}
			
#if USE_NATIVE_RESOLUTION
			if((resolutionX > 0.0) && (resolutionY > 0.0) && (maxSizeW > 0.0) && (maxSizeH > 0.0))
#else
			if((maxSizeW > 0.0) && (maxSizeH > 0.0))
#endif
			{
				path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d-%H%M%S" timeZone:nil locale:nil] stringByAppendingPathExtension:_Extensions[format]]];
				if(units == kUnits_Centimeters) {
					originX /= kInchesToCentimeters;
					originY /= kInchesToCentimeters;
					width /= kInchesToCentimeters;
					height /= kInchesToCentimeters;
				}
#if USE_NATIVE_RESOLUTION
				originX = floor(originX * resolutionX);
				originY = floor(originY * resolutionY);
				width = ceil(width * resolutionX + 0.5);
				height = ceil(height * resolutionY + 0.5);
#endif
				originX = MIN(MAX(originX, 0.0), maxSizeW);
				originY = MIN(MAX(originY, 0.0), maxSizeH);
				width = MIN(MAX(width > 0.0 ? width : maxSizeW, 0.0), maxSizeW - originX);
				height = MIN(MAX(height > 0.0 ? height : maxSizeH, 0.0), maxSizeH - originY);
				
				scanArea = [NSMutableDictionary new];
				_ICAP_SetLightPath(scanArea, 0);
				_ICAP_SetFilmType(scanArea, TWFT_POSITIVE);
				_ICAP_SetPlanarChunky(scanArea, TWPC_CHUNKY);
				switch(mode) {
					
					case kMode_BW:
					_ICAP_SetPixelType(scanArea, TWPT_BW);
					_ICAP_SetPixelDepth(scanArea, 1);
					break;
					
					case kMode_Gray:
					_ICAP_SetPixelType(scanArea, TWPT_GRAY);
					_ICAP_SetPixelDepth(scanArea, 8);
					break;
					
					case kMode_RGB:
					_ICAP_SetPixelType(scanArea, TWPT_RGB);
					_ICAP_SetPixelDepth(scanArea, 8);
					break;
					
				}
				_ICAP_SetResolution(scanArea, resolution);
				_ICAP_SetScaling(scanArea, 1.0);
				[scanArea setObject:[NSNumber numberWithDouble:originX] forKey:@"offsetX"];
				[scanArea setObject:[NSNumber numberWithDouble:originY] forKey:@"offsetY"];
				[scanArea setObject:[NSNumber numberWithDouble:width] forKey:@"width"];
				[scanArea setObject:[NSNumber numberWithDouble:height] forKey:@"height"];
				[scanArea setObject:[NSNumber numberWithBool:YES] forKey:@"progressNotificationNoData"];
				[scanArea setObject:[NSString stringWithFormat:@"scanner.reflective.%@.positive", _Modes[mode]] forKey:@"ColorSyncMode"];
				[scanArea setObject:@"reflective scan" forKey:@"scan mode"];
				[scanArea setObject:[[path lastPathComponent] stringByDeletingPathExtension] forKey: @"document name"];
				[scanArea setObject:[path pathExtension] forKey: @"document extension"];
				[scanArea setObject:(id)*_Types[format] forKey:@"document format"];
				[scanArea setObject:[path stringByDeletingLastPathComponent] forKey: @"document folder"];
				parameters = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*)pb5.theDict];
				[parameters setObject:[NSArray arrayWithObject:scanArea] forKey:@"userScanArea"];
				pb6.sessionID = sessionID;
				pb6.theDict = (CFMutableDictionaryRef)parameters;
				if(ICAScannerSetParameters(&pb6, NULL) == noErr) {
					pb7.sessionID = sessionID;
					if(ICAScannerStart(&pb7, NULL) == noErr) {
						sleep(1);
						pb8.sessionID = sessionID;
						ICAScannerStatus(&pb8, NULL); //HACK: This blocks until scan is done
						
						if(![[NSFileManager defaultManager] fileExistsAtPath:path])
						errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to retrieve resulting image file") forKey:OSAScriptErrorMessage];
					}
					else
					errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to start scanning") forKey:OSAScriptErrorMessage];
				}
				else
				errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to set scanner parameters") forKey:OSAScriptErrorMessage];
				
				[parameters release];
				[scanArea release];
			}
			else
			errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to get scanner parameters") forKey:OSAScriptErrorMessage];
			
			if(pb5.theDict)
			CFRelease(pb5.theDict);
			pb4.sessionID = sessionID;
			ICAScannerCloseSession(&pb4, NULL);
		}
		else
		errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to connect to scanner") forKey:OSAScriptErrorMessage];
	}
	else
	errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to find any connected scanner") forKey:OSAScriptErrorMessage];
	
	_result = (errorInfo ? [errorInfo retain] : [path copy]);
	[self _didFinish];
}

- (void) _didFinish
{
	//Return result to Automator
	if([_result isKindOfClass:[NSDictionary class]]) {
		[self didFinishRunningWithError:_result];
		[_result release];
		_result = nil;
	}
	else
	[self didFinishRunningWithError:nil];
}

- (void) runAsynchronouslyWithInput:(id)input
{
	[_result release];
	_result = nil;
	
#ifdef IMAGE_CAPTURE_CORE_AVAILABLE
	if(NSClassFromString(@"ICDevice"))
	[self performSelectorOnMainThread:@selector(_performICScan) withObject:nil waitUntilDone:NO];
	else
#endif
	[self performSelectorOnMainThread:@selector(_performTWAINScan) withObject:nil waitUntilDone:NO];
}

- (id) output
{
	return (_result ? [NSArray arrayWithObject:_result] : nil);
}

- (void) dealloc
{
	[_result release];
	
	[super dealloc];
}

@end
