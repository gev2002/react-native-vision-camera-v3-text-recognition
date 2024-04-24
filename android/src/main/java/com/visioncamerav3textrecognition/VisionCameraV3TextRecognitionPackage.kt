package com.visioncamerav3textrecognition

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import com.facebook.react.bridge.NativeModule
import com.mrousavy.camera.frameprocessors.FrameProcessorPluginRegistry

class VisionCameraV3TextRecognitionPackage : ReactPackage {
   companion object {
    init {
      FrameProcessorPluginRegistry.addFrameProcessorPlugin("scanText") {proxy,options ->
        VisionCameraV3TextRecognitionModule(proxy,options)
      }
    }
  }
  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return emptyList()
  }
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
    return emptyList()
  }
}
