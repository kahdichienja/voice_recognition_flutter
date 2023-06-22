import 'dart:io';

abstract class BaseVoiceTrainer {
  Future<List<List<double>>> loadVoiceSamples(String userLabel);
  Future<List<double>> readVoiceSampleData(File voiceSampleFile);
  List<List<double>> extractFeatures(List<List<double>> voiceSamples);
  List<double> performFeatureExtraction(List<double> sample);
  List<String> createLabels(String userLabel, int numSamples);
  String classifySample(List<double> sample, List<List<double>> features, List<String> labels, int k);
  double calculateDistance(List<double> sample1, List<double> sample2);
  int findClosestMatch(List<List<double>> voiceSamples, List<double> inputSample, double threshold);
  Future<bool> voiceDidMach(String userLabel, {required List<double> input, List<List<double>>? voiceSamples});
}
