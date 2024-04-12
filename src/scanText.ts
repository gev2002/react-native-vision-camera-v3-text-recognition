import type {
  Frame,
  FrameProcessorPlugin,
  TextRecognitionOptions,
} from './types';
import { VisionCameraProxy } from 'react-native-vision-camera';
import { Platform } from 'react-native';

export interface TextData {
  blockFrameBottom: number
  blockFrameLeft: number
  blockFrameRight: number
  blockFrameTop: number
  blockText: string
  elementFrameBottom: number
  elementFrameLeft: number
  elementFrameRight: number
  elementFrameTop: number
  elementText: string
  lineFrameBottom: number
  lineFrameLeft: number
  lineFrameRight: number
  lineFrameTop: number
  lineText: string
  resultText: string
  size: number
}

export interface TextDataMap {
  [key: number]: TextData
}

const plugin: FrameProcessorPlugin | undefined =
  VisionCameraProxy.initFrameProcessorPlugin('scanText');

const LINKING_ERROR =
  `The package 'react-native-vision-camera-v3-text-recognition' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

export function scanText(frame: Frame, options: TextRecognitionOptions): TextDataMap {
  'worklet';
  if (plugin == null) throw new Error(LINKING_ERROR);
  // @ts-ignore
  return options ? plugin.call(frame, options) : plugin.call(frame);
}
