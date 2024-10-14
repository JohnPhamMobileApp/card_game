import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class GameCard {
  final String frontSide;
  final String backSide;
  bool isFaceUp = false;

  GameCard(this.frontSide, this.backSide);
}

class GameProvider extends ChangeNotifier {
  final List<GameCard> cards = [];

  GameProvider() {
    // Initialize the list of cards
    for (int i = 0; i < 8; i++) {
      cards.add(GameCard("assets/card_front_$i.png", "assets/card_back.png"));
      cards.add(GameCard("assets/card_front_$i.png", "assets/card_back.png")); // Pairing cards
    }
    cards.shuffle(); // Shuffle cards to randomize their order
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp) return; // Prevent flipping if the card is already face up

    cards[index].isFaceUp = true;
    notifyListeners();

    // Check if the game is won
    if (isGameWon()) {
      showVictoryDialog();
    }
  }

  bool isGameWon() {
    // Check if all cards are face up
    return cards.every((card) => card.isFaceUp);
  }

  void showVictoryDialog() {
    // Show a victory message
    // This is a placeholder; implement your dialog here
    print('Congratulations! You won the game!');
  }
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: Consumer<GameProvider>(builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Card Matching Game'),
          ),
          body: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: provider.cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  provider.flipCard(index);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(
                            provider.cards[index].isFaceUp ? math.pi : 0),
                        child: provider.cards[index].isFaceUp
                            ? Image.asset(provider.cards[index].frontSide)
                            : Image.asset(provider.cards[index].backSide),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CardMatchingGame(),
    );
  }
}
