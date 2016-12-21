#import "RNMediaEditor.h"


@implementation RNMediaEditor

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 \
                           green:((rgbValue & 0xFF00) >> 8)/255.0 \
                            blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

// TODO set position
- (UIImage *)embedTextToImage:(NSString *)text ImageFile:(UIImage *)img
  FontSize:(NSInteger)fontSize ColorCode:(NSString *)colorCode
{
  UIGraphicsBeginImageContext(img.size);

  CGRect aRectangle = CGRectMake(0,0, img.size.width, img.size.height);
  [img drawInRect:aRectangle];

  [[self colorFromHexString:colorCode] set];           // set text color
  if ( [text length] > 200 ) {
    fontSize = 10;
  }
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];     // set text font

  [ text drawInRect : aRectangle                      // render the text
  withFont : font
  lineBreakMode : UILineBreakModeTailTruncation  // clip overflow from end of last line
  alignment : UITextAlignmentCenter ];

  UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();   // extract the image
  UIGraphicsEndImageContext();     // clean  up the context.
  UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);

  return theImage;
}

RCT_EXPORT_METHOD(echo:(NSString *)text)
{
  NSLog(@"<RNMediaEditor#Echo>: %@", text);
}

RCT_EXPORT_METHOD(addTextToImage:(NSString *)text :(UIImage *)img :(NSInteger *)fontSize :(NSString *)colorCode)
{
    [self embedTextToImage:text ImageFile:img FontSize:fontSize ColorCode:colorCode];
}

@end
