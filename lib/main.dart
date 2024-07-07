// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:magic_tales/models/message_model.dart';

import 'widgets/message_widget.dart';
import 'widgets/prompt_button.dart';

/// The API key to use when accessing the Gemini API.
///
/// To learn how to generate and specify this key,
/// check out the README file of this sample.

// TODO: Replace this api calling Vertex AI
const String _apiKey = String.fromEnvironment('API_KEY');

const String _overallGuideLines = '''Linee guida generali:
        - Usa un linguaggio semplice e adatto ai bambini
        - Evita riferimenti a violenza, paura o temi adulti
        - Incoraggia l'immaginazione e la partecipazione del lettore
        - Lascia spazio perché il bambino continui la storia''';

const String _messageFinalPart =
    '''Fornisci anche 3 opzioni di 4-5 parole ciascuna per continuare la storia.

  NON aggiungere parole superflue (e.g. json {...}). Rispondi solo usando il seguente formato JSON:

  {
    "story": "Il testo della storia qui",
    "options": [
      "Prima opzione qui",
      "Seconda opzione qui",
      "Terza opzione qui"
    ]
  }''';

void main() {
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFc3c0ff);

    return MaterialApp(
      title: 'Magic Tales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          // seedColor: const Color.fromARGB(255, 171, 222, 244),
          seedColor: const Color.fromARGB(255, 6, 1, 60),
        ),
        primaryColor: primaryColor,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: primaryColor,
              width: 4.0,
            ),
          ),
          hintStyle: TextStyle(
            color: Colors.black,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: primaryColor,
              width: 4.0,
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),

          // Add other text styles as needed
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.grey,
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(title: 'Magic Tales'),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const ChatWidget(apiKey: _apiKey),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.apiKey,
    super.key,
  });

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageModel> _generatedContent = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: widget.apiKey,
    );
    _chat = _model.startChat();
    //_generatedContent.add((image: null, text: 'Loading...', fromUser: false));
    _generateWelcomeMessage();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration textFieldDecoration = const InputDecoration(
      contentPadding: EdgeInsets.all(15),
      hintText: 'Suggerisco di...',
      fillColor:
          Color.fromARGB(166, 238, 238, 238), // Set the background color here
      filled: true,
    );

    String choosenRoot = '';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/magic_tales_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _apiKey.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        //Disabling buttons for messages that are not the latest one
                        bool disablePreviousButtons =
                            index == _generatedContent.length - 1;
                        if (index == _generatedContent.length) {
                          if (_loading) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ));
                          } else {
                            return Container(
                              margin: const EdgeInsets.all(0.0),
                            );
                          }
                        }

                        final MessageModel content = _generatedContent[index];
                        return Column(
                          children: [
                            MessageWidget(
                              text: content.text,
                              image: content.image,
                              isFromUser: content.fromUser,
                            ),
                            if (index == 0)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // PromptButton(
                                    //   disablePreviousButtons:
                                    //       disablePreviousButtons,
                                    //   onPressed: () =>
                                    //       _generateStoryStart('avventura'),
                                    //   child: const Text('Avventura'),
                                    // ),
                                    // PromptButton(
                                    //   disablePreviousButtons:
                                    //       disablePreviousButtons,
                                    //   onPressed: () =>
                                    //       _generateStoryStart('amicizia'),
                                    //   child: const Text('Amicizia'),
                                    // ),
                                    // PromptButton(
                                    //   disablePreviousButtons:
                                    //       disablePreviousButtons,
                                    //   onPressed: () =>
                                    //       _generateStoryStart('mnagia'),
                                    //   child: const Text('Magia'),
                                    // ),

                                    PromptButton(
                                      disablePreviousButtons:
                                          disablePreviousButtons,
                                      onPressed: () => setState(() {
                                        disablePreviousButtons = true;
                                        choosenRoot = 'avventura';
                                        _generateCharacterName(
                                          'avventura',
                                        );
                                      }),
                                      child: const Text('Avventura'),
                                    ),
                                    PromptButton(
                                      disablePreviousButtons:
                                          disablePreviousButtons,
                                      onPressed: () => setState(() {
                                        disablePreviousButtons = true;
                                        choosenRoot = 'amicizia';
                                        _generateCharacterName(
                                          'amicizia',
                                        );
                                      }),
                                      child: const Text('Amicizia'),
                                    ),
                                    PromptButton(
                                      disablePreviousButtons:
                                          disablePreviousButtons,
                                      onPressed: () => setState(() {
                                        disablePreviousButtons = true;
                                        choosenRoot = 'magia';
                                        _generateCharacterName(
                                          'magia',
                                        );
                                      }),
                                      child: const Text('Magia'),
                                    ),
                                  ],
                                ),
                              ),
                            if (index != 0)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    for (var option in content.options ?? [])
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth:
                                                150), // imposta una larghezza massima
                                        child: PromptButton(
                                          disablePreviousButtons:
                                              disablePreviousButtons,
                                          onPressed: () =>
                                              _sendChatMessage(option),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0, horizontal: 0.0),
                                            child: Text(
                                              option,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                      itemCount: _generatedContent.length + 1,
                    )
                  : ListView(
                      children: const [
                        Text(
                          'No API key found. Please provide an API Key using '
                          "'--dart-define' to set the 'API_KEY' declaration.",
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      decoration: textFieldDecoration,
                      controller: _textController,
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        _sendChatMessage(_textController.text);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      // _generatedContent.add((image: null, text: message, fromUser: true));
      _generatedContent
          .add((MessageModel(image: null, text: message, fromUser: true)));
      setState(() {
        _scrollDown();
      });

      final response = await _chat.sendMessage(
        Content.text(message),
      );
      final text = response.text;

      Map<String, dynamic> responseJson = parseJsonResponse(text);

      addContentMadeByAi(responseJson['story'] as String,
          responseJson['options'] as List<String>);

      if (text == null) {
        return;
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void addContentMadeByAi(String? text, List<String>? options) {
    // _generatedContent.add((image: null, text: text, fromUser: false));
    _generatedContent.add((MessageModel(
        image: null, text: text, fromUser: false, options: options)));

    if (text == null) {
      _showError('No response from API.');
    } else {
      setState(() {
        _loading = false;
        _scrollDown();
      });
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  Future<void> _generateWelcomeMessage() async {
    const welcomePrompt = '''
    Genera un messaggio di benvenuto per un'app di narrazione interattiva per bambini, seguendo queste linee guida:
    - Tono: Amichevole ed entusiasta
    - Lunghezza: 2-3 frasi
    - Contenuto: Saluta il bambino, introduci l'idea di creare una storia insieme, chiedi che tipo di avventura vorrebbero iniziare oggi
    - Termina con una domanda che introduce le opzioni di genere (avventura, amicizia, magia)
    Massimo 40 parole.

    $_messageFinalPart

    $_overallGuideLines
    ''';

    await addInitialMessage(welcomePrompt);
  }

  Future<void> addInitialMessage(String welcomePrompt) async {
    setState(() {
      _loading = true;
    });
    final response = await _chat.sendMessage(
      Content.text(welcomePrompt),
    );

    final text = response.text;

    Map<String, dynamic> responseJson = parseJsonResponse(text);

    addContentMadeByAi(responseJson['story'] as String,
        responseJson['options'] as List<String>);
    setState(() {
      _loading = false;
    });
  }

  Map<String, dynamic> parseJsonResponse(String? text) {
    Map<String, dynamic> jsonResponse = {};
    if (text != null) {
      print('json to decode $text');

      // Use regex to extract the JSON part:
      // it extract only what's between the first { and the last }
      final RegExp regex = RegExp(r'\{.*\}', dotAll: true);
      final Match? match = regex.firstMatch(text);
      if (match != null) {
        final String jsonString = match.group(0)!;
        jsonResponse = jsonDecode(jsonString);

        // Regex to make the json prettier
        const String regexPattern = r'(?<=\.|;|!|\?)(?<!\u2026)\s*(?!$|["])';

        jsonResponse = {
          'story': (jsonResponse['story'] as String)
              .replaceAll(RegExp(regexPattern), '\n'),
          'options': (jsonResponse['options'] as List<dynamic>).cast<String>(),
        };
      }
    }

    print('output $jsonResponse');
    return jsonResponse;
  }

  Future<void> _generateStoryStart(String genre) async {
    String prompt;
    switch (genre) {
      case 'avventura':
        prompt = '''
        Crea l'inizio di una storia avventurosa per bambini dai 7 ai 12 anni:
        - Protagonista: Un giovane esploratore o esploratrice
        - Ambientazione: Una giungla misteriosa o un'isola sconosciuta
        - Elemento chiave: Una mappa del tesoro o un artefatto antico
        - Tono: Eccitante ma non spaventoso
        - Lunghezza: 3-4 frasi
        - Finale: Una domanda o scelta per il lettore (es. "Quale sentiero dovrebbe prendere?")
        Massimo 60 parole.

        $_messageFinalPart

        $_overallGuideLines
        ''';
        break;
      case 'amicizia':
        prompt = '''
        Scrivi l'apertura di una storia di amicizia per bambini dai 7 ai 12 anni:
        - Personaggi: Due bambini che si incontrano per la prima volta
        - Ambientazione: Un parco giochi o il primo giorno di scuola
        - Elemento chiave: Un hobby condiviso o un problema da risolvere insieme
        - Tono: Divertente e ottimista
        - Lunghezza: 3-4 frasi
        - Finale: Una domanda sul come i personaggi potrebbero diventare amici
        Massimo 60 parole.

        $_messageFinalPart

        $_overallGuideLines
        ''';
        break;
      case 'magia':
        prompt = '''
        Genera l'inizio di una storia magica per bambini dai 7 ai 12 anni:
        - Protagonista: Un giovane apprendista mago/strega
        - Ambientazione: Una scuola di magia o un negozio di oggetti magici
        - Elemento chiave: Un incantesimo che ha un effetto inaspettato
        - Tono: Meraviglioso e leggermente comico
        - Lunghezza: 3-4 frasi
        - Finale: Una domanda su come il protagonista potrebbe risolvere il pasticcio magico
        Massimo 60 parole.

        $_messageFinalPart

        $_overallGuideLines
        ''';
        break;
      default:
        prompt = 'Genera una breve storia per bambini.';
    }
    addInitialMessage(prompt);
  }

  Future<void> _generateCharacterName(String genre) async {
    String prompt = '''
        Crea 3 nomi da protagonisti per una storia di genere $genre
  
        NON aggiungere parole superflue (e.g. json {...}). Rispondi solo usando il seguente formato JSON:
        In 'story' inserisci un modo per dire 'ed il protagonista si chiama:' (varia, scegli tu come scrivere questa frase ma, oltre al nome, aggiungi un aggettivo),
        in 'options' inserisci le 3 opzioni
        Non inserire mai ellipsis (...)

        {
          "story": "",
          "options": [
            "Prima opzione qui",
            "Seconda opzione qui",
            "Terza opzione qui"
          ]
        }

        $_overallGuideLines
        ''';
    addInitialMessage(prompt);
  }
}
