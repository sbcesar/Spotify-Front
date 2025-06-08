import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../Model/Cancion.dart';


class AudioPlayerViewModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  String? _currentPlayingId;
  bool _isLoading = false;

  String? get currentPlayingId => _currentPlayingId;
  bool get isPlaying => _player.playing;
  bool get isLoading => _isLoading;

  Future<void> togglePlay(Cancion cancion) async {
    if (_currentPlayingId == cancion.id && _player.playing) {
      await _player.pause();
    } else {
      _currentPlayingId = cancion.id;
      await _player.setUrl(cancion.audioUrl!);
      await _player.play();
    }
    notifyListeners();
  }

  void stop() {
    _player.stop();
    _currentPlayingId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
