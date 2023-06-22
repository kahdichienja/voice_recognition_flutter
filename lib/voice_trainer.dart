import 'dart:io';
import 'dart:math';

import 'package:ml_linalg/linalg.dart';

import 'base_voice_tainer.dart';

class VoiceTrainer implements BaseVoiceTrainer {
  final String voiceDirectory;
  final int numVoiceSamples;
  final int numFeatures;

  VoiceTrainer(this.voiceDirectory, this.numVoiceSamples, this.numFeatures);

  @override
  Future<List<List<double>>> loadVoiceSamples(String userLabel) async {
    final voiceSamples = <List<double>>[];

    for (var i = 1; i <= numVoiceSamples; i++) {
      final voiceSampleFile = File('$voiceDirectory${userLabel}_$i.wav');
      final voiceSampleData = await readVoiceSampleData(voiceSampleFile);
      voiceSamples.add(voiceSampleData);
    }

    return voiceSamples;
  }

  @override
  Future<List<double>> readVoiceSampleData(File voiceSampleFile) async {
    final bytes = await voiceSampleFile.readAsBytes();
    final voiceData = bytes.map((byte) => byte.toDouble()).toList();
    return voiceData;
  }

  @override
  List<List<double>> extractFeatures(List<List<double>> voiceSamples) {
    final features = <List<double>>[];

    for (var sample in voiceSamples) {
      final extractedFeatures = performFeatureExtraction(sample);
      features.add(extractedFeatures);
    }

    return features;
  }

  @override
  List<double> performFeatureExtraction(List<double> sample) {

    final features = <double>[];

    final vector = Vector.fromList(sample);
    // Calculate the mean
    final mean = vector.reduce((a, b) => a + b) / vector.length;
    features.add(mean);

    // Calculate the standard deviation
    final squaredDifferences = sample.map((value) => pow(value - mean, 2));
    final variance = squaredDifferences.reduce((a, b) => a + b) / sample.length;
    final std = sqrt(variance);
    features.add(std);

    return features;
  }

  @override
  List<String> createLabels(String userLabel, int numSamples) {
    final labels = <String>[];

    for (var i = 1; i <= numSamples; i++) {
      labels.add(userLabel);
    }

    return labels;
  }

  @override
  String classifySample(List<double> sample, List<List<double>> features,
      List<String> labels, int k) {
    final distances = <double, String>{};

    for (var i = 0; i < features.length; i++) {
      final feature = features[i];
      final label = labels[i];
      final distance = calculateDistance(sample, feature);
      distances[distance] = label;
    }

    final sortedDistances = distances.keys.toList()..sort();
    final kNearestLabels =
        sortedDistances.sublist(0, k).map((d) => distances[d]).toList();

    final labelCounts = <String, int>{};

    for (var label in kNearestLabels) {
      if (labelCounts.containsKey(label)) {
        labelCounts[label!] = labelCounts[label]! + 1;
      } else {
        labelCounts[label!] = 1;
      }
    }

    final mostCommonLabel =
        labelCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return mostCommonLabel;
  }

  @override
  double calculateDistance(List<double> sample1, List<double> sample2) {
    // Calculate the Euclidean distance between two samples
    final diff = Vector.fromList(sample1) - Vector.fromList(sample2);
    return diff.norm();
  }

  @override
  int findClosestMatch(List<List<double>> voiceSamples, List<double> inputSample, double threshold) {
    final inputFeatures = performFeatureExtraction(inputSample);

    // Pad the input features with zeros to match the length of the extracted features
    final paddedInputFeatures = List<double>.filled(voiceSamples[0].length, 0);
    paddedInputFeatures.setRange(0, inputFeatures.length, inputFeatures);

    double minDistance = double.infinity;
    int closestMatchIndex = -1;

    for (var i = 0; i < voiceSamples.length; i++) {
      final distance = calculateDistance(paddedInputFeatures, voiceSamples[i]);

      if (distance < minDistance) {
        minDistance = distance;
        closestMatchIndex = i;
      }
    }

    if (minDistance <= threshold) {
      return closestMatchIndex;
    } else {
      return -1; // No match found
    }
  }

  @override
  Future<bool> voiceDidMach(String userLabel,{required List<double> input, List<List<double>>? voiceSamples}) async {
    // List<List<double>>? _voiceSamples;

    // if (voiceSamples != null) {
      // _voiceSamples = voiceSamples;
    // } else {
    //   _voiceSamples = await loadVoiceSamples(userLabel);
    // }

    final features = extractFeatures(voiceSamples!);

    final matchIndex = findClosestMatch(features, input, 0.5);

    if (matchIndex != -1) {
      return true;
    } else {
      return false;
    }
  }
}
