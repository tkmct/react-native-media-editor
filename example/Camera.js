import React, { Component } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions
} from 'react-native';
import Camera from 'react-native-camera';

class CameraView extends Component {
  constructor(props) {
    super(props);

    this.state = {
      recording: false
    }

    this.takeVideo = this.takeVideo.bind(this);
    this.renderButton = this.renderButton.bind(this);
  }

  takeVideo() {
    this.setState({recording: true});
    this.camera.capture()
      .then(data => {
        console.log(data);
        this.props.onVideoReturned(data);
      })
      .catch(err => console.error(err));

    setTimeout(() => {
      this.camera.stopCapture();
      this.props.endCapturing();
    }, 5000);
  }

  renderButton() {
    if (this.state.recording) {
      return (
        <Text style={styles.capture}>[Capturing]</Text>
      )
    } else {
      return (
        <Text style={styles.capture} onPress={this.takeVideo}>[Capture]</Text>
      )
    }
  }

  render() {
    return (
      <View style={styles.container}>
        <Camera
          ref={(cam) => {
            this.camera = cam;
          }}
          style={styles.preview}
          aspect={Camera.constants.Aspect.fill}
          captureMode={Camera.constants.CaptureMode.video}
        >
          {
            this.renderButton()
          }
        </Camera>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1
  },
  preview: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
    height: Dimensions.get('window').height,
    width: Dimensions.get('window').width
  },
  capture: {
    flex: 0,
    backgroundColor: '#fff',
    borderRadius: 5,
    color: '#000',
    padding: 10,
    margin: 40
  }
});

export default CameraView;
