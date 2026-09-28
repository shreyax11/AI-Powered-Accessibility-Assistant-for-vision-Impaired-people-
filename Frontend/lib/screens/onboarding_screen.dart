import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/onboarding_flow.dart';
import '../services/audio_recording_service.dart';
import '../services/speech_api_service.dart';
import '../services/tts_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TtsService _ttsService = TtsService();
  final AudioRecordingService _audioService = AudioRecordingService();
  final SpeechApiService _speechApiService = SpeechApiService();
  final OnboardingFlow _flow = OnboardingFlow();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _textFocusNode = FocusNode();

  bool _started = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  String _status = 'Tap anywhere or press Enter once to begin.';

  @override
  void initState() {
    super.initState();

    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyboardFocusNode.dispose();
    _textFocusNode.dispose();
    _audioService.dispose();

    super.dispose();
  }

  // ============================================================
  // START COMPANION
  // ============================================================

  Future<void> _startCompanion() async {
    // VERY IMPORTANT:
    // Prevent the conversation from starting more than once.
    if (_started) {
      return;
    }

    _started = true;

    _setStatus('Starting AI Companion...');

    try {
      await _ttsService.initialize();

      final microphoneReady = await _audioService.initialize();

      if (!microphoneReady) {
        _started = false;

        _setStatus(
          'Microphone permission is required. '
          'Please allow microphone access and try again.',
        );

        await _speak(
          'Microphone permission is required. '
          'Please allow microphone access and try again.',
        );

        return;
      }

      await _askLanguage();
    } catch (e) {
      _started = false;

      _setStatus('Unable to start the assistant.');

      debugPrint('Start companion error: $e');
    }
  }

  // ============================================================
  // ASK LANGUAGE
  // ============================================================

  Future<void> _askLanguage() async {
    if (!mounted) {
      return;
    }

    _flow.moveTo(OnboardingStep.askLanguage);

    await _speak(
      'Welcome to AI Companion. '
      'I am here to help you. '
      'Let us get started.',
    );

    if (!mounted) {
      return;
    }

    await _speak(
      'Are you comfortable with this language? '
      'If no, then tell me your language.',
    );

    if (!mounted) {
      return;
    }

    await _startListening();
  }

  // ============================================================
  // SPEAK
  // ============================================================

  Future<void> _speak(
    String text, {
    String language = 'en-US',
  }) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSpeaking = true;
      _isListening = false;
      _status = 'Speaking...';
    });

    try {
      await _ttsService.speak(
        text,
        language: language,
      );
    } catch (e) {
      debugPrint('TTS error: $e');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSpeaking = false;
      _status = 'Listening...';
    });
  }

  // ============================================================
  // AUTOMATIC RECORDING
  // ============================================================

  Future<void> _startListening() async {
    if (!mounted) {
      return;
    }

    if (_isListening || _isProcessing || _isSpeaking) {
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _status = 'Listening...';
      });

      await _audioService.startRecording();

      // Recording window for the current prototype.
      await Future.delayed(
        const Duration(seconds: 5),
      );

      if (!mounted) {
        return;
      }

      await _finishListening();
    } catch (e) {
      debugPrint('Recording error: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _status = 'Microphone could not be started.';
      });
    }
  }

  // ============================================================
  // STOP RECORDING AND SEND TO BACKEND
  // ============================================================

  Future<void> _finishListening() async {
    if (!_isListening) {
      return;
    }

    setState(() {
      _isListening = false;
      _isProcessing = true;
      _status = 'Processing...';
    });

    try {
      final audioBytes = await _audioService.stopRecording();

      if (audioBytes == null || audioBytes.isEmpty) {
        throw Exception('No audio was recorded.');
      }

      final result = await _speechApiService.convertSpeechToText(
        audioBytes,
      );

      if (!mounted) {
        return;
      }

      final text = result['text']?.toString().trim() ?? '';

      if (text.isEmpty) {
        setState(() {
          _isProcessing = false;
          _status = 'I could not hear anything.';
        });

        await _speak(
          'I could not hear anything. '
          'Please try again.',
        );

        return;
      }

      await _handleUserInput(text);
    } catch (e) {
      debugPrint('Voice processing error: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
        _status = 'Voice processing is not connected yet.';
      });

      // IMPORTANT:
      // Do NOT restart listening here.
      //
      // This prevents the infinite speaking/listening loop
      // when Flask is not running on this laptop.
    }
  }

  // ============================================================
  // HANDLE USER INPUT
  // ============================================================

  Future<void> _handleUserInput(String text) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Understanding...';
    });

    final currentStep = _flow.currentStep;

    switch (currentStep) {
      case OnboardingStep.askLanguage:
        await _handleLanguage(text);
        break;

      case OnboardingStep.confirmHindi:
        await _handleHindiConfirmation(text);
        break;

      case OnboardingStep.languageSet:
        await _askName();
        break;

      case OnboardingStep.askName:
        await _handleName(text);
        break;

      case OnboardingStep.confirmName:
        await _handleNameConfirmation(text);
        break;

      case OnboardingStep.welcome:
        await _askLanguage();
        break;

      case OnboardingStep.completed:
        await _handleAfterOnboarding(text);
        break;
    }
  }

  // ============================================================
  // LANGUAGE
  // ============================================================

  Future<void> _handleLanguage(String text) async {
    final lowerText = text.toLowerCase();

    final isHindi =
        lowerText.contains('hindi') ||
        lowerText.contains('हिंदी');

    if (isHindi) {
      _flow.setLanguage('Hindi');

      _flow.moveTo(
        OnboardingStep.confirmHindi,
      );

      _isProcessing = false;

      await _speak(
        'क्या आप हिंदी भाषा से सहमत हैं?',
        language: 'hi-IN',
      );

      await _startListening();

      return;
    }

    _flow.setLanguage(text);

    _flow.moveTo(
      OnboardingStep.languageSet,
    );

    _isProcessing = false;

    await _speak(
      'Your preferred language has been set.',
    );

    await _askName();
  }

  // ============================================================
  // HINDI CONFIRMATION
  // ============================================================

  Future<void> _handleHindiConfirmation(String text) async {
    final lowerText = text.toLowerCase();

    final confirmed =
        lowerText.contains('yes') ||
        lowerText.contains('haan') ||
        lowerText.contains('han') ||
        lowerText.contains('हाँ') ||
        lowerText.contains('हां') ||
        lowerText.contains('जी') ||
        lowerText.contains('yes');

    if (confirmed) {
      _flow.setLanguage('Hindi');

      _flow.moveTo(
        OnboardingStep.languageSet,
      );

      _isProcessing = false;

      await _speak(
        'आपकी आम भाषा हिंदी सेट कर दी गई है।',
        language: 'hi-IN',
      );

      await _askName();

      return;
    }

    _isProcessing = false;

    await _speak(
      'ठीक है। कृपया अपनी पसंदीदा भाषा बताइए।',
      language: 'hi-IN',
    );

    await _startListening();
  }

  // ============================================================
  // ASK NAME
  // ============================================================

  Future<void> _askName() async {
    if (!mounted) {
      return;
    }

    _flow.moveTo(
      OnboardingStep.askName,
    );

    _isProcessing = false;

    await _speak(
      'नमस्ते। अपना नाम बताइए।',
      language: 'hi-IN',
    );

    await _startListening();
  }

  // ============================================================
  // HANDLE NAME
  // ============================================================

  Future<void> _handleName(String text) async {
    final name = text.trim();

    if (name.isEmpty) {
      await _speak(
        'मुझे आपका नाम सुनाई नहीं दिया। '
        'कृपया फिर से अपना नाम बताइए।',
        language: 'hi-IN',
      );

      await _startListening();

      return;
    }

    _flow.setName(name);

    _flow.moveTo(
      OnboardingStep.confirmName,
    );

    _isProcessing = false;

    await _speak(
      'क्या आपका नाम $name है? हाँ या ना।',
      language: 'hi-IN',
    );

    await _startListening();
  }

  // ============================================================
  // CONFIRM NAME
  // ============================================================

  Future<void> _handleNameConfirmation(String text) async {
    final lowerText = text.toLowerCase();

    final confirmed =
        lowerText.contains('yes') ||
        lowerText.contains('haan') ||
        lowerText.contains('han') ||
        lowerText.contains('हाँ') ||
        lowerText.contains('हां') ||
        lowerText.contains('जी');

    if (confirmed) {
      _flow.moveTo(
        OnboardingStep.completed,
      );

      _isProcessing = false;

      await _speak(
        'धन्यवाद। आपका setup पूरा हो गया है। '
        'अब आप मुझसे बात कर सकते हैं।',
        language: 'hi-IN',
      );

      return;
    }

    _flow.moveTo(
      OnboardingStep.askName,
    );

    _isProcessing = false;

    await _speak(
      'ठीक है। अपना नाम फिर से बताइए।',
      language: 'hi-IN',
    );

    await _startListening();
  }

  // ============================================================
  // AFTER ONBOARDING
  // ============================================================

  Future<void> _handleAfterOnboarding(String text) async {
    _isProcessing = false;

    await _speak(
      'आपने कहा: $text',
      language: 'hi-IN',
    );

    await _startListening();
  }

  // ============================================================
  // TEXT INPUT
  // ============================================================

  Future<void> _submitTypedText() async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      return;
    }

    _textController.clear();

    await _handleUserInput(text);
  }

  // ============================================================
  // STATUS
  // ============================================================

  void _setStatus(String value) {
    if (!mounted) {
      return;
    }

    setState(() {
      _status = value;
    });
  }

  // ============================================================
  // KEYBOARD
  // ============================================================

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (!_started) {
        _startCompanion();
      }
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_started) {
            _startCompanion();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'AI Companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ONLY ONE STATUS MESSAGE
                      Semantics(
                        liveRegion: true,
                        label: _status,
                        child: Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        enabled: !_isProcessing,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          _submitTypedText();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Optional: type your answer',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : _submitTypedText,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Submit typed answer',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
