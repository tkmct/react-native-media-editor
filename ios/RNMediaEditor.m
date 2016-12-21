
#import "RNMediaEditor.h"

@implementation RNMediaEditor

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(echo:(NSString *)text)
{
  NSLog(@"RNMediaEditor.Echo: %@", text);
}

@end
