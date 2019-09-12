#import "./ATVTopWindow.h"
extern const char *__progname;

#define NSLog(...)

// REMEMBER TO UPDATE THE HUE URL IN ATVTopWindow.h
static ATVTopWindow *screenshot = nil;

%hook PBApplication
- (void)_handleFocusedProcessDidChange {
	%orig;
  
  // Start process of getting screen image and pushing changes to the light
	if(screenshot == nil){
		float height = ([[UIScreen mainScreen] bounds].size.height);
		float width = ([[UIScreen mainScreen] bounds].size.width);

		screenshot = [[ATVTopWindow alloc]initWithFrame:CGRectMake(0,0,width,height)];

    // Turn on the light
    NSDictionary *fields = [[NSDictionary alloc] initWithObjectsAndKeys:
                 @true, @"on",
                 nil];

    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:fields options:0 error:&error];

    NSMutableURLRequest *huePut =[[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:hueURL]];
    [huePut setHTTPMethod:@"PUT"];
    [huePut setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [huePut setHTTPBody:postData];
    [[NSURLConnection alloc] initWithRequest:huePut delegate:self];
	}
}
%end


%hook PBSSystemService
-(void)sleepSystemForReason:(unsigned long long)arg1 {
  %orig;

  // Turn on the light
  NSDictionary *fields = [[NSDictionary alloc] initWithObjectsAndKeys:
               @true, @"on",
               nil];

  NSError *error;
  NSData *postData = [NSJSONSerialization dataWithJSONObject:fields options:0 error:&error];

  NSMutableURLRequest *huePut =[[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:hueURL]];
  [huePut setHTTPMethod:@"PUT"];
  [huePut setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [huePut setHTTPBody:postData];
  [[NSURLConnection alloc] initWithRequest:huePut delegate:self];
}
%end