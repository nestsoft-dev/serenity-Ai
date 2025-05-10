import 'dart:async';
import 'dart:developer';

import 'package:ai_therapy/utils/myPayWall.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:onepref/onepref.dart';
import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/paywall_result.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

bool isPro = true;

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [AudioScreen(), ChatScreen(), QuoteScreen()];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Audio'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
        ],
      ),
    );
  }
}

class AudioScreen extends StatefulWidget {
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, String>> _messages = [];
  bool _isListening = false;
  bool _aihasfinished = true;
  String userText = 'Hello';
  String _currentTranscript = '';

  final identifiers = {'monthly_1199', 'annual_7099'};

  @override
  initState() {
    super.initState();
    initTherapistTts();
    isPro = OnePref.getPremium()!;

    //checkPro();
  }

  _showMyPayWall() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return MyPayWall();
      },
    );
  }

  checkPro() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['pro'];
      log('This is entitlement ${entitlement.toString()}');

      setState(() {
        isPro = entitlement?.isActive ?? false;
      });
      if (!isPro) {
        PaywallResult paywall = await RevenueCatUI.presentPaywallIfNeeded(
          "pro",
        );
        print(paywall.name.toString());
        return;
      }
    });
  }

  Future<void> initTherapistTts() async {
    // 1. Choose a soothing language and voice:
    await _tts.setLanguage("en-US"); // English (US)
    await _tts.setVoice(
      {"name": "en-US-Standard-D", "locale": "en-US"},
    ); // e.g. Google’s “Standard D” voice :contentReference[oaicite:0]{index=0}

    // 2. Slow down the speech rate slightly (0.0–1.0):
    await _tts.setSpeechRate(
      0.45,
    ); // default ≈0.5; 0.45 feels calm and unhurried :contentReference[oaicite:1]{index=1}

    // 3. Warm up the pitch modestly (0.5–2.0):
    await _tts.setPitch(
      1.1,
    ); // default =1.0; 1.1 adds a gentle, reassuring warmth :contentReference[oaicite:2]{index=2}

    // 4. (Optional) Use SSML for natural pauses and emphasis:
    //    Surround your text with <speak>…</speak> and insert
    //    <break time="500ms"/> or <prosody> tags as needed.
    //    FlutterTts supports common SSML tags like <break> and <prosody>. :contentReference[oaicite:3]{index=3}
  }

  //   Future<void> _startListening() async {
  //     bool available = await _speech.initialize();
  //     if (available) {
  //       setState(() => _isListening = true);
  //       _speech.listen(
  //         onResult: (result) async {
  //           userText = result.recognizedWords;
  //           if (result.finalResult && userText!.isNotEmpty) {
  //             _speech.stop();
  //             setState(() {
  //               _isListening = false;
  //               _messages.add({'role': 'user', 'text': userText!});
  //               print('Recoding audio');
  //             });
  //             await _getBotReply(userText!);
  //           }
  //         },
  //       );
  //     }
  //   }

  //   Future<void> _stopAudio() async {
  //     if (!_isListening) {
  //       return;
  //     }
  //     _speech.stop();
  //     setState(() {
  //       _isListening = false;
  //       _messages.add({'role': 'user', 'text': userText!});
  //       print('Stoping audio');
  //     });
  //     await _getBotReply(userText);
  //   }

  //   Future<void> _getBotReply(String userMessage) async {
  //     final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $_apikey',
  //       },
  //       body: jsonEncode({
  //         'model': 'gpt-3.5-turbo',
  //         'messages': [
  //           {
  //             'role': 'system',
  //             'content':
  //                 'You are Nura, the compassionate AI therapist in the Serenity AI mobile app. Help the user with their emotional and mental well-being. Always respond supportively and empathetically, and speak as a calming, understanding companion named Nura.',
  //           },
  //           ..._messages.map((m) => {'role': m['role'], 'content': m['text']}),
  //         ],
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final reply =
  //           jsonDecode(response.body)['choices'][0]['message']['content'];
  //       setState(() => _messages.add({'role': 'assistant', 'text': reply}));
  //       await _tts.speak(reply);
  //     } else {
  //       setState(
  //         () => _messages.add({
  //           'role': 'assistant',
  //           'text': 'Sorry, something went wrong.',
  //         }),
  //       );
  //     }
  //   }

  Future<void> _startListening() async {
    if (!isPro) {
      _showMyPayWall();
      //  PaywallResult paywall = await RevenueCatUI.presentPaywallIfNeeded("pro");
      return;
    }
    bool available = await _speech.initialize();
    if (!available) return;

    setState(() {
      _isListening = true;
      _currentTranscript = '';
    });

    _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() => _currentTranscript = result.recognizedWords);
        // Only act when the result is final
        if (result.finalResult) {
          _stopListening(); // stop the listener
          _handleUserInput(_currentTranscript);
        }
      },
      partialResults: true,
      listenFor: Duration(minutes: 1),
      pauseFor: Duration(seconds: 5),
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _handleUserInput(String text) async {
    if (text.isEmpty) return;
    if (!isPro) {
      PaywallResult paywall = await RevenueCatUI.presentPaywallIfNeeded("pro");
      return;
    }
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      print('User said: $text');
    });
    await _getBotReply(text);
  }

  Future<void> _getBotReply(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['APIKEY']}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are Nura, the compassionate AI therapist...',
          },
          ..._messages.map((m) => {'role': m['role'], 'content': m['text']}),
        ],
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _aihasfinished = false;
      });
      final reply =
          jsonDecode(response.body)['choices'][0]['message']['content'];
      setState(() => _messages.add({'role': 'assistant', 'text': reply}));

      await _tts.speak(reply);
    } else {
      setState(
        () => _messages.add({
          'role': 'assistant',
          'text': 'Sorry, something went wrong.',
        }),
      );
    }
    setState(() {
      _aihasfinished = true;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        color: Colors.teal.shade50,
        child: Column(
          children: [
            _aihasfinished
                ? SizedBox.shrink()
                : SizedBox(
                  height: size.height * .1,
                  width: size.width,
                  child: Lottie.asset(
                    'assets/ai.json',
                    height: size.height * .1,
                    width: size.width,
                  ),
                ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.teal[200] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                          isUser
                              ? Text(msg['text']!)
                              : GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: msg['text']!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Copied to Clipboard!'),
                                    ),
                                  );
                                },
                                child: GptMarkdown(
                                  msg['text']!,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                    ),
                  );
                },
              ),
            ),

            _isListening
                ? GestureDetector(
                  onTap: () => _stopListening(),
                  child: SizedBox(
                    height: size.height * .1,
                    width: size.width,
                    child: Lottie.asset('assets/useraudio.json'),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (!isPro) {
                        _showMyPayWall();
                        return;
                      }

                      if (_isListening) {
                        _stopListening();
                        return;
                      } else if (_isListening == false) {
                        _startListening();
                        return;
                      } else {
                        return;
                      }
                    }, // _isListening ? null : _startListening,
                    icon: Icon(Icons.mic),
                    label: Text('Speak to Start'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  checkPro() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['pro'];
      print(entitlement.toString());
      setState(() {
        isPro = entitlement?.isActive ?? false;
      });
      if (!isPro) {
        PaywallResult paywall = await RevenueCatUI.presentPaywallIfNeeded(
          "pro",
        );
        print(paywall.name.toString());
        return;
      }
    });
  }

  @override
  initState() {
    super.initState();
    //checkPro();

    isPro = OnePref.getPremium()!;
  }

  _showMyPayWall() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return MyPayWall();
      },
    );
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;
    if (!isPro) {
      _showMyPayWall();
      //  PaywallResult paywall = await RevenueCatUI.presentPaywallIfNeeded("pro");
      return;
      // PaywallResult paywall = await RevenueCatUI.presentPaywallIfNeeded("pro");
      // return;
    }

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _controller.clear();
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['APIKEY']}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Nura, the compassionate AI therapist in the Serenity AI mobile app. Help the user with their emotional and mental well-being. Always respond supportively and empathetically, and speak as a calming, understanding companion named Nura.',
          },
          ..._messages.map((m) => {'role': m['role'], 'content': m['text']}),
        ],
      }),
    );

    if (response.statusCode == 200) {
      final reply =
          jsonDecode(response.body)['choices'][0]['message']['content'];
      setState(() => _messages.add({'role': 'assistant', 'text': reply}));
    } else {
      setState(
        () => _messages.add({
          'role': 'assistant',
          'text': 'Sorry, something went wrong.',
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.teal.shade50,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: BubbleSpecialThree(
                      text: msg['text']!,
                      color:
                          isUser
                              ? const Color.fromRGBO(128, 203, 196, 1)
                              : Colors.white,
                      tail: true,
                      isSender: isUser ? true : false,
                      textStyle: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: MessageBar(
                      sendButtonColor: const Color.fromARGB(255, 50, 164, 152),
                      messageBarColor: Colors.transparent,
                      onSend: (val) {
                        if (!isPro) {
                          _showMyPayWall();
                          return;
                        }
                        if (val.isEmpty) return;
                        setState(() {
                          _controller.text = val;
                        });
                        _sendMessage();
                      },
                      messageBarHintText: 'How are you feeling today?',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _quote = "You are enough just as you are.";
  bool _loading = false;

  Future<void> _fetchQuote() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _quote = data[0]['q'] + ' — ' + data[0]['a']);
      } else {
        setState(
          () => _quote = 'Could not fetch quote. Please try again later.',
        );
      }
    } catch (_) {
      setState(() => _quote = 'An error occurred.');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.teal.shade50,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Daily Affirmation',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? CircularProgressIndicator()
                  : Text(
                    _quote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _fetchQuote,
                icon: Icon(Icons.refresh),
                label: Text('New Quote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//pod repo update