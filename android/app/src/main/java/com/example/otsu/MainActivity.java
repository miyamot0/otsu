package com.example.otsu;

import android.os.Bundle;
import android.view.WindowManager;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }
}

/*
public class MainActivity extends FlutterActivity implements TextToSpeech.OnInitListener {
    private static String CHANNEL = "com.example.otsu/tts";

    public TextToSpeech speaker;
    String toSpeak;

    public MainActivity ref = this;
    private final String tag = "TTS";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        speaker = new TextToSpeech(ref, ref);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, Result result) {
                Map<String, Object> arguments =  methodCall.arguments();
                Toast.makeText(getApplicationContext(),"Pre-text",Toast.LENGTH_SHORT).show();

                if (methodCall.method.equals("speak"))
                {
                    Toast.makeText(getApplicationContext(),"In call",Toast.LENGTH_SHORT).show();

                    toSpeak = (String) arguments.get("from");

                    if (speaker == null)
                    {
                        Toast.makeText(getApplicationContext(),"Was Null",Toast.LENGTH_SHORT).show();

                        //AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
                        //audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 20, 0);

                    }
                    else
                    {
                        Toast.makeText(getApplicationContext(),"Was Not Null",Toast.LENGTH_SHORT).show();

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
        Toast.makeText(getApplicationContext(),"ApiUnder20",Toast.LENGTH_SHORT).show();

        HashMap<String, String> map = new HashMap<>();
        map.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "MessageId");
        speaker.speak(text, TextToSpeech.QUEUE_FLUSH, map);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void ApiOver21(String text)
    {
        Toast.makeText(getApplicationContext(),"ApiOver21",Toast.LENGTH_SHORT).show();

        String utteranceId=this.hashCode() + "";
        speaker.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId);
    }
}
*/