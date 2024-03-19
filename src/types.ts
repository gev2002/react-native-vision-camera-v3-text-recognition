export type {
  CameraProps,
  Frame,
  FrameProcessorPlugin,
  FrameProcessor,
} from 'react-native-vision-camera';
import type { CameraProps } from 'react-native-vision-camera';
export interface TextRecognitionOptions {
  language: 'latin' | 'chinese' | 'devanagari' | 'japanese' | 'korean';
}

export type CameraTypes = {
  callback: Function;
  options: TextRecognitionOptions;
} & CameraProps;
