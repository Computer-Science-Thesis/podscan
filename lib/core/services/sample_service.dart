class SampleService {
  Future<void> load() async {
    await Future.delayed(Duration(seconds: 10));
  }
}