#import "RNMediaEditor.h"
#import "RCTImageLoader.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface RNMediaEditor ()

@property (nonatomic, strong) NSMutableDictionary *options;

@end


@implementation RNMediaEditor {
  NSString *_imageAssetPath;
}


@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport
{
  return @{
    @"AssetType": @{
      @"Image": @"image",
      @"Video": @"video"
    }
  };
}


- (UIColor *)colorFromHexString:(NSString *)hexString Alpha:(float)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 \
                           green:((rgbValue & 0xFF00) >> 8)/255.0 \
                            blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}


/*
* options
* @type:                integer  required [0,1]
* @data:                base64 string   required
* @text:                string   required
* @subText:             string   optional
* @fontSize:            integer  optional
* @textColor:           string   optional
* @backgroundColor:     string   optional
* @backgroundOpacity:   float    optional
* @top:                 integer  optional
* @left:                integer  optional
* @subTop:              integer  optional
* @subLeft:             integer  optional
*/
RCT_EXPORT_METHOD
(
  embedText:(NSDictionary *)options
  resolve:(RCTPromiseResolveBlock)resolve
  reject:(RCTPromiseRejectBlock)reject
)
{
  self.options = options;
  NSString *type = [self.options valueForKey:@"type"];

  if ([type isEqualToString:@"image"]) {
    [self embedTextOnImage:options resolver:resolve rejecter:reject];

  } else if ([type isEqualToString:@"video"]) {
    [self embedTextOnVideo:options resolver:resolve rejecter:reject];

  } else {
    NSError *error = [NSError errorWithDomain: @"rnmediaeditor" code:1 userInfo:nil];
    reject(@"invalid_options", @"argument options invalid type", error);
  }
}


-(void)
  embedTextOnImage:(NSDictionary *)options
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
{
  self.options = options;
  NSDictionary *firstText = [options objectForKey:@"firstText"];
  NSDictionary *secondText = [options objectForKey:@"secondText"];
  
  NSString *base64str = [options objectForKey:@"data"];
  NSData *data = [[NSData alloc]
                  initWithBase64EncodedString:base64str
                  options:NSDataBase64DecodingIgnoreUnknownCharacters];
  UIImage *image = [UIImage imageWithData:data];
  

  NSNumber *fontSizeNumber = [firstText objectForKey:@"fontSize"];
  NSInteger fontSize = abs(fontSizeNumber.intValue);

  UIColor *textColor =
    [self colorFromHexString:[firstText objectForKey:@"textColor"] Alpha:1.0];

  NSNumber *backgroundOpacityNumber = [firstText objectForKey:@"backgroundOpacity"];
  float backgroundOpacity = backgroundOpacityNumber.floatValue;

  UIColor *backgroundColor =
    [self colorFromHexString:[firstText objectForKey:@"backgroundColor"] Alpha:backgroundOpacity];

  NSNumber *topNumber = [firstText objectForKey:@"top"];
  NSNumber *leftNumber = [firstText objectForKey:@"left"];
  CGFloat top = topNumber.floatValue;
  CGFloat left = leftNumber.floatValue;
  
  NSString *text = [firstText objectForKey:@"text"];
 
  // create font and size of font
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
  CGSize size = [text sizeWithFont:font];
  
  // create rect of image
  UIGraphicsBeginImageContext(image.size);
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  
  // wrapper rect
  CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
  
  // the base point of text rect
  CGPoint point = CGPointMake(left, top);
  
  
  [backgroundColor set];
  
  
  CGRect textContainer = CGRectMake(point.x, point.y, size.height * 2, size.width + fontSize * 2);
  
  CGContextFillRect(
                    UIGraphicsGetCurrentContext(),
                    textContainer
                    );
  
  CGRect textRect = CGRectMake(point.x + fontSize/2, point.y + size.height / 4, size.height, size.width + fontSize * 2);
  
  [textColor set];
  [text drawInRect:textRect
          withFont:font
     lineBreakMode:UILineBreakModeClip
         alignment:UITextAlignmentLeft ];
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSData* jpgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(newImage, 1.0f)];
  UIImage *image2 = [UIImage imageWithData:jpgData];

  
  // again to second text
  NSNumber *fontSizeNumber2 = [secondText objectForKey:@"fontSize"];
  NSInteger fontSize2 = abs(fontSizeNumber2.intValue);
  
  UIColor *textColor2 =
  [self colorFromHexString:[secondText objectForKey:@"textColor"] Alpha:1.0];
  
  NSNumber *backgroundOpacityNumber2 = [secondText objectForKey:@"backgroundOpacity"];
  float backgroundOpacity2 = backgroundOpacityNumber2.floatValue;
  
  UIColor *backgroundColor2 =
  [self colorFromHexString:[secondText objectForKey:@"backgroundColor"] Alpha:backgroundOpacity2];
  
  NSNumber *topNumber2 = [secondText objectForKey:@"top"];
  NSNumber *leftNumber2 = [secondText objectForKey:@"left"];
  CGFloat top2 = topNumber2.floatValue;
  CGFloat left2 = leftNumber2.floatValue;
  
  NSString *text2 = [secondText objectForKey:@"text"];
  
  // create font and size of font
  UIFont *font2 = [UIFont boldSystemFontOfSize:fontSize2];
  CGSize size2 = [text2 sizeWithFont:font2];
  
  // create rect of image
  UIGraphicsBeginImageContext(image.size);
  [image2 drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  
  // wrapper rect
  CGRect rect2 = CGRectMake(0, 0, image.size.width, image.size.height);
  
  // the base point of text rect
  CGPoint point2 = CGPointMake(left2, top2);
  [backgroundColor2 set];
  
  
  CGRect textContainer2 = CGRectMake(point2.x, point2.y, size2.width + fontSize2*1, size2.height * 1.5);
  
  CGContextFillRect(
                    UIGraphicsGetCurrentContext(),
                    textContainer2
                    );
  
  CGRect textRect2 = CGRectMake(point2.x + fontSize2/2, point2.y + textContainer2.size.height / 4, size2.width, size2.height);
  
  [textColor2 set];
  [text2 drawInRect:textRect2
          withFont:font2
     lineBreakMode:UILineBreakModeClip
         alignment:UITextAlignmentLeft ];
  
  
  UIImage *newImage2 = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSData* jpgData2 = [[NSData alloc] initWithData:UIImageJPEGRepresentation(newImage2, 1.0f)];
  NSString* jpg64Str = [jpgData2 base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];

  
  resolve(@[@"embed text on image", jpg64Str]);
}





-(void)embedTextOnVideo:(NSDictionary *)options
               resolver:(RCTPromiseResolveBlock)resolve
               rejecter:(RCTPromiseRejectBlock)reject
{
  self.options = options;
  NSDictionary *firstText = [options objectForKey:@"firstText"];
  NSDictionary *secondText = [options objectForKey:@"secondText"];
  
  NSString *urlStr = [options objectForKey:@"path"];
  NSURL *url = [NSURL fileURLWithPath:urlStr];
  
  AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:url options:nil];
  
  AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
  AVMutableCompositionTrack *mutableCompositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
  
  AVAssetTrack *baseVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
  
  [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, baseVideoTrack.timeRange.duration) ofTrack:baseVideoTrack atTime:kCMTimeZero error:nil];
  
  // prpare instruction
  AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
  mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
  AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mutableCompositionVideoTrack];
  mainInstruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
  
  // check orientation
  CGSize size = baseVideoTrack.naturalSize;

  // create text1
  CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
  NSString *text1 = [firstText objectForKey:@"text"];
  
  // create font and size of font
  [subtitle1Text setFont:@"Helvetica-Bold"];
  NSNumber *fontSizeNumber1 = [firstText objectForKey:@"fontSize"];
  NSInteger fontSize1 = abs(fontSizeNumber1.integerValue);
  UIFont *font1 = [UIFont boldSystemFontOfSize:fontSize1];
  CGSize textSize1 = [text1 sizeWithFont:font1];
  NSNumber *topN1 = [firstText objectForKey:@"top"];
  NSNumber *leftN1 = [firstText objectForKey:@"left"];
  [subtitle1Text setFontSize:fontSize1];
  
//  [subtitle1Text setFrame:CGRectMake(leftN1.integerValue, topN1.integerValue, textSize1.width + fontSize1*2, textSize1.height * 2)];
  [subtitle1Text setFrame:CGRectMake(leftN1.integerValue, topN1.integerValue, size.width, 30)];
  [subtitle1Text setString:text1];
  [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
  
  UIColor *textColor1 =
  [self colorFromHexString:[firstText objectForKey:@"textColor"] Alpha:1.0];
  [subtitle1Text setForegroundColor:[textColor1 CGColor]];
  
  NSNumber *backgroundOpacityNumber1 = [firstText objectForKey:@"backgroundOpacity"];
  float alpha1 = backgroundOpacityNumber1.floatValue;

  UIColor *backgroundColor1 = [self colorFromHexString:[firstText objectForKey:@"backgroundColor"] Alpha:alpha1];
  [subtitle1Text setBackgroundColor:[backgroundColor1 CGColor]];
  
  
  // create text2
  CATextLayer *subtitle2Text = [[CATextLayer alloc] init];
  NSString *text2 = [secondText objectForKey:@"text"];
  
  // create font and size of font
  [subtitle2Text setFont:@"Helvetica-Bold"];
  NSNumber *fontSizeNumber2 = [secondText objectForKey:@"fontSize"];
  NSInteger fontSize2 = abs(fontSizeNumber2.integerValue);
  UIFont *font2 = [UIFont boldSystemFontOfSize:fontSize2];
  CGSize textSize2 = [text2 sizeWithFont:font2];
  NSNumber *topN2 = [secondText objectForKey:@"top"];
  NSNumber *leftN2 = [secondText objectForKey:@"left"];
  [subtitle2Text setFontSize:fontSize2];
  
  // TODO 文字の場所をコントロールする
  //  [subtitle1Text setFrame:CGRectMake(leftN1.integerValue, topN1.integerValue, textSize1.width + fontSize1*2, textSize1.height * 2)];
  [subtitle2Text setFrame:CGRectMake(abs(leftN2.integerValue), abs(topN2.integerValue), size.width, 30)];
  [subtitle2Text setString:text2];
  [subtitle2Text setAlignmentMode:kCAAlignmentCenter];
  
  UIColor *textColor2 =
  [self colorFromHexString:[secondText objectForKey:@"textColor"] Alpha:1.0];
  [subtitle2Text setForegroundColor:[textColor2 CGColor]];
  
  NSNumber *backgroundOpacityNumber2 = [secondText objectForKey:@"backgroundOpacity"];
  float alpha2 = backgroundOpacityNumber2.floatValue;
  
  UIColor *backgroundColor2 = [self colorFromHexString:[secondText objectForKey:@"backgroundColor"] Alpha:alpha2];
  [subtitle2Text setBackgroundColor:[backgroundColor2 CGColor]];
  
  
  
  // create overlay
  CALayer *overlayLayer = [CALayer layer];
  [overlayLayer addSublayer:subtitle1Text];
  [overlayLayer addSublayer:subtitle2Text];
  overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
  [overlayLayer setMasksToBounds:YES];
  
  // create parent layer
  
  CALayer *parentLayer = [CALayer layer];
  CALayer *videoLayer = [CALayer layer];
  parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
  videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
  [parentLayer addSublayer:videoLayer];
  [parentLayer addSublayer:overlayLayer];
  
  // create videocomposition to add textLayer on base video
  AVMutableVideoComposition *textLayerComposition = [AVMutableVideoComposition videoComposition];
  textLayerComposition.renderSize = size;
  textLayerComposition.frameDuration = CMTimeMake(1, 30);
  textLayerComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
  textLayerComposition.instructions = [NSArray arrayWithObject:mainInstruction];
  
  
  // static date formatter
  static NSDateFormatter *kDateFormatter;
  kDateFormatter = [[NSDateFormatter alloc] init];
  [kDateFormatter setDateFormat:@"yyyyMMddHHmmss"];

  
  // export AVComposition to CameraRoll
  AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
  
  exporter.videoComposition = textLayerComposition;
  
  exporter.outputURL = [[[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:@YES error:nil] URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]] URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeMPEG4, kUTTagClassFilenameExtension))];

  exporter.outputFileType = AVFileTypeMPEG4;
  exporter.shouldOptimizeForNetworkUse = YES;

  [exporter exportAsynchronouslyWithCompletionHandler:^{
      ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
      if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:exporter.outputURL]) {
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL completionBlock:^(NSURL *assetURL, NSError *assetError){
          if (assetURL) {
            NSLog(@"output: %@", assetURL.absoluteString);
          }
          resolve(@{@"path": exporter.outputURL.absoluteString, @"assetPath": assetURL.absoluteString});
        }];
      }
  }];

}


@end
