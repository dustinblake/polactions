#import <Cocoa/Cocoa.h>
#import <Automator/Automator.h>

@interface EvernoteUpload : AMBundleAction 
{
	NSString*			_identifier;
	NSDateFormatter*	_dateFormatter;
}
- (id)runWithInput:(id)input fromAction:(AMAction*)anAction error:(NSDictionary**)errorInfo;
@end
