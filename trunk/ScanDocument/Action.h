#import <Cocoa/Cocoa.h>
#import <Automator/Automator.h>

@interface ScanDocument : AMBundleAction 
- (id)runWithInput:(id)input fromAction:(AMAction*)anAction error:(NSDictionary**)errorInfo;
@end
