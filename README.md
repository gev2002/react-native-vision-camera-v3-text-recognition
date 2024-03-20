The frame processor plugin for text recognition using  Google ML Kit library for react-native-vision-camera with high performance.

# 🚨 Required Modules

react-native-vision-camera => 3.9.0 <br />
react-native-worklets-core = 0.4.0

## 💻 Installation

```sh
npm install react-native-vision-camera-v3-text-recognition
yarn add react-native-vision-camera-v3-text-recognition
```
## 👷Features
    Easy To Use.
    Works Just Writing few lines of Code.
    Works With React Native Vision Camera.
    Works for Both Cameras.
    Works Fast.
    Works With Android 🤖 and IOS.📱
    Writen With Kotlin and Objective-C.

## 💡 Usage

```js
import { Camera } from 'react-native-vision-camera-v3-text-recognition';

const [text,setText] = useState(null)

console.log(text)

<Camera
  options={{
   language: "latin"
    }}
  style={StyleSheet.absoluteFill}
  device={device}
  callback={(data) => setText(data)}
  {...props}
/>
```


---

## ⚙️ Options

|   Name   |  Type    |                 Values                 | Default |
|:--------:| :---: |:--------------------------------------:|:-------:|
| language | string | latin, chinese, devanagari, japanese, korean |  latin  |

















