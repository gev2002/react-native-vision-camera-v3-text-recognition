#import <MLKitTextRecognition/MLKitTextRecognition.h>
#import <MLKitTextRecognitionChinese/MLKitTextRecognitionChinese.h>
#import <MLKitTextRecognitionDevanagari/MLKitTextRecognitionDevanagari.h>
#import <MLKitTextRecognitionJapanese/MLKitTextRecognitionJapanese.h>
#import <MLKitTextRecognitionKorean/MLKitTextRecognitionKorean.h>
#import <MLKitTextRecognitionCommon/MLKitTextRecognitionCommon.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCameraProxy.h>
#import <VisionCamera/Frame.h>
@import MLKitVision;
@interface VisionCameraTextRecognitionV3Plugin : FrameProcessorPlugin

@property(nonatomic, strong) MLKTextRecognizer *textRecognizer;

@end

@implementation VisionCameraTextRecognitionV3Plugin

- (instancetype)initWithProxy:(VisionCameraProxyHolder*)proxy
                   withOptions:(NSDictionary* _Nullable)options {
    self = [super initWithProxy:proxy withOptions:options];
    if (self) {
        NSString *language = options[@"language"];

        NSLog(@" %@ 444 ",language);
        if ([language isEqualToString:@"latin"]) {
            MLKTextRecognizerOptions *options = [[MLKTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
        } else if ([language isEqualToString:@"chinese"]) {
            MLKChineseTextRecognizerOptions *chineseOptions = [[MLKChineseTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:chineseOptions];
        }else if ([language isEqualToString:@"devanagari"]) {
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
        }else {
            MLKTextRecognizerOptions *defaultOptions = [[MLKTextRecognizerOptions alloc] init];
            _textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:defaultOptions];            }

    }
    return self;
}

- (id _Nullable)callback:(Frame* _Nonnull)frame
           withArguments:(NSDictionary* _Nullable)arguments {
    CMSampleBufferRef buffer = frame.buffer;
    UIImageOrientation orientation = frame.orientation;
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:buffer];
    image.orientation = orientation;
    NSMutableArray *data = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.textRecognizer processImage:image
                                   completion:^(MLKText *_Nullable result,
                                                NSError *_Nullable error) {
            if (error || !result ) {
                dispatch_group_leave(dispatchGroup);
                return;
            }
            for (MLKTextBlock *block in result.blocks) {
                NSMutableDictionary *objData = [[NSMutableDictionary alloc] init];
                NSString *resultText = result.text;
                objData[@"resultText"] = resultText;
                NSString *blockText = block.text;
                objData[@"blockText"] = blockText;
                CGRect blockFrame = block.frame;
                objData[@"blockFrameLeft"] = @(CGRectGetMinX(blockFrame));
                objData[@"blockFrameTop"] = @(CGRectGetMinY(blockFrame));
                objData[@"blockFrameRight"] = @(CGRectGetMaxX(blockFrame));
                objData[@"blockFrameBottom"] = @(CGRectGetMaxY(blockFrame));
                objData[@"size"] = @(blockFrame.size.height);
              for (MLKTextLine *line in block.lines) {
                NSString *lineText = line.text;
                  objData[@"lineText"] = lineText;
                  CGRect lineFrame = line.frame;
                  objData[@"lineFrameLeft"] = @(CGRectGetMinX(lineFrame));
                  objData[@"lineFrameTop"] = @(CGRectGetMinY(lineFrame));
                  objData[@"lineFrameRight"] = @(CGRectGetMaxX(lineFrame));
                  objData[@"lineFrameBottom"] = @(CGRectGetMaxY(lineFrame));
                  objData[@"size"] = @(lineFrame.size.height);
                for (MLKTextElement *element in line.elements) {
                  NSString *elementText = element.text;
                  CGRect elementFrame = element.frame;
                    objData[@"elementText"] = elementText;
                    objData[@"elementFrameLeft"] = @(CGRectGetMinX(elementFrame));
                    objData[@"elementFrameTop"] = @(CGRectGetMinY(elementFrame));
                    objData[@"elementFrameRight"] = @(CGRectGetMaxX(elementFrame));
                    objData[@"elementFrameBottom"] = @(CGRectGetMaxY(elementFrame));
                    objData[@"size"] = @(elementFrame.size.height);
                }
              }
                [data addObject:objData];
            }
            dispatch_group_leave(dispatchGroup);
        }];

    });
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    return data;
}

VISION_EXPORT_FRAME_PROCESSOR(VisionCameraTextRecognitionV3Plugin, scanText)

@end
