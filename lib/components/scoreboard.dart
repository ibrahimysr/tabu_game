import 'package:flutter/material.dart';

class Scoreboard extends StatelessWidget {
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final int currentTeam;
  final int currentRound;
  final int totalRounds;

  const Scoreboard({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.currentTeam,
    required this.currentRound,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 16,
        children: [
          _buildTeamScore(team1Name, team1Score, currentTeam == 1),
          Container(
            width: 2,
            height: 40,
            color: Colors.white.withValues(alpha:0.3),
          ),
          _buildTeamScore(team2Name, team2Score, currentTeam == 2),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'TUR $currentRound/$totalRounds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String name, int score, bool isActive) {
    return Container(
      constraints: BoxConstraints(minWidth: 100),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            score.toString(),
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}