
import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  Timer? countdownTimer;

  int countdownTime = 20;
  String enteredCode = '';
  String currentScreen = 'code';
  bool gameFinished = false;

  final String accessCode = 'FlazeGoat';
  final String rewardCode = 'CORE-7392';

  List<String> tiles = [
    'R', 'R', 'R',
    'G', 'G', 'G',
    'B', 'B', 'B',
  ];

  int emptyIndex = 9;

  @override
  void initState() {
    super.initState();
    tiles.shuffle();
    tiles.add(' ');
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Component tile(String value) {
    if (value == 'R') {
      return div(classes: 'tile red', [Component.text('R')]);
    } else if (value == 'G') {
      return div(classes: 'tile green', [Component.text('G')]);
    } else if (value == 'B') {
      return div(classes: 'tile blue', [Component.text('B')]);
    }

    return div(classes: 'tile empty', [Component.text(' ')]);
  }

  bool isPuzzleSolved() {
    const correctOrder = [
      'R', 'R', 'R',
      'G', 'G', 'G',
      'B', 'B', 'B',
    ];

    for (int i = 0; i < correctOrder.length; i++) {
      if (tiles[i] != correctOrder[i]) {
        return false;
      }
    }

    return true;
  }

  void checkCode() {
    if (enteredCode.trim() == accessCode) {
      setState(() {
        currentScreen = 'puzzle';
      });

      startCountdown();
    }
  }

  void startCountdown() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (gameFinished) {
          timer.cancel();
          return;
        }

        if (countdownTime > 0) {
          setState(() {
            countdownTime--;
          });
        }

        if (countdownTime <= 0) {
          timer.cancel();

          setState(() {
            gameFinished = true;
            currentScreen = isPuzzleSolved() ? 'victory' : 'failed';
          });
        }
      },
    );
  }

  void onTileClick(int index) {
    if (gameFinished || tiles[index] == ' ') return;

    setState(() {
      tiles[emptyIndex] = tiles[index];
      tiles[index] = ' ';
      emptyIndex = index;

      if (isPuzzleSolved()) {
        gameFinished = true;
        currentScreen = 'victory';
        countdownTimer?.cancel();
      }
    });
  }

  @override
  Component build(BuildContext context) {
    return div([
      if (currentScreen == 'code')
        div(classes: 'app', [
          input(
            classes: 'code-input',
            attributes: {
              'placeholder': 'Enter code',
              'autocomplete': 'off',
              'autocapitalize': 'off',
              'spellcheck': 'false',
            },
            events: events(
              onInput: (String value) {
                enteredCode = value;

                if (enteredCode.trim() == accessCode) {
                  checkCode();
                }
              },
            ),
          ),
        ]),

      if (currentScreen == 'puzzle')
        div(classes: 'app', [
          h2([Component.text('$countdownTime')]),
          div(
            classes: 'puzzle-grid',
            tiles.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;

              return button(
                classes: 'tile-button',
                events: {
                  'click': (event) => onTileClick(index),
                },
                [tile(value)],
              );
            }).toList(),
          ),
        ]),

      if (currentScreen == 'victory')
        div(classes: 'app', [
          div(classes: 'reward-code', [
            Component.text(rewardCode),
          ]),
        ]),

      if (currentScreen == 'failed')
        div(classes: 'app', []),

      div(classes: 'desktop-warning', [
        Component.text(''),
      ]),
    ]);
  }
}
