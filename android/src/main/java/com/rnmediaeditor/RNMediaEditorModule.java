package com.rnmediaeditor;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.github.hiteshsondhi88.libffmpeg.ExecuteBinaryResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.FFmpeg;
import com.github.hiteshsondhi88.libffmpeg.LoadBinaryResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.exceptions.FFmpegCommandAlreadyRunningException;
import com.github.hiteshsondhi88.libffmpeg.exceptions.FFmpegNotSupportedException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Date;


public class RNMediaEditorModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext _reactContext;
  private static final String TAG = "RNMediaEditorModule";

  public static final int TYPE_IMAGE = 1;
  public static final int TYPE_VIDEO = 2;

  public RNMediaEditorModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this._reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNMediaEditor";
  }



  @ReactMethod
  public void embedTextOnImage(String text, String path, int fontSize, String fontColor, Callback successCallback, Callback errorCallback) {
    // Create image bitmap from uri
    File img = new File(path);

    if (img.exists()) {
      Bitmap bitmap = BitmapFactory.decodeFile(path);
      Bitmap.Config bitmapConfig = bitmap.getConfig();
      // set default config if config is none
      if (bitmapConfig == null) {
        bitmapConfig = Bitmap.Config.ARGB_8888;
      }

      bitmap = bitmap.copy(bitmapConfig, true);
      Canvas canvas = new Canvas(bitmap);
      Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
      paint.setColor(Color.parseColor(fontColor));
      // TODO set fontSize in pixel
      paint.setTextSize((int)(12 * fontSize));

      // draw text to the Center of Canvas
      Rect bounds = new Rect();
      paint.getTextBounds(text, 0, text.length(), bounds);
      int x = (bitmap.getWidth() - bounds.width()) / 6;
      int y = (bitmap.getHeight() - bounds.height()) / 5;
      canvas.drawText(text, x , y, paint);

      int bytes = bitmap.getByteCount();

      ByteBuffer buffer = ByteBuffer.allocate(bytes);
      bitmap.copyPixelsToBuffer(buffer);

      // Save into Camera Roll
      String uri = MediaStore.Images.Media.insertImage(_reactContext.getContentResolver(), bitmap, "", "");

//
//      byte[] data = buffer.array();
//
//
//      File out = getOutputFile(TYPE_IMAGE);
//
//      writeDataToFile(data, out);

      successCallback.invoke(uri);
    }
  }

  @ReactMethod
  public void embedTextOnVideo(String text, String path, int fontSize, String fontColor, final Callback successCallback, final Callback errorCallback) {
    FFmpeg ffmpeg = FFmpeg.getInstance(_reactContext);
    try {
      ffmpeg.loadBinary(new LoadBinaryResponseHandler() {

        @Override
        public void onStart() {}

        @Override
        public void onFailure() {}

        @Override
        public void onSuccess() {}

        @Override
        public void onFinish() {}
      });
    } catch (FFmpegNotSupportedException e) {
      // Handle if FFmpeg is not supported by device
    }

    File out = getOutputFile(TYPE_VIDEO);

//    String[] cmd = new String[] {
//            "-i", path, "-vf",
//            String.format("drawtext=\"fontfile=/systems/fonts/DroidSans.ttf: text='%s': " +
//                    "box=1: boxcolor=black@0.5: boxborder=5: x=(w-text_w)/t: y=(h-text_h)/2\"", text),
//            "-codec:a", "aac", out.getAbsolutePath()
//    };
    String[] cmd = new String[] {
            "-i", path, "-ss", "30", "-c", "copy", "-t", "10", out.getAbsolutePath()
    };

    try {
      // to execute "ffmpeg -version" command you just need to pass "-version"
      ffmpeg.execute(cmd, new ExecuteBinaryResponseHandler() {

        @Override
        public void onStart() {}

        @Override
        public void onProgress(String message) {}

        @Override
        public void onFailure(String message) {
          errorCallback.invoke("Error ffmpeg executing with message:\n\t" + message);
        }

        @Override
        public void onSuccess(String message) {
          successCallback.invoke("Successfully output file with message:\n\t");
        }

        @Override
        public void onFinish() {}
      });
    } catch (FFmpegCommandAlreadyRunningException e) {
      // Handle if FFmpeg is already running
    }


  }

  @Nullable
  private Throwable writeDataToFile(byte[] data, File file) {
    try {
      FileOutputStream fos = new FileOutputStream(file);
      fos.write(data);
      fos.close();
    } catch (FileNotFoundException e) {
      return e;
    } catch (IOException e) {
      return e;
    }

    return null;
  }

  @Nullable
  private File getOutputFile(int type) {
    File storageDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM);

    // Create storage dir if it does not exist
    if (!storageDir.exists()) {
      if (!storageDir.mkdirs()) {
        Log.e(TAG, "Failed to create directory:" + storageDir.getAbsolutePath());
        return null;
      }
    }

    // media file name
    String fileName = String.format("%s", new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()));


    if (type == TYPE_IMAGE){
      fileName = String.format("IMG_%s.jpg", fileName);
    } else if (type == TYPE_VIDEO) {
      fileName = String.format("VID_%s.mp4", fileName);
    } else {
      Log.e(TAG, "Unsupported media type:" + type);
      return null;
    }

    return new File(String.format("%s%s%s", storageDir.getPath(), File.separator, fileName));
  }


}
