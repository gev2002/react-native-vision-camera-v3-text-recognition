export type {
  CameraProps,
  Frame,
  FrameProcessorPlugin,
  ReadonlyFrameProcessor,
} from 'react-native-vision-camera';
import type { CameraProps } from 'react-native-vision-camera';
export interface TextRecognitionOptions {
  language: 'latin' | 'chinese' | 'devanagari' | 'japanese' | 'korean';
}

export type TextData = {
  blockFrameBottom: number;
  blockFrameLeft: number;
  blockFrameRight: number;
  blockFrameTop: number;
  blockText: string;
  elementFrameBottom: number;
  elementFrameLeft: number;
  elementFrameRight: number;
  elementFrameTop: number;
  elementText: string;
  lineFrameBottom: number;
  lineFrameLeft: number;
  lineFrameRight: number;
  lineFrameTop: number;
  lineText: string;
  resultText: string;
  size: number;
};

export type TextDataMap = {
  [key: number]: TextData;
};

export type CameraTypes = {
  callback: (data: TextDataMap) => void;
  options: TextRecognitionOptions;
} & CameraProps;
