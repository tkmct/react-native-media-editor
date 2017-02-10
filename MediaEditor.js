
import { NativeModules } from 'react-native';

const { RNMediaEditor } = NativeModules;

const DEFAULT_OPTIONS = {
  fontSize: 24,
  textColor: '#ffffff',
  backgroundColor: '#000000',
  backgroundOpacity: 0.5,
  top: 100,
  left: 100,
};


// module.exports = {
//   ...RNMediaEditor,
//   embedText: (options) => {
//     return RNMediaEditor.embedText({...DEFAULT_OPTIONS, ...options});
//   }
// }

export default RNMediaEditor;
