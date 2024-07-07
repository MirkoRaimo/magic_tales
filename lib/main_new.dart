import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StoryGeneratorScreen(),
    );
  }
}

class StoryGeneratorScreen extends StatefulWidget {
  const StoryGeneratorScreen({super.key});

  @override
  State<StoryGeneratorScreen> createState() => _StoryGeneratorScreenState();
}

class _StoryGeneratorScreenState extends State<StoryGeneratorScreen> {
  final GenerativeModel model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyDs6_8gvkrEM587dtZR4N61aavBZw34A7w',
  );

  String _storyText = '';

  Future<void> generateStory(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    setState(() {
      _storyText = response.text ?? 'Errore nella generazione della storia.';
    });
  }

  @override
  void initState() {
    super.initState();
    _generateWelcomeMessage();
  }

  Future<void> _generateWelcomeMessage() async {
    const welcomePrompt = '''
    Genera un messaggio di benvenuto per un'app di narrazione interattiva per bambini, seguendo queste linee guida:
    - Tono: Amichevole ed entusiasta
    - Lunghezza: 2-3 frasi
    - Contenuto: Saluta il bambino, introduci l'idea di creare una storia insieme, chiedi che tipo di avventura vorrebbero iniziare oggi
    - Termina con una domanda che introduce le opzioni di genere (avventura, amicizia, magia)
    Massimo 40 parole.

    Linee guida generali:
    - Usa un linguaggio semplice e adatto ai bambini
    - Evita riferimenti a violenza, paura o temi adulti
    - Incoraggia l'immaginazione e la partecipazione del lettore
    - Lascia spazio perché il bambino continui la storia
    ''';

    await generateStory(welcomePrompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generatore di Storie')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(_storyText),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _generateStoryStart('avventura'),
                  child: Text('Avventura'),
                ),
                ElevatedButton(
                  onPressed: () => _generateStoryStart('amicizia'),
                  child: Text('Amicizia'),
                ),
                ElevatedButton(
                  onPressed: () => _generateStoryStart('magia'),
                  child: Text('Magia'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

        Linee guida generali:
        - Usa un linguaggio semplice e adatto ai bambini
        - Evita riferimenti a violenza, paura o temi adulti
        - Incoraggia l'immaginazione e la partecipazione del lettore
        - Lascia spazio perché il bambino continui la storia
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

        Linee guida generali:
        - Usa un linguaggio semplice e adatto ai bambini
        - Evita riferimenti a violenza, paura o temi adulti
        - Incoraggia l'immaginazione e la partecipazione del lettore
        - Lascia spazio perché il bambino continui la storia
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

        Linee guida generali:
        - Usa un linguaggio semplice e adatto ai bambini
        - Evita riferimenti a violenza, paura o temi adulti
        - Incoraggia l'immaginazione e la partecipazione del lettore
        - Lascia spazio perché il bambino continui la storia
        ''';
        break;
      default:
        prompt = 'Genera una breve storia per bambini.';
    }
    await generateStory(prompt);
  }
}
