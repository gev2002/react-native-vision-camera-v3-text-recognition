import MLKitTextRecognition
import MLKitTextRecognitionChinese
import MLKitTextRecognitionDevanagari
import MLKitTextRecognitionJapanese
import MLKitTextRecognitionKorean
import MLKitTextRecognitionCommon
import VisionCamera
import MLKitVision

// Official instructions: https://cloud.google.com/vision/docs/ocr#ocr_requirements

@objc(VisionCameraTextRecognition)
public class VisionCameraTextRecognition: FrameProcessorPlugin {
    
    var textRecognizer: TextRecognizer?
    
    public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable: Any]! = [:]) {
        super.init(proxy: proxy, options: options)
        
        if let language = options["language"] as? String {
            switch language {
            case "latin":
                let options = TextRecognizerOptions()
                textRecognizer = TextRecognizer.textRecognizer(options: options)
            case "chinese":
                let chineseOptions = ChineseTextRecognizerOptions()
                textRecognizer = TextRecognizer.textRecognizer(options: chineseOptions)
            case "devanagari":
                let devanagariOptions = DevanagariTextRecognizerOptions()
                textRecognizer = TextRecognizer.textRecognizer(options: devanagariOptions)
            case "japanese":
                let japaneseOptions = JapaneseTextRecognizerOptions()
                textRecognizer = TextRecognizer.textRecognizer(options: japaneseOptions)
            case "korean":
                let koreanOptions = KoreanTextRecognizerOptions()
                textRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)
            default:
                let defaultOptions = TextRecognizerOptions()
                textRecognizer = TextRecognizer.textRecognizer(options: defaultOptions)
            }
        } else {
            let defaultOptions = TextRecognizerOptions()
            textRecognizer = TextRecognizer.textRecognizer(options: defaultOptions)
        }
    }
    
    public override func callback(
        _ frame: Frame,
        withArguments arguments: [AnyHashable: Any]?
    ) -> Any? {
        let buffer = frame.buffer
        let visionImage = VisionImage(buffer: buffer)
        visionImage.orientation = getOrientation(orientation: frame.orientation)
        
        var data: [[String: Any]] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.textRecognizer?.process(visionImage) { result, error in
                guard error == nil, let result = result else {
                    dispatchGroup.leave()
                    return
                }
                
                for block in result.blocks {
                    var objData: [String: Any] = [:]
                    objData["resultText"] = result.text
                    objData["blockText"] = block.text
                    objData["blockFrameLeft"] = block.frame.minX
                    objData["blockFrameTop"] = block.frame.minY
                    objData["blockFrameRight"] = block.frame.maxX
                    objData["blockFrameBottom"] = block.frame.maxY
                    objData["size"] = block.frame.size.height
                    
                    for line in block.lines {
                        objData["lineText"] = line.text
                        objData["lineFrameLeft"] = line.frame.minX
                        objData["lineFrameTop"] = line.frame.minY
                        objData["lineFrameRight"] = line.frame.maxX
                        objData["lineFrameBottom"] = line.frame.maxY
                        objData["size"] = line.frame.size.height
                        
                        for element in line.elements {
                            objData["elementText"] = element.text
                            objData["elementFrameLeft"] = element.frame.minX
                            objData["elementFrameTop"] = element.frame.minY
                            objData["elementFrameRight"] = element.frame.maxX
                            objData["elementFrameBottom"] = element.frame.maxY
                            objData["size"] = element.frame.size.height
                        }
                    }
                    
                    data.append(objData)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        return data
    }

    private func getOrientation(
          orientation: UIImage.Orientation
        ) -> UIImage.Orientation {
          switch orientation {
            case .right, .leftMirrored:
              return .up
            case .left, .rightMirrored:
              return .down
            case .up, .downMirrored:
              return .left
            case .down, .upMirrored:
              return .right
          default:
              return .up
          }
      }
}
