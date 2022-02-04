import 'dart:math';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

class WebRadio extends StatefulWidget {

  const WebRadio({Key? key}) : super(key: key);

  @override
  State<WebRadio> createState() => _WebRadioState();
}

class _WebRadioState extends State<WebRadio> {

final _audioPlayer = ja.AudioPlayer(
    handleInterruptions: false,
    androidApplyAudioAttributes: false,
    handleAudioSessionActivation: false,
  );
  
  @override
  void initState() {
    init();
    super.initState();
  }

  init(){
     AudioSession.instance.then((audioSession) async {
      await audioSession.configure(const AudioSessionConfiguration.speech());
      _handleInterruptions(audioSession);
      await _audioPlayer.setUrl("https://servidor18.brlogic.com:7436/live?type=.m3u");
    });
  }

  void _handleInterruptions(AudioSession audioSession) {

    bool playInterrupted = false;

    _audioPlayer.playingStream.listen((playing) {
      playInterrupted = false;
      if (playing) {
        audioSession.setActive(true);
      }
    });

    audioSession.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            if (audioSession.androidAudioAttributes!.usage == AndroidAudioUsage.game) {
              _audioPlayer.setVolume(_audioPlayer.volume / 2);
            }
            playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (_audioPlayer.playing) {
              _audioPlayer.stop();
              playInterrupted = true;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _audioPlayer.setVolume(min(1.0, _audioPlayer.volume * 2));
            playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
            if (playInterrupted) _audioPlayer.play();
            playInterrupted = false;
            break;
          case AudioInterruptionType.unknown:
            playInterrupted = false;
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       body: Center(
         child: StreamBuilder<ja.PlayerState>(
           stream: _audioPlayer.playerStateStream,
           builder: (context, snapshot) {
             final playerState = snapshot.data;
             print(playerState?.processingState);
             if (playerState?.processingState != ja.ProcessingState.ready && playerState?.processingState != ja.ProcessingState.idle){
               return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  child: const CircularProgressIndicator(),
                );
             } else {
               return playerState?.playing == true ? 
                 IconButton(
                   icon: const Icon(Icons.stop),
                   iconSize: 64.0,
                   onPressed: _audioPlayer.stop,
                 ) : 
                 IconButton(
                   icon: const Icon(Icons.play_arrow),
                   iconSize: 64.0,
                   onPressed: _audioPlayer.play,
                 );
             }
           },
         ),
       )
     ); 
  }
}

