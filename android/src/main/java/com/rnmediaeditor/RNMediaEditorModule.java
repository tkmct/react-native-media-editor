package com.rnmediaeditor;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNMediaEditorModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNMediaEditorModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNMediaEditor";
  }

  @ReactMethod
  public void echo(final String text) {
    System.out.println("Echo by Android module: " + text);
  }
}
