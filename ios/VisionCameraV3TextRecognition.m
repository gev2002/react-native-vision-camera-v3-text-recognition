#import <MLKitTextRecognition/MLKitTextRecognition.h>
#import <MLKitTextRecognitionChinese/MLKitTextRecognitionChinese.h>
#import <MLKitTextRecognitionDevanagari/MLKitTextRecognitionDevanagari.h>
#import <MLKitTextRecognitionJapanese/MLKitTextRecognitionJapanese.h>
#import <MLKitTextRecognitionKorean/MLKitTextRecognitionKorean.h>
#import <MLKitTextRecognitionCommon/MLKitTextRecognitionCommon.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/VisionCameraProxy.h>
#import <VisionCamera/Frame.h>
@import MLKitVision;
@interface VisionCameraTextRecognitionV3Plugin : FrameProcessorPlugin

@property(nonatomic, strong) MLKTextRecognizer *textRecognizer;

@end

@implementation VisionCameraTextRecognitionV3Plugin

- (instancetype)initWithProxy:(VisionCameraProxyHolder*)proxy
                   withOptions:(NSDictionary* _Nullable)options {
    self = [super initWithProxy:proxy withOptions:options];

    if (options != nil && [options.allKeys containsObject:@"language"]) {
        NSString *language = options[@"language"];

        if ([language isEqualToString:@"latin"]) {
            MLKTextRecognizerOptions *latinOptions = [[MLKTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:latinOptions];
        }
        else if ([language isEqualToString:@"chinese"]) {
            MLKChineseTextRecognizerOptions *chineseOptions = [[MLKChineseTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:chineseOptions];
        }
        else if ([language isEqualToString:@"devanagari"]) {
            MLKDevanagariTextRecognizerOptions *devanagariOptions = [[MLKDevanagariTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:devanagariOptions];
        }
        else if ([language isEqualToString:@"japanese"]) {
            MLKJapaneseTextRecognizerOptions *japaneseOptions = [[MLKJapaneseTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:japaneseOptions];
        }
        else if ([language isEqualToString:@"korean"]) {
            MLKKoreanTextRecognizerOptions *koreanOptions = [[MLKKoreanTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:koreanOptions];
        }
    } else {
        MLKTextRecognizerOptions *defaultOptions = [[MLKTextRecognizerOptions alloc] init];
        _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:defaultOptions];
    }

    return self;
}

- (id _Nullable)callback:(Frame* _Nonnull)frame
           withArguments:(NSDictionary* _Nullable)arguments {
    CMSampleBufferRef buffer = frame.buffer;
    UIImageOrientation orientation = frame.orientation;
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:buffer];
    image.orientation = orientation;
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.textRecognizer processImage:image
                                   completion:^(MLKText *_Nullable result,
                                                NSError *_Nullable error) {
            if (error || !result ) {
                [NSException raise:@"Error processing text recognition" format:@"%@",error];

            }
            NSString *resultText = result.text;
            data[@"resultText"] = resultText;
            for (MLKTextBlock *block in result.blocks) {
                NSString *blockText = block.text;
                data[@"blockText"] = blockText;
                CGRect blockFrame = block.frame;
                data[@"blockFrameLeft"] = @(CGRectGetMinX(blockFrame));
                data[@"blockFrameTop"] = @(CGRectGetMinY(blockFrame));
                data[@"blockFrameRight"] = @(CGRectGetMaxX(blockFrame));
                data[@"blockFrameBottom"] = @(CGRectGetMaxY(blockFrame));
                data[@"size"] = @(blockFrame.size.height);
              for (MLKTextLine *line in block.lines) {
                NSString *lineText = line.text;
                  data[@"lineText"] = lineText;
                  CGRect lineFrame = line.frame;
                  data[@"lineFrameLeft"] = @(CGRectGetMinX(lineFrame));
                  data[@"lineFrameTop"] = @(CGRectGetMinY(lineFrame));
                  data[@"lineFrameRight"] = @(CGRectGetMaxX(lineFrame));
                  data[@"lineFrameBottom"] = @(CGRectGetMaxY(lineFrame));
                  data[@"size"] = @(lineFrame.size.height);
                for (MLKTextElement *element in line.elements) {
                  NSString *elementText = element.text;
                  CGRect elementFrame = element.frame;
                    data[@"elementText"] = elementText;
                    data[@"elementFrameLeft"] = @(CGRectGetMinX(elementFrame));
                    data[@"elementFrameTop"] = @(CGRectGetMinY(elementFrame));
                    data[@"elementFrameRight"] = @(CGRectGetMaxX(elementFrame));
                    data[@"elementFrameBottom"] = @(CGRectGetMaxY(elementFrame));
                    data[@"size"] = @(elementFrame.size.height);
                }
              }
            }
            dispatch_group_leave(dispatchGroup);

        }];

    });
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    return data;
}

VISION_EXPORT_FRAME_PROCESSOR(VisionCameraTextRecognitionV3Plugin, scanText)

@end
