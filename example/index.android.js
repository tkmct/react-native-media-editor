/* @flow */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Image,
  Button,
  Dimensions,
  Platform,
  ActivityIndicator,
  TextInput
} from 'react-native';
import ImagePicker from 'react-native-image-picker';
import RNMediaEditor from 'react-native-media-editor';
import Video from 'react-native-video';
import CameraView from './Camera';


var options = {
  title: 'Select Image',
  storageOptions: {
    skipBackup: true,
    path: 'images'
  }
};

function toVerticalString(str) {
  let verStr = '';
  for (s of str) {
    verStr += s + '\n';
  }
  return verStr;
}

export default class example extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showCamera: false,
      loading: false,
      photo: null,
      video: null,
      text: '',
      fontSize: 20,
      colorCode: '#ffffff',
      textBackgroundColor: '#fef000'
    };

    this.onButtonPress = this.onButtonPress.bind(this);
    this.onTakeVideoPress = this.onTakeVideoPress.bind(this);
    this.onEmbedButtonPress = this.onEmbedButtonPress.bind(this);
    this.renderMedia = this.renderMedia.bind(this);
    this.renderVideo = this.renderVideo.bind(this);
    this.renderImage = this.renderImage.bind(this);
    this.renderInput = this.renderInput.bind(this);
  }

  onButtonPress() {
    this.setState({
      photo: null,
      loading: true
    });
    ImagePicker.launchImageLibrary(options, (response) => {
      console.log('Response = ', response);

      if (response.didCancel) {
        console.log('User cancelled image picker');
      }
      else if (response.error) {
        console.log('ImagePicker Error: ', response.error);
      }
      else if (response.customButton) {
        console.log('User tapped custom button: ', response.customButton);
      }
      else {

        let source;
        // or a reference to the platform specific asset location
        if (Platform.OS === 'ios') {
          source = {uri: response.uri.replace('file://', ''), isStatic: true};
        } else {
          source = {uri: response.uri, path: response.path, isStatic: true};
        }
        console.log(source);

        this.setState({
          photo: source,
          loading: false,
        });
      }
    });
  }

  onEmbedButtonPress() {
    console.log(RNMediaEditor);
    const {text, subText, photo, video, fontSize, colorCode, textBackgroundColor} = this.state;

    console.log(video);
    console.log(photo);

    if (video) {
      RNMediaEditor.embedTextOnVideo(text, video.path, fontSize, (file) => { console.log(file); }, (err) => console.log(err));
    } else if (photo) {
      RNMediaEditor.embedTextOnImage(text, photo.path, fontSize, colorCode, (file) => {
         console.log(file);
         this.setState({photo: {
           uri: file
         }});
       }, (err) => {
         console.log(err)
       });
    }
  }

  onTakeVideoPress() {
    this.setState({
      showCamera: true
    });
  }


  renderMedia() {
    if (this.state.video) {
      return this.renderVideo();
    } else if (this.state.photo) {
      return this.renderImage();
    } else {
      return;
    }
  }

  renderVideo() {
    console.log("Video rendered")
    console.log(this.state);
    return (
      <Video
        source={{uri: this.state.video.path}}
        ref={ref => {
          this.player = ref;
        }}
        resizeMode="cover"
        repeat
        rate={1.0}
        style={styles.video}
      />
    )
  }

  renderImage() {
    if (this.state.photo) {
      return (
        <Image
          style={styles.image}
          source={this.state.photo}
        />
      )
    } else if (this.state.loading) {
      return <ActivityIndicator />;
    } else {
      return;
    }
}

  renderInput() {
    return (
      <View>
        <View>
          <Text style={styles.labelText}>Text</Text>
          <TextInput
            style={styles.input}
            onChangeText={(text) => this.setState({text})}
            value={this.state.text}
          />
        </View>
        <View>
          <Text>Font Size</Text>
          <TextInput
            style={styles.input}
            onChangeText={(fontSize) => this.setState({fontSize: Number(fontSize)})}
            keyboardType="number-pad"
            value={String(this.state.fontSize)}
          />
        </View>
        <View>
          <Text>Color</Text>
          <TextInput
            style={styles.input}
            onChangeText={(colorCode) => this.setState({colorCode})}
            value={this.state.colorCode}
          />
        </View>
      </View>
    )
  }

  render() {
    if (this.state.showCamera) {
      return (
        <CameraView
          endCapturing={() => {this.setState({showCamera: false})}}
          onVideoReturned={(video) => {this.setState({video})}}
        />
      )
    } else {
      return (
        <View style={styles.container}>
          <View style={{ flex: 1 }}>
          { this.renderMedia() }
        </View>
        <View style={styles.container}>
          <Button
            onPress={this.onButtonPress}
            title="Pick Image"
          />
          <Button
            onPress={this.onTakeVideoPress}
            title="Take Video"
          />
          <Button
            onPress={this.onEmbedButtonPress}
            title="Embed Text"
          />
          { this.renderInput() }
        </View>
      </View>
    );
    }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  image: {
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height/2,
  },
  input: {
    height: 20,
    width: 200,
    borderWidth: 0.5,
    borderColor: '#0f0f0f',
    borderRadius: 5,
    fontSize: 14,
    padding: 4,
  },
  video: {
    flex: 1,
    width: 200,
    height: 300
  }
});

AppRegistry.registerComponent('example', () => example);
