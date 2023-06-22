import 'dart:async';
import 'dart:io';
import 'package:flutter_sound_record/flutter_sound_record.dart';

class VoiceRecognizer {
  Future<List<double>?> recordVoiceSample(
      {Duration duration = const Duration(seconds: 5)}) async {
    final completer = Completer<List<double>>();
    final FlutterSoundRecord recorder = FlutterSoundRecord();

    try {
      if (await recorder.hasPermission()) {
        recorder.start();

        Timer(duration, () async {
          final String? path = await recorder.stop();

          // Read the recorded audio file
          final audioData = await File(path!).readAsBytes();

          // Convert the audio data to a list of doubles with normalization
          final voiceSamples = audioData.map((sample) => sample / 32768.0).toList();

          // Resolve the completer with the voice samples
          completer.complete(voiceSamples);
        });

        return completer.future;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
