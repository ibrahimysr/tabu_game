import 'package:flutter/material.dart';

class GameTimer extends StatelessWidget {
  final int timeLeft;

  const GameTimer({
    super.key,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: timeLeft <= 10 ? Colors.red : Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          timeLeft.toString(),
          style: TextStyle(
            color: timeLeft <= 10 ? Colors.red : Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}