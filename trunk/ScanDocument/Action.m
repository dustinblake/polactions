#import <TWAIN/TWAIN.h> 
#define ICAP_FILMTYPE 2000
#define TWFT_POSITIVE 0
#define TWFT_NEGATIVE 1

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
static NSString* _Extensions[] = {@"jpg", @"png", @"tiff"};
static const CFStringRef* _Types[] = {&kUTTypeJPEG, &kUTTypePNG, &kUTTypeTIFF};

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

static double _ICAP_GetPhysicalWidth(NSDictionary* info)
{
	return [_ICAP_GetOneValue(info, @"ICAP_PHYSICALWIDTH") doubleValue];
}

static double _ICAP_GetPhysicalHeight(NSDictionary* info)
{
	return [_ICAP_GetOneValue(info, @"ICAP_PHYSICALHEIGHT") doubleValue];
}

@implementation ScanDocument

- (id) runWithInput:(id)input fromAction:(AMAction*)anAction error:(NSDictionary**)errorInfo
{
	NSMutableArray*						output = [NSMutableArray array];
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
	double								maxSizeW = 0.0,
										maxSizeH = 0.0;
	NSString*							path = nil;
	ICAGetDeviceListPB					pb1 = {};
    ICACopyObjectPropertyDictionaryPB	pb2 = {};
	ICAScannerOpenSessionPB				pb3 = {};
	ICAScannerCloseSessionPB			pb4 = {};
	ICAScannerGetParametersPB			pb5 = {};
	ICAScannerSetParametersPB			pb6 = {};
	ICAScannerStartPB					pb7 = {};
	ICAScannerStatusPB					pb8 = {};
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
			
			pb5.sessionID = sessionID;
			pb5.theDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
			if(ICAScannerGetParameters(&pb5, NULL) == noErr) {
				device = [(NSDictionary*)pb5.theDict objectForKey:@"device"];
				maxSizeW = _ICAP_GetPhysicalWidth(device);
				maxSizeH = _ICAP_GetPhysicalHeight(device);
			}
			
			if((maxSizeW > 0.0) && (maxSizeH > 0.0)) {
				path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d-%H%M%S" timeZone:nil locale:nil] stringByAppendingPathExtension:_Extensions[format]]];
				if(units == kUnits_Centimeters) {
					originX /= kInchesToCentimeters;
					originY /= kInchesToCentimeters;
					width /= kInchesToCentimeters;
					height /= kInchesToCentimeters;
				}
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
						
						if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
							if([input isKindOfClass:[NSArray class]])
							[output addObjectsFromArray:input];
							else
							[output addObject:input];
							[output addObject:path];
						}
						else {
							*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to retrieve resulting image file") forKey:OSAScriptErrorMessage];
							path = nil;
						}
					}
					else
					*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to start scanning") forKey:OSAScriptErrorMessage];
				}
				else {
					*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to set scanner parameters") forKey:OSAScriptErrorMessage];
					path = nil;
				}
				[parameters release];
				[scanArea release];
			}
			else
			*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to get scanner parameters") forKey:OSAScriptErrorMessage];
			
			CFRelease(pb5.theDict);
			pb4.sessionID = sessionID;
			ICAScannerCloseSession(&pb4, NULL);
		}
		else
		*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to connect to scanner") forKey:OSAScriptErrorMessage];
		
		if(path == nil)
		return nil;
	}
	else {
		*errorInfo = [NSDictionary dictionaryWithObject:LOCALIZED_STRING(@"Unable to find any connected scanner") forKey:OSAScriptErrorMessage];
		return nil;
	}
	
	return output;
}

@end
