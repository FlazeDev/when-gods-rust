
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
  String countdownText = 'Solve The Puzzle';
  String enteredCode = '';
  bool isCodeCorrect = false;
  bool gameFinished = false;

  List<String> tiles = [
    'R', 'R', 'R',
    'G', 'G', 'G',
    'B', 'B', 'B',
  ];

  int emptyIndex = 9;

  Component tile(String tile) {
    if (tile == 'R') {
      return div(classes: 'tile red', [Component.text('R')]);
    } else if (tile == 'G') {
      return div(classes: 'tile green', [Component.text('G')]);
    } else if (tile == 'B') {
      return div(classes: 'tile blue', [Component.text('B')]);
    } else {
      return div(classes: 'tile empty', [Component.text(' ')]);
    }
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

  @override
  void initState() {
    super.initState();
    tiles.shuffle();
    tiles.add(' ');
  }

  void codeCheck() {
    if (enteredCode.trim() == 'FlazeGoat') {
      setState(() {
        isCodeCorrect = true;
        countdownText = 'Solve The Puzzle';
      });

      startCountdown();
    } else {
      setState(() {
        isCodeCorrect = false;
      });
    }
  }

  void startCountdown() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (countdownTime > 0 && !gameFinished) {
          setState(() {
            countdownTime--;
          });
        }

        if (countdownTime <= 0) {
          timer.cancel();

          setState(() {
            gameFinished = true;
            countdownText = isPuzzleSolved()
                ? 'Good Job! Puzzle Solved!'
                : 'Time is up! Reload to try again.';
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
        countdownText = 'Good Job! Puzzle Solved!';
        countdownTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div([
      div(classes: 'app', [
        h1([Component.text('OVERCLOCK')]),
        p(
          classes: 'subtitle',
          [Component.text('SOLVE THE GRID BEFORE TIME RUNS OUT')],
        ),

        if (!isCodeCorrect)
          div(classes: 'panel', [
            h2([Component.text('ACCESS REQUIRED')]),
            p(
              classes: 'subtitle',
              [Component.text('Enter the code to unlock the puzzle.')],
            ),
            input(
              classes: 'code-input',
              attributes: {
                'placeholder': 'Enter Code',
              },
              events: events(
                onInput: (String value) {
                  enteredCode = value;
                },
              ),
            ),
            button(
              classes: 'action-button',
              events: {
                'click': (event) => codeCheck(),
              },
              [Component.text('UNLOCK')],
            ),
          ]),

        if (isCodeCorrect)
          div(classes: 'panel', [
            h2([Component.text('THE GRID')]),
            p(
              classes: 'status',
              [Component.text('$countdownTime seconds remaining')],
            ),
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
            p(
              classes: 'status',
              [Component.text(countdownText)],
            ),
          ]),
      ]),

      div(classes: 'desktop-warning', [
        h2([Component.text('PHONE REQUIRED')]),
        p([
          Component.text('Open this puzzle on your phone to play.'),
        ]),
      ]),
    ]);
  }
}
