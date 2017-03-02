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
import android.support.annotation.RequiresPermission;
import android.support.annotation.StringDef;
import android.util.Log;
import android.util.Base64;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
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
  public void embedText(final ReadableMap options, Promise promise) {
    String type = options.getString("type");
    if (type.equals("image")) {
      Log.d("Example", "RNMediaeditor embed text on image called");
      embedTextOnImage(options, promise);
    } else if (type.equals("video")) {
      embedTextOnVideo(options, promise);
    }
  }

  private void embedTextOnImage(final ReadableMap options, final Promise promise) {
    String path = options.getString("path");
    ReadableMap firstText = options.getMap("firstText");

    File img = new File(path);

    if (img.exists()) {
      // create base bitmap of input file
      Bitmap bitmap = BitmapFactory.decodeFile(path);
      Bitmap.Config bitmapConfig = bitmap.getConfig();

      Log.d("example", "bytes:" + Integer.toString(bitmap.getByteCount()));
      // set default config if config is none
      if (bitmapConfig == null) {
        bitmapConfig = Bitmap.Config.ARGB_8888;
      }

      bitmap = bitmap.copy(bitmapConfig, true);
      Canvas canvas = new Canvas(bitmap);

      String backgroundColor = firstText.getString("backgroundColor");
      float backgroundOpacity = (float) (firstText.getDouble("backgroundOpacity"));

      // draw text container container
      Paint containerPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
      containerPaint.setColor(Color.parseColor(backgroundColor));
      containerPaint.setStyle(Paint.Style.FILL);
      int opacity = (int) (255 * backgroundOpacity);
      containerPaint.setAlpha(opacity);

      String fontColor = firstText.getString("fontColor");
      int fontSize = firstText.getInt("fontSize");
      String text = firstText.getString("text");

      // draw text Paint
      Paint textPaint = new Paint();
      textPaint.setColor(Color.parseColor(fontColor));

      // convert pixel to sp
      float scaledDensity = _reactContext.getResources().getDisplayMetrics().scaledDensity;
//      textPaint.setTextSize(fontSize/scaledDensity);
      textPaint.setTextSize(fontSize);
      float textSize = textPaint.getTextSize();
      float containerWidth = textPaint.measureText(text) + textSize * 2;

      int top = firstText.getInt("top");
      int left = firstText.getInt("left");
      // draw paint in canvas
      canvas.drawRect(left, top, left + containerWidth, top + textSize * 2, containerPaint); // left, top, right, bottom
      canvas.drawText(text, left + textSize, top + textSize * 4 / 3, textPaint);


      int bytes = bitmap.getByteCount();
      ByteBuffer buffer = ByteBuffer.allocate(bytes);
      bitmap.copyPixelsToBuffer(buffer);

      // Save into Camera Roll
      String uri = MediaStore.Images.Media.insertImage(_reactContext.getContentResolver(), bitmap, "", "");

      byte[] data = buffer.array();
      String dataString = new String(data);

      File out = getOutputFile(TYPE_IMAGE);

      writeDataToFile(data, out);

      promise.resolve(out.getAbsolutePath());
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


    if (type == TYPE_IMAGE) {
      fileName = String.format("IMG_%s.jpg", fileName);
    } else if (type == TYPE_VIDEO) {
      fileName = String.format("VID_%s.mp4", fileName);
    } else {
      Log.e(TAG, "Unsupported media type:" + type);
      return null;
    }
    Log.d("example", String.format("%s%s%s", storageDir.getPath(), File.separator, fileName));

    return new File(String.format("%s%s%s", storageDir.getPath(), File.separator, fileName));
  }


  public void embedTextOnVideo(ReadableMap options, Promise promise) {
    FFmpeg ffmpeg = FFmpeg.getInstance(_reactContext);
    try {
      ffmpeg.loadBinary(new LoadBinaryResponseHandler() {

        @Override
        public void onStart() {
        }

        @Override
        public void onFailure() {
        }

        @Override
        public void onSuccess() {
        }

        @Override
        public void onFinish() {
        }
      });
    } catch (FFmpegNotSupportedException e) {
      // Handle if FFmpeg is not supported by device
    }

    String path = options.getString("path");
    ReadableMap firstText = options.getMap("firstText");
    String text = firstText.getString("text");
    String fontColor = firstText.getString("textColor");
    String backgroundColor = firstText.getString("backgroundColor");
    int fontSize = firstText.getInt("fontSize");
    float backgroundOpaciy = (float)firstText.getDouble("backgroundOpacity");
    File out = getOutputFile(TYPE_VIDEO);

    String[] cmd = new String[] {
            "-i", path, "-filter_complex", "drawtext=fontfile=/system/fonts/DroidSans.ttf:text=" +
            text + ":x=(w-text_w)/2:y=(h-text_h-line_h)/2" +":fontcolor=" + fontColor + ":fontsize=" + fontSize +
            ":box=1:boxcolor="+backgroundColor+"@"+backgroundOpaciy+":boxborderw="+(fontSize/2), out.getAbsolutePath()
    };

    try {
      // to execute "ffmpeg -version" command you just need to pass "-version"
      ffmpeg.execute(cmd, new ExecuteBinaryResponseHandler() {

        @Override
        public void onStart() {
          Log.d("example", "start ffmpeg");
        }

        @Override
        public void onProgress(String message) {
          Log.d("example", "onProgress: " + message);
        }

        @Override
        public void onFailure(String message) {
          Log.e("example", "Error ffmpeg executing with message:\n\t" + message);
        }

        @Override
        public void onSuccess(String message) {
          Log.d("example", "Successfully output file with message:\n\t");
        }

        @Override
        public void onFinish() {
        }
      });
    } catch (FFmpegCommandAlreadyRunningException e) {
      // Handle if FFmpeg is already running
    }
  }

}
