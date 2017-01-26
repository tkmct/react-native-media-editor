#import "RNMediaEditor.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation RNMediaEditor

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (UIColor *)colorFromHexString:(NSString *)hexString Alpha:(float)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 \
                           green:((rgbValue & 0xFF00) >> 8)/255.0 \
                            blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}


- (UIImage *) Text:(NSString *) text
              Image:(UIImage *) image
              FontSize:(NSInteger)fontSize
              TextColor:(NSString *)textColor
              BackgroundColor:(NSString *)backgroundColor
              BackgroundOpacity:(float)backgroundOpacity
              Top:(NSInteger) top
              Left:(NSInteger) left

{
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
  [[self colorFromHexString:backgroundColor Alpha:backgroundOpacity] set];
  CGRect textContainer = CGRectMake(point.x, point.y, size.width + fontSize*2, size.height * 2);

  CGContextFillRect(
    UIGraphicsGetCurrentContext(),
    textContainer
  );

  CGRect textRect = CGRectMake(point.x + fontSize, point.y + textContainer.size.height/4, size.width, size.height);

  [[self colorFromHexString:textColor Alpha:1.0] set];
  [text drawInRect:textRect
    withFont:font
    lineBreakMode:UILineBreakModeClip
    alignment:UITextAlignmentLeft ];

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);

  return newImage;
}


- (void)AddTextOnVideo:(NSURL *)videoPath
                  text:(NSString *)text
              fontSize:(NSInteger)fontSize
{
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];

    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack =
    [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];

    // Create text layer
    CGSize videoSize = videoTrack.naturalSize;
    // TODO size
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.fontSize = videoSize.height / 6;
    textLayer.shadowOpacity = 0.5;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);

    // create parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:textLayer];

    // create composition to composite
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool =
    [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

    // create instruction
    AVMutableVideoCompositionInstruction *instruction =
    [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVMutableVideoCompositionLayerInstruction* layerInstruction =
    [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];

    videoComp.instructions = [NSArray arrayWithObjects: instruction];

    // composite layer
    AVAssetExportSession *_assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                    presetName:AVAssetExportPresetMediumQuality];
    _assetExport.videoComposition = videoComp;

    NSString* videoName = @"test.mov";
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;

    // ファイルが存在している場合は削除
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }

    // エクスポード実行
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void) {
         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
         if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportUrl])
         {
             [library writeVideoAtPathToSavedPhotosAlbum:exportUrl completionBlock:^(NSURL *assetURL, NSError *assetError){
                 if (assetError) { }
             }];
         }
    }];

}

RCT_EXPORT_METHOD(
  embedTextOnImage:(NSString *)text
  :(UIImage *)img :(NSInteger *)fontSize
  :(NSString *)colorCode
  :(NSString *)backgroundColor
  :(float)backgroundOpacity
  :(NSInteger *)top :(NSInteger *)left)
{
    [ self
    Text:text Image:img
    FontSize:fontSize
    TextColor:colorCode
    BackgroundColor:backgroundColor
    BackgroundOpacity: backgroundOpacity
    Top:top Left:left ];
}

RCT_EXPORT_METHOD(embedTextOnVideo:(NSString *)text :(NSString *)videoPath :(NSInteger *)fontSize)
{
    [self AddTextOnVideo:[NSURL URLWithString:videoPath] text:text fontSize:fontSize];
}

@end
