import 'package:flutter/material.dart';

class TabuRightsIndicator extends StatelessWidget {
  final int currentTabuRights;

  const TabuRightsIndicator({
    super.key,
    required this.currentTabuRights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TABU HAKKI: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...List.generate(3, (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.star,
              color: index < currentTabuRights 
                ? Colors.yellow 
                : Colors.white.withOpacity(0.3),
              size: 20,
            ),
          )),
        ],
      ),
    );
  }
}