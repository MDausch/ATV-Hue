#import "./ATVTopWindow.h"

NSString *redVal;
NSString *greenVal;
NSString *blueVal;

//Thanks to stack overflow: https://stackoverflow.com/questions/5562095/average-color-value-of-uiimage-in-objective-c/42002273
struct pixel {
    unsigned char r, g, b, a;
};

static UIColor *dominantColorFromImage(UIImage *image, float alpha){
	NSUInteger red = 1;
	NSUInteger green = 1;
	NSUInteger blue = 1;

	CGImageRef imgCGImage = image.CGImage;
	struct pixel *pixels = (struct pixel *)calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
	if (pixels != nil){
		CGContextRef context = CGBitmapContextCreate((void *)pixels, image.size.width, image.size.height, 8, image.size.width * 4, CGImageGetColorSpace(imgCGImage), kCGImageAlphaPremultipliedLast);
		if (context != NULL) {
			CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), imgCGImage);

      //Get center point's color
      int pos = (image.size.width * image.size.height )/ 2 + image.size.width / 2;

			red = pixels[pos].r;
			green = pixels[pos].g;
			blue = pixels[pos].b;

      redVal = [NSString stringWithFormat: @"R:%lu", red];
      greenVal = [NSString stringWithFormat: @"G:%lu",  green];
      blueVal = [NSString stringWithFormat: @"B:%lu",  blue];
			CGContextRelease(context);
		}
		free(pixels);
	}
	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}


@implementation ATVTopWindow
-(instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];

  self.windowLevel = 100000000;
  self.alpha = 1.0;
  self.hidden = NO;
  self.backgroundColor = [UIColor clearColor];
  _screen = [[UIImage alloc] init];
  _isCapturing = NO;
  _autoTimer = nil;

  [self _setSecure: YES];
  [self setUserInteractionEnabled:NO];

  //Get screen from before we do anything :)
  UIImage *screenshot = [self fetchImageFromScreen];
	[self startCapture];

  return self;
}

-(void)startCapture{
  //Only create the timer if its not already running
  if(_autoTimer == nil){
     _autoTimer = [NSTimer scheduledTimerWithTimeInterval: .1f
        target:self
        selector:@selector(autoCapture:)
        userInfo:nil
        repeats:YES];
    _isCapturing = YES;
  }
}

-(void)autoCapture:(NSTimer *)timer{
  _screen = [self fetchImageFromScreen];

  //Now get dominant uicolor
	UIColor *color = dominantColorFromImage(_screen,1);

  CGFloat hue, saturation, brightness, alpha ;
  [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

  hue = (int) (hue * 65535);
  saturation = (int) (saturation * 255);
  brightness = (int) (brightness * 255);

  NSDictionary *fields = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSNumber numberWithFloat:brightness],@"bri",
    [NSNumber numberWithFloat:saturation ],@"sat",
    [NSNumber numberWithFloat:hue],@"hue",
    @2,@"transitiontime",
    nil];

  NSError *error;
  NSData *postData = [NSJSONSerialization dataWithJSONObject:fields options:0 error:&error];

  //Post Update To Hue light
  NSMutableURLRequest *huePut = [[NSMutableURLRequest alloc] initWithURL: 
    [NSURL URLWithString:hueURL]];
  [huePut setHTTPMethod:@"PUT"];
  [huePut setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [huePut setHTTPBody:postData];
  [[NSURLConnection alloc] initWithRequest:huePut delegate:self];
}

-(UIImage *)fetchImageFromScreen{
  //Get Main window screen and its bounds
  UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
  CGRect rect = [keyWindow bounds];

  //Screen to UIImage
  UIGraphicsBeginImageContextWithOptions(rect.size, YES, 3.0);
  UIImage *image = _UICreateScreenUIImage();
  CGRect patchRect = rect;
  patchRect.size = image.size;
  patchRect.origin = CGPointMake(-rect.origin.x, -rect.origin.y);
  [image drawInRect:patchRect];
  image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  //Return Image
  return image;
}
@end