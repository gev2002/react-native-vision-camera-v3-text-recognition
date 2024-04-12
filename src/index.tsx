import React, { forwardRef,type ForwardedRef } from 'react';
import {
  Camera as VisionCamera,
  useFrameProcessor,
} from 'react-native-vision-camera';
import { useRunInJS } from 'react-native-worklets-core';
import { scanText } from './scanText';
import type { CameraTypes, Frame, FrameProcessor } from './types';

export { scanText } from './scanText';
export type { TextData, TextDataMap } from './types';

export const Camera = forwardRef(function Camera(props: CameraTypes,ref:ForwardedRef<any>) {
  const { callback, device, options } = props;
  // @ts-ignore
  const useWorklets = useRunInJS((data: TextDataMap): void => {
    callback(data);
  }, []);
  const frameProcessor: FrameProcessor = useFrameProcessor(
    (frame: Frame): void => {
      'worklet';
      // @ts-ignore
      const data = scanText(frame, options);
      // @ts-ignore
      // eslint-disable-next-line react-hooks/rules-of-hooks
      useWorklets(data);
    },
    []
  );
  return (
    !!device && <VisionCamera ref={ref} frameProcessor={frameProcessor} {...props} />
  );
});
