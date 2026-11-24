import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'settings_service.dart';

enum Sfx { tap, place, correct, wrong, win, hint, reward, equation }

/// Sound effects + looping background music, both controlled from Settings.
class AudioService extends GetxService with WidgetsBindingObserver {
  static AudioService get to => Get.find();

  static const _files = {
    Sfx.tap: 'sounds/tap.wav',
    Sfx.place: 'sounds/place.wav',
    Sfx.correct: 'sounds/correct.wav',
    Sfx.wrong: 'sounds/wrong.wav',
    Sfx.win: 'sounds/win.wav',
    Sfx.hint: 'sounds/hint.wav',
    Sfx.reward: 'sounds/reward.wav',
    Sfx.equation: 'sounds/equation.wav',
  };

  final Map<Sfx, AudioPlayer> _players = {};
  final AudioPlayer _music = AudioPlayer(playerId: 'music');
  bool _musicStarted = false;

  SettingsService get _settings => SettingsService.to;

  Future<AudioService> init() async {
    WidgetsBinding.instance.addObserver(this);
    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
    for (final s in Sfx.values) {
      final p = AudioPlayer(playerId: 'sfx_${s.name}');
      await p.setPlayerMode(PlayerMode.lowLatency);
      await p.setReleaseMode(ReleaseMode.stop);
      _players[s] = p;
    }
    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(0.35);
    ever(_settings.music, (_) => syncMusic());
    syncMusic();
    return this;
  }

  void play(Sfx s) {
    if (!_settings.sfx.value) return;
    final p = _players[s];
    if (p == null) return;
    p.stop().then((_) => p.play(AssetSource(_files[s]!), volume: 0.8)).catchError((_) {});
  }

  Future<void> syncMusic() async {
    try {
      if (_settings.music.value) {
        if (!_musicStarted) {
          await _music.play(AssetSource('sounds/music.wav'));
          _musicStarted = true;
        } else {
          await _music.resume();
        }
      } else {
        await _music.pause();
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _music.pause().catchError((_) {});
    } else if (state == AppLifecycleState.resumed) {
      syncMusic();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final p in _players.values) {
      p.dispose();
    }
    _music.dispose();
    super.onClose();
  }
}
