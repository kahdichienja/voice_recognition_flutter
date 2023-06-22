import 'package:flutter/material.dart';
import 'package:voicerecog/voice_recognizer.dart';
import 'package:voicerecog/voice_trainer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Recognition Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Voice Recognition Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _voicematched = "";

  List<List<double>> prerecorded = [[]];
  List<List<double>> samples = [];

  final voiceRecognizer = VoiceRecognizer();
  void _incrementCounter() async {
    final sample = await voiceRecognizer.recordVoiceSample(
        duration: const Duration(seconds: 1));

    print('Recorded voice sample with ${sample!.length} samples');
    // debugPrint('Recorded === ${sample} ===== ');

    setState(() {
      prerecorded.add(sample);
      removeEmptyLists(prerecorded);
    });

    print("prerecorded ${prerecorded}");
    print("prerecorded ${prerecorded.length}");
  }

  List<List<double>> removeEmptyLists(List<List<double>> inputList) {
    return inputList.where((list) => list.isNotEmpty).toList();
  }

  void predicte() async {
    const String voiceDirectory = 'voice_samples/';
    const int numVoiceSamples = 5;
    const int numFeatures = 10;
    const userLabel = 'user1';
    final l = removeEmptyLists(prerecorded);

    print(l.runtimeType);
    print(l.first.runtimeType);
    print(l.first);
    final voiceTrainer = VoiceTrainer(voiceDirectory, numVoiceSamples, numFeatures);

    final matchIndex = await voiceTrainer.voiceDidMach(
      userLabel,
      voiceSamples: l,
      input: l.first,
    );

    if (matchIndex) {
      setState(() => _voicematched = "Yes");
    } else {
      setState(() => _voicematched = "No");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'Input ${prerecorded.first.toString()}',
            // ),
            // Text(
            //   'Sample  ${prerecorded.remove(prerecorded.first).toString()}?',
            // ),
            const Text(
              'Voice Matched?',
            ),
            Text(
              _voicematched,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => setState(() => prerecorded.clear()),
            tooltip: 'Increment',
            label: const Icon(Icons.refresh),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton.extended(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            label: const Icon(Icons.mic),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton.extended(
            onPressed: predicte,
            tooltip: 'Increment',
            label: const Icon(Icons.precision_manufacturing),
          ),
        ],
      ),
    );
  }
}
