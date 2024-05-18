package com.visioncamerav3textrecognition

import android.media.Image
import android.view.Surface
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessors.VisionCameraProxy
import com.mrousavy.camera.core.types.Orientation
import java.util.ArrayList

fun Orientation?.toDegrees(): Int =
  when (this) {
    Orientation.PORTRAIT -> 0
    Orientation.LANDSCAPE_LEFT -> 90
    Orientation.PORTRAIT_UPSIDE_DOWN -> 180
    Orientation.LANDSCAPE_RIGHT -> 270
    else -> 0  // Default to PORTRAIT
  }


class VisionCameraV3TextRecognitionModule(proxy : VisionCameraProxy, options: Map<String, Any>?): FrameProcessorPlugin() {
  private var recognizer: TextRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
  private var language = options?.get("language").toString()

  init {
    recognizer = when (language) {
      "latin" -> TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
      "chinese" -> TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
      "devanagari" -> TextRecognition.getClient(DevanagariTextRecognizerOptions.Builder().build())
      "japanese" -> TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build())
      "korean" -> TextRecognition.getClient(KoreanTextRecognizerOptions.Builder().build())
      else -> TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    }
  }
  override fun callback(frame: Frame, arguments: Map<String, Any>?): ArrayList<Any> {
      try {
        val mediaImage: Image = frame.image
        val array = WritableNativeArray()
        val orientation : Orientation = frame.orientation
        val degrees = orientation.toDegrees()
        val image = InputImage.fromMediaImage(mediaImage, degrees)
        val task: Task<Text> = recognizer.process(image)
        val result: Text? = Tasks.await(task)
          val resultText = result?.text
          for (block in result?.textBlocks!!) {
            val map = WritableNativeMap()
            map.putString("resultText",resultText)
            val blockText = block.text
            map.putString("blockText",blockText)
            val blockCornerPoints = block.cornerPoints?.size
            if (blockCornerPoints != null) {
              map.putInt("size",blockCornerPoints)
            }
            val blockFrameBottom = block.boundingBox?.bottom
            val blockFrameTop = block.boundingBox?.top
            val blockFrameLeft = block.boundingBox?.left
            val blockFrameRight = block.boundingBox?.right
            if (blockFrameBottom != null) {
              map.putInt("blockFrameBottom",blockFrameBottom)
            }
            if (blockFrameLeft != null) {
              map.putInt("blockFrameLeft",blockFrameLeft)
            }
            if (blockFrameTop != null) {
              map.putInt("blockFrameTop",blockFrameTop)
            }
            if (blockFrameRight != null) {
              map.putInt("blockFrameRight",blockFrameRight)
            }
            for (line in block.lines) {
              val lineText = line.text
              map.putString("lineText",lineText)
              val lineCornerPoints = line.cornerPoints?.size
              if (lineCornerPoints != null) {
                map.putInt("size",lineCornerPoints)
              }
              val lineFrameBottom = line.boundingBox?.bottom
              val lineFrameTop = line.boundingBox?.top
              val lineFrameLeft = line.boundingBox?.left
              val lineFrameRight = line.boundingBox?.right
              if (lineFrameBottom != null) {
                map.putInt("lineFrameBottom",lineFrameBottom)
              }
              if (lineFrameLeft != null) {
                map.putInt("lineFrameLeft",lineFrameLeft)
              }
              if (lineFrameTop != null) {
                map.putInt("lineFrameTop",lineFrameTop)
              }
              if (lineFrameRight != null) {
                map.putInt("lineFrameRight",lineFrameRight)
              }
              for (element in line.elements) {
                val elementText = element.text
                map.putString("elementText",elementText)

                val elementCornerPoints = line.cornerPoints?.size
                if (elementCornerPoints != null) {
                  map.putInt("size",elementCornerPoints)
                }
                val elementFrameBottom = line.boundingBox?.bottom
                val elementFrameTop = line.boundingBox?.top
                val elementFrameLeft = line.boundingBox?.left
                val elementFrameRight = line.boundingBox?.right
                if (elementFrameBottom != null) {
                  map.putInt("elementFrameBottom",elementFrameBottom)
                }
                if (elementFrameLeft != null) {
                  map.putInt("elementFrameLeft",elementFrameLeft)
                }
                if (elementFrameTop != null) {
                  map.putInt("elementFrameTop",elementFrameTop)
                }
                if (elementFrameRight != null) {
                  map.putInt("elementFrameRight",elementFrameRight)
                }
              }
              array.pushMap(map)

            }
          }
        return array.toArrayList()
      } catch (e: Exception) {
       throw  Exception("Error processing text recognition: $e ")
      }
  }
}

