// import 'dart:typed_data';

// import 'package:http/http.dart' as http;
// import 'package:record/record.dart';

// class AudioRecordingService {
//   final AudioRecorder _recorder = AudioRecorder();

//   // ------------------------------------------------------------
//   // CHECK MICROPHONE PERMISSION
//   // ------------------------------------------------------------

//   Future<bool> initialize() async {
//     return await _recorder.hasPermission();
//   }

//   // ------------------------------------------------------------
//   // START RECORDING
//   // ------------------------------------------------------------

//   Future<void> startRecording() async {
//     final hasPermission =
//         await _recorder.hasPermission();

//     if (!hasPermission) {
//       throw Exception(
//         'Microphone permission not granted.',
//       );
//     }

//     await _recorder.start(
//       const RecordConfig(
//         encoder: AudioEncoder.wav,
//         sampleRate: 16000,
//         numChannels: 1,
//       ),
//       path: 'ai_companion_input.wav',
//     );
//   }

//   // ------------------------------------------------------------
//   // STOP RECORDING
//   // ------------------------------------------------------------

//   Future<String?> stopRecording() async {
//     return await _recorder.stop();
//   }

//   // ------------------------------------------------------------
//   // GET ACTUAL AUDIO BYTES
//   // ------------------------------------------------------------
//   //
//   // On Flutter Web, record() returns a Blob URL.
//   // We download that Blob URL and convert it to bytes.
//   // ------------------------------------------------------------

//   Future<Uint8List?> getRecordedAudio(
//     String? path,
//   ) async {
//     if (path == null || path.isEmpty) {
//       return null;
//     }

//     final response =
//         await http.get(Uri.parse(path));

//     if (response.statusCode != 200) {
//       throw Exception(
//         'Could not read recorded audio. '
//         'Status: ${response.statusCode}',
//       );
//     }

//     return response.bodyBytes;
//   }

//   // ------------------------------------------------------------
//   // CANCEL RECORDING
//   // ------------------------------------------------------------

//   Future<void> cancelRecording() async {
//     await _recorder.cancel();
//   }

//   // ------------------------------------------------------------
//   // DISPOSE
//   // ------------------------------------------------------------

//   void dispose() {
//     _recorder.dispose();
//   }
// }

import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:record/record.dart';

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> initialize() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) {
      throw Exception('Microphone permission not granted.');
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: 'ai_companion_input.wav',
    );
  }

  Future<Uint8List?> stopRecording() async {
    final path = await _recorder.stop();

    if (path == null || path.isEmpty) {
      return null;
    }

    // On Flutter Web, the recorder returns a browser blob URL.
    // We convert that recorded audio into actual bytes.
    final response = await http.get(
      Uri.parse(path),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to read recorded audio: ${response.statusCode}',
      );
    }

    return response.bodyBytes;
  }

  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  void dispose() {
    _recorder.dispose();
  }
}