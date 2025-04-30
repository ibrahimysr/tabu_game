import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabu_game/components/dynamic_gradient.dart';
import 'package:tabu_game/components/game_buttons.dart';
import 'package:tabu_game/components/game_timer.dart';
import 'package:tabu_game/components/scoreboard.dart';
import 'package:tabu_game/components/settings_dialog.dart';
import 'package:tabu_game/components/tabu_rights.dart';
import 'package:tabu_game/model/game_settings.dart';
import 'package:tabu_game/model/tabu_card.dart';

import '../components/game_card.dart';


class TabuGame extends StatefulWidget {
  const TabuGame({super.key});

  @override
  _TabuGameState createState() => _TabuGameState();
}

class _TabuGameState extends State<TabuGame> with TickerProviderStateMixin {
  List<TabuCard> cards = [];
  late GameSettings settings;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;

  int team1Score = 0;
  int team2Score = 0;
  int currentTeam = 1;
  int timeLeft = 60;
  int currentRound = 1;
  int team1TabuRights = 3;
  int team2TabuRights = 3;
  int completedTurns = 0;
  bool isPlaying = false;
  bool gameStarted = false;
  late TabuCard currentCard;

  @override
  void initState() {
    super.initState();
    settings = GameSettings();
    _loadSettings();
    _loadCards();
    _setupAnimations();
  }
  void startTimer() {
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }

    if (!isPlaying || timeLeft <= 0) {
      timer.cancel();
      _showRoundEndDialog();
      return;
    }

    setState(() {
      timeLeft--;
    });
  });
} 

Future<void> _showRoundEndDialog() async {
  setState(() {
    isPlaying = false;
  });

  completedTurns++;
  bool isRoundComplete = completedTurns % 2 == 0;
  bool isGameComplete = completedTurns == (settings.totalRounds * 2);

  if (isGameComplete) {
    await _showGameEndDialog();
  } else {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Süre Doldu!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sıra ${currentTeam == 1 ? settings.team2Name : settings.team1Name} takımına geçiyor!'),
            if (isRoundComplete) Text('\n${currentRound}. tur tamamlandı!'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Devam'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (isRoundComplete) {
                  currentRound++;
                  team1TabuRights = 3;
                  team2TabuRights = 3;
                }
                currentTeam = currentTeam == 1 ? 2 : 1;
                timeLeft = settings.roundDuration;
                startRound();
              });
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _showGameEndDialog() async {
  String winner;
  if (team1Score > team2Score) {
    winner = "${settings.team1Name} kazandı!";
  } else if (team2Score > team1Score) {
    winner = "${settings.team2Name} kazandı!";
  } else {
    winner = "Berabere!";
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Oyun Bitti!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(winner),
          SizedBox(height: 10),
          Text('${settings.team1Name}: $team1Score puan'),
          Text('${settings.team2Name}: $team2Score puan'),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Yeni Oyun'),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              team1Score = 0;
              team2Score = 0;
              currentRound = 1;
              completedTurns = 0;
              gameStarted = false;
            });
          },
        ),
      ],
    ),
  );
}

  void _setupAnimations() {
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      setState(() {
        settings = GameSettings.fromJson(jsonDecode(settingsJson));
        timeLeft = settings.roundDuration;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(settings.toJson()));
  }

  Future<void> _loadCards() async {
    try {
      final String response = await rootBundle.loadString('assets/cards.json');
      final data = await json.decode(response);
      setState(() {
        cards = (data['cards'] as List)
            .map((card) => TabuCard.fromJson(card))
            .toList();
        if (cards.isNotEmpty) {
          currentCard = cards.first;
        }
      });
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  Future<void> initializeGame() async {
    setState(() {
      team1TabuRights = 3;
      team2TabuRights = 3;
    });
    bool? result = await showSettingsDialog(context, settings);
    if (result == true) {
      setState(() {
        gameStarted = true;
        startRound();
      });
    }
  }

  void startRound() {
    setState(() {
      isPlaying = true;
      timeLeft = settings.roundDuration;
      currentCard = getRandomCard();
      _cardAnimationController.forward(from: 0.0);
      startTimer();
    });
  }

  void passWord() {
    _cardAnimationController.forward(from: 0.0);
    setState(() {
      currentCard = getRandomCard();
    });
  }

  int get currentTabuRights => currentTeam == 1 ? team1TabuRights : team2TabuRights;

  void tabuPenalty() {
    if (currentTabuRights > 0) {
      _cardAnimationController.forward(from: 0.0);
      setState(() {
        if (currentTeam == 1) {
          team1TabuRights--;
          team2Score++;
        } else {
          team2TabuRights--;
          team1Score++;
        }
        currentCard = getRandomCard();
      });
    }
  }

  TabuCard getRandomCard() {
    final random = Random();
    return cards[random.nextInt(cards.length)];
  }

  void correctAnswer() {
    _cardAnimationController.forward(from: 0.0);
    setState(() {
      if (currentTeam == 1) {
        team1Score++;
      } else {
        team2Score++;
      }
      currentCard = getRandomCard();
    });
  }

  void wrongAnswer() {
    _cardAnimationController.forward(from: 0.0);
    setState(() {
      if (currentTeam == 1) {
        team2Score++;
      } else {
        team1Score++;
      }
      currentCard = getRandomCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 80,
                      ),
                      child: Column(
                        mainAxisAlignment: gameStarted 
                          ? MainAxisAlignment.start 
                          : MainAxisAlignment.center,
                        children: [
                          if (gameStarted) 
                            _buildGameContent()
                          else 
                            _buildStartGameButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildHeader() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TABU',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                // Implement theme toggle logic (e.g., using Provider or setState)
              },
            ),
            if (gameStarted)
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () async {
                  bool? result = await showSettingsDialog(context, settings);
                  if (result == true) {
                    setState(() {
                      timeLeft = settings.roundDuration;
                    });
                  }
                },
              ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildGameContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Scoreboard(
          team1Name: settings.team1Name,
          team2Name: settings.team2Name,
          team1Score: team1Score,
          team2Score: team2Score,
          currentTeam: currentTeam,
          currentRound: currentRound,
          totalRounds: settings.totalRounds,
        ),
        SizedBox(height: 10),
        GameTimer(timeLeft: timeLeft),
        SizedBox(height: 10),
        if (isPlaying) ...[
          GameCard(
            card: currentCard,
            animation: _cardAnimation,
          ),
          SizedBox(height: 10),
          TabuRightsIndicator(currentTabuRights: currentTabuRights),
          SizedBox(height: 10),
          GameButtons(
            onCorrect: correctAnswer,
            onPass: passWord,
            onTabu: currentTabuRights > 0 ? tabuPenalty : null,
          ),
          SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildStartGameButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: initializeGame,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'OYUNA BAŞLA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }
}