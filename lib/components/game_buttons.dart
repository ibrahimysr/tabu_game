import 'package:flutter/material.dart';

class GameButtons extends StatelessWidget {
  final VoidCallback onCorrect;
  final VoidCallback onPass;
  final VoidCallback? onTabu;

  const GameButtons({
    super.key,
    required this.onCorrect,
    required this.onPass,
    required this.onTabu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildGameButton(
            icon: Icons.check,
            label: 'DOĞRU',
            color: Colors.green,
            onPressed: onCorrect,
          ),
          _buildGameButton(
            icon: Icons.skip_next,
            label: 'PAS',
            color: Colors.orange,
            onPressed: onPass,
          ),
          _buildGameButton(
            icon: Icons.dangerous,
            label: 'TABU',
            color: Colors.red,
            onPressed: onTabu,
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 100,
      constraints: BoxConstraints(minWidth: 90, maxWidth: 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed == null 
            ? [Colors.grey, Colors.grey.shade600]
            : [color.withValues(alpha:0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: onPressed == null ? [] : [
          BoxShadow(
            color: color.withValues(alpha:0.4),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}