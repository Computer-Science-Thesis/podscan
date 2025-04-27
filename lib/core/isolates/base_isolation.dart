import 'dart:isolate';
import 'package:flutter/services.dart';

abstract class BaseIsolateParams {
  final String imagePath;
  final String? modelPath;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  BaseIsolateParams({
    required this.imagePath,
    required this.modelPath,
    required this.sendPort,
    required this.rootIsolateToken,
  });
}

Future<void> handleIsolateInference<T>({
  required T params,
  required Future<Map<String, dynamic>> Function(T params) runModelInference,
}) async {
  if (params is BaseIsolateParams) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);

    if (params.modelPath == null) {
      params.sendPort.send({'error': 'Model path is null'});
    }

    final stopWatch = Stopwatch()..start();
    final results = await runModelInference(params);
    stopWatch.stop();

    results['elapsedMilliseconds'] = stopWatch.elapsedMilliseconds;
    params.sendPort.send(results);
  }
}

class InferenceIsolate<T> {
  final Future<Map<String, dynamic>> result;
  final Isolate isolate;

  InferenceIsolate({required this.result, required this.isolate});

  void stop() {
    isolate.kill(priority: Isolate.immediate);
  }
}

Future<InferenceIsolate<T>> runInferenceInIsolate<T>({
  required T Function(SendPort sendPort) createParams,
  required void Function(T) isolateEntry
}) async {
  final receivePort = ReceivePort();
  final params = createParams(receivePort.sendPort);

  final isolate = await Isolate.spawn<T>(isolateEntry, params);
  final resultFuture = receivePort.first.then((value) {
    receivePort.close();
    return value as Map<String, dynamic>;
  });

  return InferenceIsolate(result: resultFuture, isolate: isolate);
}