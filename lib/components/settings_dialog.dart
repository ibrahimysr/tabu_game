import 'package:flutter/material.dart';
import 'package:tabu_game/model/game_settings.dart';

Future<bool?> showSettingsDialog(BuildContext context, GameSettings settings) async {
  TextEditingController team1Controller = TextEditingController(text: settings.team1Name);
  TextEditingController team2Controller = TextEditingController(text: settings.team2Name);

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Oyun Ayarları'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: team1Controller,
              decoration: InputDecoration(labelText: 'Takım 1 Adı'),
            ),
            TextField(
              controller: team2Controller,
              decoration: InputDecoration(labelText: 'Takım 2 Adı'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Süre (saniye): '),
                DropdownButton<int>(
                  value: settings.roundDuration,
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
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Tur Sayısı: '),
                DropdownButton<int>(
                  value: settings.totalRounds,
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
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('İptal'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text('Başla'),
          onPressed: () {
            settings.team1Name = team1Controller.text;
            settings.team2Name = team2Controller.text;
            Navigator.pop(context, true);
          },
        ),
      ],
    ),
  );
}