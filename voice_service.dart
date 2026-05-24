import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  final Map<String, String> _aliases = {
    "chengalpet": "Chengalpattu",
    "madras": "Chennai",
    "kovai": "Coimbatore",
    "kanchi": "Kanchipuram",
    "conjeevaram": "Kanchipuram",
    "kanyakumari": "Kanniyakumari",
    "cape comorin": "Kanniyakumari",
    "mayavaram": "Mayiladuthurai",
    "nagai": "Nagapattinam",
    "ooty": "Nilgiris",
    "udhagamandalam": "Nilgiris",
    "pudugai": "Pudukkottai",
    "ramnad": "Ramanathapuram",
    "sivagangai": "Sivaganga",
    "tanjore": "Thanjavur",
    "tuticorin": "Thoothukudi (Tuticorin)",
    "thoothukudi": "Thoothukudi (Tuticorin)",
    "trichy": "Tiruchirappalli",
    "tiruchi": "Tiruchirappalli",
    "trichirappalli": "Tiruchirappalli",
    "nellai": "Tirunelveli",
    "tirupur": "Tiruppur",
    "vellor": "Vellore",
    "madrai": "Madurai",
    "chenai": "Chennai",
  };

  final Map<String, int> _months = {
    "january": 1, "february": 2, "march": 3, "april": 4, "may": 5, "june": 6,
    "july": 7, "august": 8, "september": 9, "october": 10, "november": 11, "december": 12,
    "jan": 1, "feb": 2, "mar": 3, "apr": 4, "jun": 6, "jul": 7, "aug": 8, "sep": 9, "oct": 10, "nov": 11, "dec": 12
  };

  Future<void> speak(String text, String langCode) async {
    try {
      await _tts.setLanguage(langCode);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
      
      // Wait for speech to finish (approximate or use completion handler)
      // For now, we'll use a short delay to prevent overlapping with mic
      await Future.delayed(Duration(milliseconds: text.length * 100)); 
    } catch (e) {
      print("Voice Error: $e");
    }
  }

  Future<String?> listen() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (errorNotification) => print('Speech error: $errorNotification'),
    );

    if (available) {
      String recognizedText = "";
      bool isDone = false;

      await _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          if (result.finalResult) {
            isDone = true;
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      // Wait for result
      int timeout = 0;
      while (!isDone && timeout < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_speech.isListening && recognizedText.isNotEmpty) break;
        timeout++;
      }
      
      await _speech.stop();
      return recognizedText.trim().isNotEmpty ? recognizedText : null;
    }
    return null;
  }

  Map<String, String?> parseBookingInfo(String input) {
    String? source;
    String? destination;
    String? travelDate;
    
    final lowerInput = " " + input.toLowerCase().replaceAll(RegExp(r'[^\w\s\-]'), ' ') + " ";
    final districts = AppConstants.tnDistricts;

    if (lowerInput.contains(" today ")) {
      travelDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else if (lowerInput.contains(" tomorrow ")) {
      travelDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    } else if (lowerInput.contains(" day after tomorrow ")) {
      travelDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 2)));
    } else {
      final numericDateRegex = RegExp(r'(\d{1,2})[\-\/](\d{1,2})[\-\/](\d{4})');
      final numMatch = numericDateRegex.firstMatch(input);
      
      final monthList = _months.keys.join('|');
      final spokenDateRegex1 = RegExp('(\\d{1,2})\\s+($monthList)\\s+(\\d{4})');
      final spokenDateRegex2 = RegExp('($monthList)\\s+(\\d{1,2})\\s+(\\d{4})');
      
      final spokenMatch1 = spokenDateRegex1.firstMatch(lowerInput);
      final spokenMatch2 = spokenDateRegex2.firstMatch(lowerInput);

      if (spokenMatch1 != null) {
        try {
          int day = int.parse(spokenMatch1.group(1)!);
          String monthName = spokenMatch1.group(2)!;
          int year = int.parse(spokenMatch1.group(3)!);
          int month = _months[monthName]!;
          DateTime parsed = DateTime(year, month, day);
          travelDate = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (e) {}
      } else if (spokenMatch2 != null) {
        try {
          String monthName = spokenMatch2.group(1)!;
          int day = int.parse(spokenMatch2.group(2)!);
          int year = int.parse(spokenMatch2.group(3)!);
          int month = _months[monthName]!;
          DateTime parsed = DateTime(year, month, day);
          travelDate = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (e) {}
      } else if (numMatch != null) {
        try {
          int day = int.parse(numMatch.group(1)!);
          int month = int.parse(numMatch.group(2)!);
          int year = int.parse(numMatch.group(3)!);
          DateTime parsed = DateTime(year, month, day);
          travelDate = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (e) {}
      }
    }

    String? findDistrict(String segment) {
      for (var d in districts) {
        String cleanD = d.toLowerCase().replaceAll(RegExp(r'\(.*\)'), '').trim();
        if (segment.contains(" $cleanD ")) return d;
      }
      for (var entry in _aliases.entries) {
        if (segment.contains(" ${entry.key} ")) return entry.value;
      }
      return null;
    }

    if (lowerInput.contains(" from ") && lowerInput.contains(" to ")) {
      final fromIndex = lowerInput.indexOf(" from ");
      final toIndex = lowerInput.indexOf(" to ");
      if (fromIndex < toIndex) {
        source = findDistrict(lowerInput.substring(fromIndex, toIndex));
        destination = findDistrict(lowerInput.substring(toIndex));
      }
    } else if (lowerInput.contains(" to ")) {
      final toIndex = lowerInput.indexOf(" to ");
      source = findDistrict(lowerInput.substring(0, toIndex));
      destination = findDistrict(lowerInput.substring(toIndex));
    }

    if (source == null || destination == null) {
      List<String> found = [];
      List<String> words = lowerInput.trim().split(RegExp(r'\s+'));
      for (var word in words) {
        String? d;
        if (_aliases.containsKey(word)) {
          d = _aliases[word];
        } else {
          for (var dist in districts) {
            String cleanDist = dist.toLowerCase().replaceAll(RegExp(r'\(.*\)'), '').trim();
            if (cleanDist == word) {
              d = dist;
              break;
            }
          }
        }
        if (d != null && !found.contains(d)) found.add(d);
      }
      if (found.isNotEmpty) {
        source = source ?? found[0];
        if (found.length > 1) destination = destination ?? found[1];
      }
    }

    if (source == destination) destination = null;

    return {
      "source": source,
      "destination": destination,
      "date": travelDate,
    };
  }

  Future<void> stop() async {
    await _tts.stop();
    await _speech.stop();
  }
}
