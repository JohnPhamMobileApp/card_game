import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:async';

class GameCard {
  final String frontSide;
  final String backSide;
  bool isFaceUp = false;
  bool isMatched = false; // Track if the card is matched

  GameCard(this.frontSide, this.backSide);
}

class GameProvider extends ChangeNotifier {
  final List<GameCard> cards = [];
  int? firstCardIndex; // Store the index of the first card flipped
  int? secondCardIndex; // Store the index of the second card flipped

  GameProvider() {
    // Initialize the list of cards
    for (int i = 0; i < 8; i++) {
      // Create pairs of cards
      cards.add(GameCard("assets/card_front_$i.jpg", "assets/card_back.jpg"));
      cards.add(GameCard("assets/card_front_$i.jpg", "assets/card_back.jpg"));
    }
    cards.shuffle(); // Shuffle cards to randomize their order
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp || cards[index].isMatched) return; // Prevent flipping if already face up or matched

    cards[index].isFaceUp = true;
    notifyListeners();

    if (firstCardIndex == null) {
      firstCardIndex = index; // Save the index of the first card
    } else {
      secondCardIndex = index; // Save the index of the second card
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    if (cards[firstCardIndex!].frontSide == cards[secondCardIndex!].frontSide) {
      // Cards match
      cards[firstCardIndex!].isMatched = true;
      cards[secondCardIndex!].isMatched = true;
      firstCardIndex = null;
      secondCardIndex = null;
      notifyListeners();
    } else {
      // Cards do not match, flip them back after a short delay
      Timer(Duration(seconds: 1), () {
        cards[firstCardIndex!].isFaceUp = false;
        cards[secondCardIndex!].isFaceUp = false;
        firstCardIndex = null;
        secondCardIndex = null;
        notifyListeners();
      });
    }
  }

  bool isGameWon() {
    // Check if all cards are matched
    return cards.every((card) => card.isMatched);
  }

  void showVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You won the game!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame(); // Reset the game if desired
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    // Reset the game state
    cards.forEach((card) {
      card.isFaceUp = false;
      card.isMatched = false;
    });
    cards.shuffle(); // Shuffle cards again
    notifyListeners();
  }
}

class CardMatchingGame extends StatelessWidget {
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
              crossAxisCount: 4, // 4 columns for a 4x4 grid
            ),
            itemCount: provider.cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  provider.flipCard(index);
                  // Check if the game is won
                  if (provider.isGameWon()) {
                    provider.showVictoryDialog(context);
                  }
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CardMatchingGame(),
    );
  }
}
