import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/voice_service.dart';
import '../utils/routes.dart';

class VoiceBookingScreen extends StatefulWidget {
  const VoiceBookingScreen({super.key});

  @override
  State<VoiceBookingScreen> createState() => _VoiceBookingScreenState();
}

class _VoiceBookingScreenState extends State<VoiceBookingScreen> {
  final VoiceService _voiceService = VoiceService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  String _statusText = "Say route and date clearly\n(e.g., 'Chennai to Karur 1-8-2026')";
  String _liveText = "";
  bool _isListening = false;
  bool _isProcessing = false;

  // Persist state to accumulate info from multiple voice commands
  String? _source;
  String? _destination;
  String? _travelDate;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          _processFinalResult(isFinal: true);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (available) {
      _startListening();
    }
  }

  void _startListening() async {
    if (_isProcessing) return;
    
    setState(() {
      _isListening = true;
      _liveText = "";
      // Keep status text helpful
      if (_source == null) {
        _statusText = "Listening for your route...";
      } else if (_travelDate == null) {
        _statusText = "Route confirmed. Now say the date (e.g. 1-8-2026)";
      }
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _liveText = result.recognizedWords;
        });
        _processFinalResult(isFinal: result.finalResult);
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _processFinalResult({bool isFinal = false}) async {
    if (_isProcessing || _liveText.isEmpty) return;

    final info = _voiceService.parseBookingInfo(_liveText);
    
    // Accumulate info: don't overwrite if we already found it
    _source ??= info['source'];
    _destination ??= info['destination'];
    _travelDate ??= info['date'];

    // CHECK IF WE HAVE EVERYTHING
    if (_source != null && _destination != null && _travelDate != null) {
      _isProcessing = true;
      _speech.stop();
      
      setState(() {
        _isListening = false;
        _statusText = "Searching: $_source to $_destination on $_travelDate";
      });

      await _voiceService.speak("Perfect! Searching buses from $_source to $_destination for $_travelDate.", "en-US");
      
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          AppRoutes.busList,
          arguments: {
            'source': _source!,
            'destination': _destination!,
            'date': _travelDate!,
          },
        );
      }
    } else if (isFinal) {
      // If we are missing something, prompt and listen again
      if (_source != null && _destination != null && _travelDate == null) {
        setState(() => _statusText = "Route found: $_source to $_destination.\nWhen would you like to travel?");
        await _voiceService.speak("Route confirmed. Please say the travel date like 1st of August or Tomorrow.", "en-US");
        _startListening(); 
      } else if (_source == null || _destination == null) {
        setState(() => _statusText = "I heard '$_liveText'.\nPlease say both cities (e.g. Chennai to Karur).");
        // Don't auto-restart if we didn't catch any city, wait for user to tap or let them try again
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Voice Booking Assistant"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _travelDate == null ? "Where & When?" : "Processing Booking",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Speak clearly into the microphone", style: TextStyle(color: Colors.grey)),
            
            const Spacer(),
            
            // Pulse Effect
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  _buildPulseEffect(),
                GestureDetector(
                  onTap: _isListening ? () => _speech.stop() : _startListening,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.redAccent : Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isListening ? Colors.redAccent.withOpacity(0.3) : Colors.black12,
                          blurRadius: 20,
                          spreadRadius: 5
                        )
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 60,
                      color: _isListening ? Colors.white : Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // SHOW THE ACCUMULATED INFO
            if (_source != null || _destination != null || _travelDate != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Column(
                  children: [
                    if (_source != null && _destination != null)
                      Text("Route: $_source ➔ $_destination", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    if (_travelDate != null)
                      Text("Date: $_travelDate", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),

            // THE BLUE LIVE TEXT BUBBLE
            if (_liveText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  _liveText,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 20),
            
            Text(
              _statusText,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            
            const Spacer(),
            
            TextButton(
              onPressed: () {
                _speech.stop();
                Navigator.pop(context);
              },
              child: const Text("Cancel and use Keyboard", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseEffect() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 1.0, end: 1.5),
      duration: const Duration(seconds: 1),
      builder: (context, double value, child) {
        return Container(
          width: 120 * value,
          height: 120 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent.withOpacity(0.5 - (value - 1.0) * 0.5), width: 2),
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }
}
