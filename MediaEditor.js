
import { NativeModules } from 'react-native';

const { RNMediaEditor } = NativeModules;

RNMediaEditor.hello("World");

export default RNMediaEditor;
