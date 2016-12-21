
#import "RNMediaEditor.h"

@implementation RNMediaEditor

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(hello:(NSString *)name)
{
  NSLog(@"Hello %@", name);
}



@end

