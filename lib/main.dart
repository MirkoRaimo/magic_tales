import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:magic_tales/models/message_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'locale/bloc/locale_bloc.dart';
import 'widgets/message_widget.dart';
import 'widgets/prompt_button.dart';

/// The API key to use when accessing the Gemini API.
///
/// To learn how to generate and specify this key,
/// check out the README file of this sample.

// TODO: Replace this api calling Vertex AI

const String _overallGuideLines = '''Linee guida generali:
        - A prescindere dal resto del testo, la risposta dovrà essere in lingua: inglese
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

const String _messageEndingPart =
    '''Non fornire nessun opzione. Compila il campo story. Il campo options deve essere un array vuoto.

  NON aggiungere parole superflue (e.g. json {...}). Rispondi solo usando il seguente formato JSON:

  {
    "story": "Il testo della storia qui",
    "options": [leave this empty
      
    ]
  }''';

const String _storyIdea = '''
      Nel corso della chat, la storia dovrà avere questo stile:

      - Protagonista: Un giovane esploratore, scienziato, chimico, artista, inventore, apprendista stregone, tritone, sirena, ma non obbligatoriamente uno di questi. Scegli tu.
      - Ambientazione: Una giungla misteriosa, un'isola sconosciuta, un relitto sommerso, una vecchia cattedrale, un laboratorio, un labirinto, una foresta, una spiaggia, una montagna, un ghiacciaio, una nave, un vascello, un altro pianeta, ma non obbligatoriamente uno di questi. Scegli tu.
      - Elemento chiave: Una mappa del tesoro o un artefatto antico, un incantesimo, una pergamena, un manufatto, un oggetto comune, ma non obbligatoriamente uno di questi. Scegli tu.
      - Tono: Eccitante ma non spaventoso
      - Lunghezza: 3-4 frasi''';

const double desktopMaxWidthPx = 500.0;

void main() {
  runApp(
    BlocProvider(
      create: (context) => LocaleBloc(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: constraints.maxWidth > desktopMaxWidthPx
                  ? desktopMaxWidthPx
                  : constraints.maxWidth,
              child: const GenerativeAISample(),
            ),
          );
        },
      ),
    ),
  );
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFc3c0ff);
    late Locale currentLocale;

    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
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
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.grey,
            ),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // locale: state.locale,
          locale: const Locale('en', ''),
          // Use english as default language
          // It is used when the app starts
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              currentLocale = const Locale('en', '');
              return currentLocale;
            }
            currentLocale = supportedLocales.firstWhere(
              (supportedLocale) =>
                  supportedLocale.languageCode == locale.languageCode,
              orElse: () => const Locale('en', ''),
            );
            return currentLocale;
          },
          home: const ChatScreen(),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appTitle,
        ),
        // actions: <Widget>[
        //   BlocBuilder<LocaleBloc, LocaleState>(
        //     builder: (context, state) {
        //       String selectedLanguage = state.locale.languageCode;

        //       return DropdownButton<String>(
        //         value: selectedLanguage,
        //         //value: '🇬🇧',
        //         // icon: const Icon(Icons.language, color: Colors.white),
        //         onChanged: (String? newValue) {
        //           if (newValue != null) {
        //             context.read<LocaleBloc>().add(ChangeLocale(newValue));
        //           }
        //         },
        //         items: const <DropdownMenuItem<String>>[
        //           DropdownMenuItem<String>(
        //             value: 'it',
        //             child: Text('🇮🇹'),
        //           ),
        //           DropdownMenuItem<String>(
        //             value: 'en',
        //             child: Text('🇬🇧'),
        //           ),

        //           DropdownMenuItem<String>(
        //             value: 'es',
        //             child: Text('🇪🇸'),
        //           ),
        //           // Add more languages here
        //         ],
        //       );
        //     },
        //   ),
        // ],
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
  //this value determines when to ask to the user if they want to end the tale
  final int _numEnoughCycles = 6;
  bool _showEndStoryButton = false;
  bool _storyEnded = false;

  final safetySettings = [
    // SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
    // SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
    // SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.low),
    // SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.low),

    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.unspecified),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.unspecified),
    SafetySetting(
        HarmCategory.sexuallyExplicit, HarmBlockThreshold.unspecified),
    SafetySetting(
        HarmCategory.dangerousContent, HarmBlockThreshold.unspecified),
  ];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: widget.apiKey,
      safetySettings: safetySettings,
    );
    _chat = _model.startChat();
    WidgetsBinding.instance.window.locale;

    final locale = ui.PlatformDispatcher.instance.locale;

    _generateWelcomeMessage(locale);
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
    InputDecoration textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      // hintText: 'Suggerisco di...',
      hintText: AppLocalizations.of(context)!.textFieldHint,
      fillColor: const Color.fromARGB(
          166, 238, 238, 238), // Set the background color here
      filled: true,
    );

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
                        if (index / 2 > _numEnoughCycles) {
                          _showEndStoryButton = true;
                        }

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
                                    PromptButton(
                                      disablePreviousButtons:
                                          disablePreviousButtons,
                                      onPressed: !_loading
                                          ? () => setState(() {
                                                _generateCharacterName(
                                                  'avventura',
                                                );
                                              })
                                          : null,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .optionAdventure,
                                      ),
                                    ),
                                    PromptButton(
                                      disablePreviousButtons:
                                          disablePreviousButtons,
                                      onPressed: !_loading
                                          ? () => setState(() {
                                                _generateCharacterName(
                                                  'amicizia',
                                                );
                                              })
                                          : null,
                                      child: Text(AppLocalizations.of(context)!
                                          .optionFriendship),
                                    ),
                                    PromptButton(
                                      disablePreviousButtons:
                                          disablePreviousButtons,
                                      onPressed: !_loading
                                          ? () => setState(() {
                                                _generateCharacterName(
                                                  'magia',
                                                );
                                              })
                                          : null,
                                      child: Text(AppLocalizations.of(context)!
                                          .optionMagic),
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
              child: Column(
                children: [
                  if (_showEndStoryButton)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 0.0),
                          child: ElevatedButton(
                            onPressed: _loading || _storyEnded
                                ? null
                                : () {
                                    _generateEndingMessage();
                                    setState(() {
                                      _storyEnded = true;
                                    });
                                  },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Theme.of(context).disabledColor;
                                  }
                                  return Theme.of(context).colorScheme.primary;
                                },
                              ),
                            ),
                            child: Text(
                              'Terminate the tale',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            ),
                          ),
                        ),

                        // FloatingActionButton(child: TextButton('Concludi la storia'), onPressed: null),
                      ],
                    ),
                  Row(
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
                          onPressed: _loading || _storyEnded
                              ? null
                              : () async {
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message,
      {bool appendMessage = true}) async {
    setState(() {
      _loading = true;
    });

    try {
      // _generatedContent.add((image: null, text: message, fromUser: true));
      if (appendMessage) {
        _generatedContent
            .add((MessageModel(image: null, text: message, fromUser: true)));
      }
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
      _showError(e.toString(), onPressed: () {
        Navigator.of(context).pop();
        _sendChatMessage(
            'Generate a new response for the message $message. The previous one got the following issue ${e.toString()}',
            appendMessage: false);
      });

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

  void _showError(String message, {VoidCallback? onPressed}) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Not so fast!'),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: onPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
              child: const Text('Ok', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  Future<void> _generateWelcomeMessage(Locale locale) async {
    String welcomePrompt = '''
    A prescindere dal resto del testo, la risposta dovrà essere in lingua: inglese

    Genera un messaggio di benvenuto per un'app di narrazione interattiva per bambini, seguendo queste linee guida:
    - Tono: Amichevole ed entusiasta
    - Lunghezza: 2-3 frasi
    - Contenuto: Saluta il bambino, introduci l'idea di creare una storia insieme, chiedi che tipo di avventura vorrebbero iniziare oggi.
    - Ricorda ai bambini che possono usare scrivere e proporre delle loro idee se quelle suggerite dall'ai non piacciono
    - Termina con una domanda che introduce le opzioni di genere (avventura, amicizia, magia)
    Massimo 40 parole.

    $_messageFinalPart

    $_overallGuideLines
    ''';

    await addInitialMessage(welcomePrompt);
  }

  Future<void> _generateEndingMessage() async {
    const welcomePrompt = '''
    Concludi la storia.
    Il finale deve essere inaspettato, ma appagante per il lettore.
    In poche parole, ricorda anche da dove è partito il protagonista e dove è arrivato, magari sottolineando il tratto caratteristico del protagonista che l'ha portato lì (e.g. la sua ironia, il suo coraggio, la sua caparbietà ecc...)
    Massimo 80 parole

    $_messageEndingPart

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

// - Protagonista: Un giovane esploratore, scienziato, chimico, artista, inventore, apprendista stregone, tritone, sirena, ma non obbligatoriamente uno di questi. Scegli tu.
//         - Ambientazione: Una giungla misteriosa, un'isola sconosciuta, un relitto sommerso, una vecchia cattedrale, un laboratorio, un labirinto, una foresta, una spiaggia, una montagna, un ghiacciaio, una nave, un vascello, un altro pianeta, ma non obbligatoriamente uno di questi. Scegli tu.
//         - Elemento chiave: Una mappa del tesoro o un artefatto antico, un incantesimo, una pergamena, un manufatto, un oggetto comune, ma non obbligatoriamente uno di questi. Scegli tu.
//         - Tono: Eccitante ma non spaventoso
//         - Lunghezza: 3-4 frasi
//         - Finale: Una domanda o scelta per il lettore (es. "Quale sentiero dovrebbe prendere?")
//         Massimo 60 parole.
