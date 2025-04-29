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

Future<Map<String, dynamic>> runInferenceInIsolate<T>({
  required T Function(SendPort sendPort) createParams,
  required void Function(T) isolateEntry,
}) async {
  final receivePort = ReceivePort();
  final params = createParams(receivePort.sendPort);
  await Isolate.spawn<T>(isolateEntry, params);
  return await receivePort.first as Map<String, dynamic>;
}