import 'dart:math';

import 'package:flutter/material.dart';

class RandomMode extends StatefulWidget{
  final Random _random = Random();

  /// Génère une grille complète aléatoire avec des valeurs 2, 4, 8, ou 16.
  List<List<int>> generateRandomGrid(int gridSize) {
    return List.generate(
      gridSize,
          (_) => List.generate(
        gridSize,
            (_) => _getRandomTileValue(),
      ),
    );
  }

  /// Génère une nouvelle tuile aléatoire avec des valeurs possibles de 2, 4, 8, ou 16.
  int generateRandomTile() {
    const possibleValues = [2, 4, 8, 16];
    return possibleValues[_random.nextInt(possibleValues.length)];
  }

  /// Retourne une position aléatoire pour placer une tuile.
  Map<String, int> getRandomPosition(int gridSize) {
    return {
      'row': _random.nextInt(gridSize),
      'col': _random.nextInt(gridSize),
    };
  }

  /// Retourne une valeur aléatoire pour les tuiles (2, 4, 8, ou 16).
  int _getRandomTileValue() {
    const possibleValues = [2, 4, 8, 16];
    return possibleValues[_random.nextInt(possibleValues.length)];
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
