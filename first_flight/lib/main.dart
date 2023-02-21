import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter',
        theme: ThemeData(
          // useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    addCurrentToHistory();
    notifyListeners();
  }

  void addCurrentToHistory() {
    history.add(current);
  }

  void removeFavourite(WordPair wordPair) {
    favorites.remove(wordPair);
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? current]) {
    current = current ?? this.current;
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return WillPopScope(
          onWillPop: () async {
            if(selectedIndex == 1) {
              setState(() {
                selectedIndex = 0;
              });
              return false;
            }
            else {
              return true;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Flutter'),
            ),
            body: constraints.maxWidth < 500
              ?
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        child: page,
                      ),
                    ),
                    SafeArea(
                      child: BottomNavigationBar(
                        items: [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.favorite),
                            label: 'Favorites',
                          ),
                        ],
                        currentIndex: selectedIndex,
                        onTap: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                        },
                      ),
                    )
                  ],
                )
            :
                Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        extended: constraints.maxWidth >= 600,
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.favorite),
                            label: Text('Favorites'),
                          ),
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        child: page,
                      ),
                    ),
                  ],
                ),
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    if(!appState.history.contains(pair)) {
      appState.addCurrentToHistory();
    }

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    final ScrollController controller = ScrollController();
    void scrollDown() {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }

    return Center(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemBuilder: (context, position) {
                  var element = appState.history[position];
                  return ListTile(
                    leading: appState.favorites.contains(element) ? Icon(Icons.favorite) : SizedBox(),
                    iconColor: Theme.of(context).primaryColor,
                    title: Text(element.asPascalCase),
                    textColor: Colors.teal,
                    onTap: (){
                      appState.toggleFavorite(element);
                    },
                  );
                },
                itemCount: appState.history.length,
              ),
            ),
            Column(
              children: [
                SizedBox(height: 10),
                BigCard(pair: pair),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          appState.toggleFavorite();
                        },
                        icon: Icon(icon),
                        label: Text('Like')),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          appState.getNext();
                          scrollDown();
                        },
                        child: Text('Next')),
                  ],
                ),
                SizedBox(height: 10),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.favorites;

    if (pair.isEmpty) {
      return Center(
        child: Text('No favorites yet', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
      );
    }

    return Center(
      child: ListView.builder(
        itemBuilder: (context, position) {
          if(position == 0) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                  'You have ${appState.favorites.length} favorites:',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
            );
          }
          else {
            var element = pair[position-1];
            return ListTile(
              leading: Icon(Icons.favorite),
              iconColor: Theme.of(context).primaryColor,
              title: Text(element.asPascalCase),
              textColor: Colors.teal,
              onTap: (){
                appState.removeFavourite(element);
              },
            );
          }
        },
        itemCount: pair.length + 1,
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: Text(
            pair.asLowerCase,
            style: style,
            semanticsLabel: pair.asPascalCase, // For Accessibility - https://codelabs.developers.google.com/codelabs/flutter-codelab-first#4:~:text=visually%20impaired%20users.-,However,-%2C%20you%20might%20want
          ),
        ),
      ),
    );
  }
}
