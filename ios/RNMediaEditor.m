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


// TODO 文字の大きさ, textBoxなどの大きさの調整
- (UIImage *) drawText:(NSString *) text
              inImage:(UIImage *) image
              FontSize:(NSInteger)fontSize
              ColorCode:(NSString *)color
              X:(NSInteger) x
              Y:(NSInteger) y
{
  CGPoint point = CGPointMake(x, y);
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
  UIGraphicsBeginImageContext(image.size);
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
  [[UIColor brownColor] set];
  CGContextFillRect(
    UIGraphicsGetCurrentContext(),
    CGRectMake(point.x, point.y,
    image.size.width, fontSize)); // TODO fontsize => 決められるように
  [[self colorFromHexString:color] set];
  [text drawInRect:CGRectIntegral(rect)
    withFont:font
    lineBreakMode:UILineBreakModeTailTruncation
    alignment:UITextAlignmentCenter ];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);

  return newImage;
}

RCT_EXPORT_METHOD(embedTextOnImage:(NSString *)text :(UIImage *)img :(NSInteger *)fontSize :(NSString *)colorCode :(NSInteger *)x :(NSInteger *)y)
{
    [self drawText:text inImage:img FontSize:fontSize ColorCode:colorCode X:x Y:y];
}

@end
