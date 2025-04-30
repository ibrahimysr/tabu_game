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
  State<TabuGame> createState() => _TabuGameState();
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5C6BC0),  // Açık mavi
                Color(0xFF3949AB),  // Orta mavi
                Color(0xFF1A237E),  // Koyu mavi
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                radius: 35,
                child: Icon(
                  Icons.timer_off,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Süre Doldu!', 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )
              ),
              SizedBox(height: 15),
              Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
              SizedBox(height: 15),
              Text(
                'Sıra ${currentTeam == 1 ? settings.team2Name : settings.team1Name} takımına geçiyor!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              if (isRoundComplete) 
                Container(
                  margin: EdgeInsets.only(top: 15),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        '$currentRound. tur tamamlandı!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text(
                      'Devam',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showGameEndDialog() async {
  String winner;
  Color winnerColor;
  IconData winnerIcon;
  
  if (team1Score > team2Score) {
    winner = "${settings.team1Name} kazandı!";
    winnerColor = Colors.blueAccent;
    winnerIcon = Icons.emoji_events;
  } else if (team2Score > team1Score) {
    winner = "${settings.team2Name} kazandı!";
    winnerColor = Colors.redAccent;
    winnerIcon = Icons.emoji_events;
  } else {
    winner = "Berabere!";
    winnerColor = Colors.purpleAccent;
    winnerIcon = Icons.balance;
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF673AB7),  // Mor
              Color(0xFF4527A0),  // Koyu mor
              Color(0xFF311B92),  // Çok koyu mor
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    'Oyun Bitti!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: winnerColor,
                      radius: 40,
                      child: Icon(
                        winnerIcon,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: winnerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                winner,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            _buildScoreCard(
              settings.team1Name,
              team1Score,
              team1Score >= team2Score ? Colors.blue.shade300 : Colors.transparent,
            ),
            SizedBox(height: 10),
            _buildScoreCard(
              settings.team2Name,
              team2Score,
              team2Score >= team1Score ? Colors.red.shade300 : Colors.transparent,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text(
                    'Yeni Oyun',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    ),
  );
}

Widget _buildScoreCard(String teamName, int score, Color highlightColor) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: highlightColor,
        width: 3,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.group, color: Colors.white70),
            SizedBox(width: 12),
            Text(
              teamName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score puan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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

  int get currentTabuRights =>
      currentTeam == 1 ? team1TabuRights : team2TabuRights;

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
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            80,
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
              color: Colors.green.withValues(alpha:0.4),
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
