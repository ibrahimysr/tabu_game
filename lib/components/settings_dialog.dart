import 'package:flutter/material.dart';
import 'package:tabu_game/model/game_settings.dart';

Future<bool?> showSettingsDialog(BuildContext context, GameSettings settings) async {
  TextEditingController team1Controller = TextEditingController(text: settings.team1Name);
  TextEditingController team2Controller = TextEditingController(text: settings.team2Name);
  
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),  // Koyu mavi
              Color(0xFF3949AB),  // Orta mavi
              Color(0xFF5C6BC0),  // Açık mavi
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
            Text(
              'Oyun Ayarları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              margin: EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: team1Controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Takım 1 Adı',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                  border: InputBorder.none,
                  icon: Icon(Icons.group, color: Colors.white),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              margin: EdgeInsets.only(bottom: 20),
              child: TextField(
                controller: team2Controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Takım 2 Adı',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                  border: InputBorder.none,
                  icon: Icon(Icons.group, color: Colors.white),
                ),
              ),
            ),
            _buildSettingRow(
              context,
              'Süre (saniye): ',
              DropdownButton<int>(
                value: settings.roundDuration,
                dropdownColor: Color(0xFF3949AB),
                style: TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Colors.white70,
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: [30, 45, 60, 90, 120]
                    .map((int value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        ))
                    .toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    settings.roundDuration = newValue;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              Icons.timer,
            ),
            SizedBox(height: 15),
            _buildSettingRow(
              context,
              'Tur Sayısı: ',
              DropdownButton<int>(
                value: settings.totalRounds,
                dropdownColor: Color(0xFF3949AB),
                style: TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Colors.white70,
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: [1, 2, 3, 4, 5]
                    .map((int value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        ))
                    .toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    settings.totalRounds = newValue;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              Icons.repeat,
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  'İptal',
                  Colors.redAccent.withOpacity(0.8),
                  () => Navigator.pop(context, false),
                  Icons.cancel,
                ),
                _buildButton(
                  context,
                  'Başla',
                  Colors.greenAccent.withOpacity(0.8),
                  () {
                    settings.team1Name = team1Controller.text;
                    settings.team2Name = team2Controller.text;
                    Navigator.pop(context, true);
                  },
                  Icons.play_arrow,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSettingRow(BuildContext context, String label, Widget dropdown, IconData iconData) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(iconData, color: Colors.white),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Spacer(),
        dropdown,
      ],
    ),
  );
}

Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onPressed, IconData icon) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 5,
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}