package com.example.otsu;

import android.annotation.TargetApi;
import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.View;
import android.view.WindowManager;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static String CHANNEL = "com.example.otsu/tts";

    public TextToSpeech speaker;
    String toSpeak;

    private final String tag = "TTS";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        View decorView = getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_IMMERSIVE;
        decorView.setSystemUiVisibility(uiOptions);

        speaker = new TextToSpeech(MainActivity.this, new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status == TextToSpeech.SUCCESS) {
                    int result = speaker.setLanguage(Locale.US);

                    if (result==TextToSpeech.LANG_MISSING_DATA || result==TextToSpeech.LANG_NOT_SUPPORTED) {
                        System.out.println("This Language is not supported");
                    }
                }
                else {
                    System.out.println("Initialization Failed");
                }
            }
        });

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
                @Override
                public void onMethodCall(MethodCall methodCall, Result result) {

                    Map<String, Object> arguments =  methodCall.arguments();

                    toSpeak = (String) arguments.get("output");

                    if (methodCall.method.equals("speak"))
                    {
                        SpeakRoute(toSpeak);
                    }
                    else
                    {
                        result.notImplemented();
                    }
                }
            }
        );
    }

    private void SpeakRoute(String text) {
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
}