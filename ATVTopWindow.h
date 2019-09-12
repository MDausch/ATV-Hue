#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow+Private.h>
#import <objc/runtime.h>
#import <notify.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/utsname.h>

// See http://iphonedevwiki.net/index.php/UIImage#UICreateScreenUIImage for more information
OBJC_EXTERN UIImage *_UICreateScreenUIImage() NS_RETURNS_RETAINED;

// Change this to work with your hue setup
static NSString *hueURL = @"http://<HUE BRIDGE IP>/api/<API KEY>>/lights/<LIGHT NUMBER>/state";

static int hueG = 0;
static int satG = 0;
static int briG = 0;

@interface ATVTopWindow : UIWindow
{
  NSTimer *_autoTimer;
  BOOL _isCapturing;
  UIImage *_screen;
}
- (void)startCapture;
- (void)autoCapture:(NSTimer *)timer;
@end


