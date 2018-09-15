package com.example.otsu;

import android.annotation.TargetApi;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;
import android.view.WindowManager;

import java.util.Dictionary;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity implements TextToSpeech.OnInitListener {
  private static String CHANNEL = "com.example.dragdropexample/tts";

  public TextToSpeech speaker;
  String toSpeak;

  public MainActivity ref = this;
  private final String tag = "TTS";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

      getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {

      @Override
      public void onMethodCall(MethodCall methodCall, Result result) {

        Map<String, Object> arguments =  methodCall.arguments();

        if (methodCall.method.equals("speak")) {

          toSpeak = (String) arguments.get("from");

          if (speaker == null)
          {
            //AudioManager am = (Android.Media.AudioManager) Plugin.CurrentActivity.CrossCurrentActivity.Current.Activity.GetSystemService(Android.Content.Context.AudioService);
            //int amStreamMusicMaxVol = am.GetStreamMaxVolume(Android.Media.Stream.Music);
            //am.SetStreamVolume(Android.Media.Stream.Music, amStreamMusicMaxVol, 0);
            speaker = new TextToSpeech(ref, ref);
          }
          else
          {
            SpeakRoute(toSpeak);
          }


          result.success(1);

        }
      }
    });
  }

  @Override
  public void onInit(int i)
  {
    if (i == TextToSpeech.SUCCESS)
    {
      SpeakRoute(toSpeak);
    }
  }

  private void SpeakRoute(String text)
  {
    if (speaker.isSpeaking()) return;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
    {
      ApiOver21(text);
    }
    else
    {
      ApiUnder20(text);
    }
  }

  @SuppressWarnings("deprecation")
  private void ApiUnder20(String text)
  {
    HashMap<String, String> map = new HashMap<>();
    map.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "MessageId");
    speaker.speak(text, TextToSpeech.QUEUE_FLUSH, map);
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  private void ApiOver21(String text)
  {
    String utteranceId=this.hashCode() + "";
    speaker.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId);
  }

  private UtteranceProgressListener utteranceProgressListener =
          new UtteranceProgressListener() {
              @Override
              public void onStart(String utteranceId) {
                  //channel.invokeMethod("speak.onStart", true);
              }

              @Override
              public void onDone(String utteranceId) {
                  //channel.invokeMethod("speak.onComplete", true);
              }

              @Override
              @Deprecated
              public void onError(String utteranceId) {
                  //channel.invokeMethod("speak.onError", "Error from TextToSpeech");
              }

              @Override
              public void onError(String utteranceId, int errorCode) {
                  //channel.invokeMethod("speak.onError", "Error from TextToSpeech - " + errorCode);
              }
          };

  private TextToSpeech.OnInitListener onInitListener = new TextToSpeech.OnInitListener() {
      @Override
      public void onInit(int status)
      {
          if (status == TextToSpeech.SUCCESS)
          {
              speaker.setOnUtteranceProgressListener(utteranceProgressListener);

              try
              {
                  speaker.setLanguage(Locale.US);
              }
              catch (NullPointerException e)
              {
                  Log.d(tag, "getDefaultVoice: " + e.getMessage() + " (known issue with API 21 & 22)");
              }
          } else {
              Log.d(tag, "Failed to initialize TextToSpeech");
          }
  }
};
}