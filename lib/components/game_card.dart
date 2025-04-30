import 'package:flutter/material.dart';
import 'package:tabu_game/model/tabu_card.dart';

class GameCard extends StatelessWidget {
  final TabuCard card;
  final Animation<double> animation;

  const GameCard({
    super.key,
    required this.card,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: 350,
            ),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.word,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 2,
                    height: 30,
                  ),
                  ...card.forbiddenWords.map((word) => Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}