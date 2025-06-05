import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String url) async {
    await _player.setUrl(url);
    _player.play();
  }

  static void pause() => _player.pause();
  static void stop() => _player.stop();
  static AudioPlayer get player => _player;
}
