import 'package:cloud_functions/cloud_functions.dart';

class GeminiService {
  final FirebaseFunctions functions;

  GeminiService({FirebaseFunctions? functions})
    : functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<String> sendPrompt(String prompt) async {
    try {
      final callable = functions.httpsCallable('chatWithGemini');
      final result = await callable.call(<String, dynamic>{'prompt': prompt});
      return result.data['reply'] as String;
    } on FirebaseFunctionsException catch (e) {
      return 'Error: ${e.code} ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
