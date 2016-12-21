/**
* Sample React Native App
* https://github.com/facebook/react-native
* @flow
*/

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Image,
  Button,
  Dimensions,
  Platform
} from 'react-native';
import ImagePicker from 'react-native-image-picker';
import RNMediaEditor from 'react-native-media-editor';


var options = {
  title: 'Select Avatar',
  customButtons: [
    {name: 'fb', title: 'Choose Photo from Facebook'},
  ],
  storageOptions: {
    skipBackup: true,
    path: 'images'
  }
};

/**
* The first arg is the options object for customization (it can also be null or omitted for default options),
* The second arg is the callback which sends object: response (more info below in README)
*/

export default class example extends Component {
  constructor(props) {
    super(props);

    this.state = {
      photo: null,
      video: null,
      text: 'Text embedded',
    };

    this.onButtonPress = this.onButtonPress.bind(this);
    this.onEmbedButtonPress = this.onEmbedButtonPress.bind(this);
    this.renderImage = this.renderImage.bind(this);
  }

  componentWillMount() {
    RNMediaEditor.echo("Hello RNMediaEditor");
  }

  onButtonPress() {
    RNMediaEditor.echo("Button pressed");
    ImagePicker.showImagePicker(options, (response) => {
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
        // You can display the image using either data...
        const source = {uri: 'data:image/jpeg;base64,' + response.data, isStatic: true};

        // or a reference to the platform specific asset location
        if (Platform.OS === 'ios') {
          const source = {uri: response.uri.replace('file://', ''), isStatic: true};
        } else {
          const source = {uri: response.uri, isStatic: true};
        }

        this.setState({
          photo: source
        });
      }
    });
  }

  onEmbedButtonPress() {
    const {text, photo} = this.state;
    if (photo) {
      console.log(text, photo);
      // RNMediaEditor.embedTextToImage(photo, text);
    }
  }

  renderImage() {
    if (this.state.photo) {
      return (
        <Image
          style={styles.image}
          source={this.state.photo}
        />
      )
    } else {
      return;
    }
  }

  render() {
    return (
      <View style={styles.container}>
        { this.renderImage() }
        <Button
          onPress={this.onButtonPress}
          title="Pick Image"
        />
        <Button
          onPress={this.onEmbedButtonPress}
          title="Embed Text"
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  image: {
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height/2,
  }
});

AppRegistry.registerComponent('example', () => example);
