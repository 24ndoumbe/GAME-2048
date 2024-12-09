import 'package:flutter/material.dart';
import 'petale.dart';
import 'dart:math';



class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int moveCount = 0;
  bool isRandomGrid = false;
  int targetValue = 256;
  bool hasWon = false; // Pour empêcher plusieurs dialogues de victoire
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  List<Widget> petalWidgets = []; // Liste pour stocker les pétales


  // Fonction pour démarrer l'animation des pétales
  void _startPetalAnimation() {
    setState(() {
      petalWidgets = List.generate(1500, (index) {
        // Taille des pétales, toute petite et égale
        double size = 5.0; // Taille fixe de 50 pixels pour tous les pétales

        // Position horizontale, espacée de manière égale
        double leftPosition = (index * 5.0) % 350.0; // Position horizontale espacée

        // Position verticale, au-dessus de l'écran
        double topPosition = -size; // Départ en dehors de l'écran
        return Petal(
          size: size,
          leftPosition: leftPosition,
          topPosition: topPosition,
        );
      });
    });
  }

  // Appeler cette méthode lorsque le joueur gagne
  void _onPlayerWin() {
    // Simulez un délai pour démarrer les pétales après une victoire
    Future.delayed(Duration(seconds: 1), () {
      _startPetalAnimation(); // Lance l'animation des pétales
    });
  }

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      moveCount = 0;
      hasWon = false; // Réinitialiser l'état de victoire
      grid = List.generate(4, (_) => List.filled(4, 0));
      _addRandomTile();
      _addRandomTile();
      petalWidgets.clear(); // Réinitialise les pétales
    });
  }

  void _addRandomTile() {
    List<int> emptyTiles = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          emptyTiles.add(i * 4 + j);
        }
      }
    }
    if (emptyTiles.isNotEmpty) {
      int randomIndex = emptyTiles[Random().nextInt(emptyTiles.length)];
      grid[randomIndex ~/ 4][randomIndex % 4] = 2;
    }
  }

  bool _isTargetAchieved() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == targetValue) {
          return true;
        }
      }
    }
    return false;
  }
  void _onSwipe(String direction) {
    setState(() {
      if (_moveTiles(direction)) {
        moveCount++;
        _addRandomTile();

        // Vérifier si le joueur a atteint la valeur cible
        if (!hasWon && _isTargetAchieved()) {
          hasWon = true;
          _showCongratulationsDialog();
          _startPetalAnimation(); // Lance l'animation des pétales
          return; // Arrête ici pour éviter de vérifier la défaite après avoir gagné
        }

        // Vérifier si le joueur a perdu après le déplacement
        if (!_canMove()) {
          _showGameOverDialog();
        }
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vous avez perdu'),
          content: const Text('Aucun mouvement possible ! Essayez à nouveau.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame(); // Redémarre une nouvelle partie
              },
              child: const Text('Nouvelle Partie'),
            ),
          ],
        );
      },
    );
  }

  bool _canMove() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) return true; // Une case vide existe
        if (j < 3 && grid[i][j] == grid[i][j + 1]) return true; // Fusion possible à droite
        if (i < 3 && grid[i][j] == grid[i + 1][j]) return true; // Fusion possible en bas
      }
    }
    return false; // Aucun mouvement possible
  }





  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant à l'extérieur
      builder: (context) {
        return AlertDialog(
          title: const Text('Félicitations !'),
          content: Text('Vous avez atteint $targetValue !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
                _startNewGame(); // Redémarrer une nouvelle partie
              },
              child: const Text('Nouvelle Partie'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );
  }

  /*void _startPetalAnimation() {
    // Ajouter des pétales animées après la victoire
    setState(() {
      petalWidgets = List.generate(20, (index) {
        double size = Random().nextInt(20) + 20.0; // Taille aléatoire des pétales
        double leftPosition = Random().nextInt(300).toDouble(); // Position horizontale
        double topPosition = -30.0; // Position initiale (en haut de l'écran)

        return AnimatedPositioned(
          duration: Duration(seconds: 20),
          curve: Curves.easeOut,
          left: leftPosition,
          top: topPosition + (Random().nextInt(200).toDouble()), // Animation vers le bas
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      });
    });
  }*/


  bool _moveTiles(String direction) {
    bool moved = false;

    if (direction == "left") {
      for (int i = 0; i < 4; i++) {
        List<int> row = grid[i];
        moved = _mergeAndSlide(row) || moved;
      }
    } else if (direction == "right") {
      for (int i = 0; i < 4; i++) {
        List<int> row = grid[i].reversed.toList();
        moved = _mergeAndSlide(row);
        grid[i] = row.reversed.toList();
      }
    } else if (direction == "up") {
      for (int j = 0; j < 4; j++) {
        List<int> column = [grid[0][j], grid[1][j], grid[2][j], grid[3][j]];
        moved = _mergeAndSlide(column) || moved;
        for (int i = 0; i < 4; i++) {
          grid[i][j] = column[i];
        }
      }
    } else if (direction == "down") {
      for (int j = 0; j < 4; j++) {
        List<int> column = [grid[3][j], grid[2][j], grid[1][j], grid[0][j]];
        moved = _mergeAndSlide(column);
        List<int> reversed = column.reversed.toList();
        for (int i = 0; i < 4; i++) {
          grid[i][j] = reversed[i];
        }
      }
    }

    return moved;
  }

  bool _mergeAndSlide(List<int> line) {
    bool moved = false;
    List<int> newLine = line.where((value) => value != 0).toList();

    for (int i = 0; i < newLine.length - 1; i++) {
      if (newLine[i] == newLine[i + 1]) {
        newLine[i] *= 2;
        newLine[i + 1] = 0;
        moved = true;
      }
    }

    newLine = newLine.where((value) => value != 0).toList();
    while (newLine.length < 4) {
      newLine.add(0);
    }

    for (int i = 0; i < 4; i++) {
      if (line[i] != newLine[i]) {
        moved = true;
      }
      line[i] = newLine[i];
    }

    return moved;
  }



  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.grey[300]!;
      case 4:
        return Colors.yellow[400]!;
      case 8:
        return Colors.orange[400]!;
      case 16:
        return Colors.red[500]!;
      case 32:
        return Colors.pink[600]!;
      case 64:
        return Colors.orange[700]!;
      case 128:
        return Colors.green[500]!;
      case 256:
        return Colors.green[600]!;
      case 512:
        return Colors.blue[400]!;
      case 1024:
        return Colors.blue[500]!;
      case 2048:
        return Colors.blue[600]!;
      default:
        return Colors.grey;
    }
  }

  void _onCheckBoxChanged(bool? value) {
    setState(() {
      isRandomGrid = value!;
    });
  }

  void _onDifficultyChange(int? value) {
    setState(() {
      targetValue = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048 Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showAboutDialog,
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showRulesDialog,
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy > 0) {
            _onSwipe("down");
          } else {
            _onSwipe("up");
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            _onSwipe("right");
          } else {
            _onSwipe("left");
          }
        },
        child: Center(
          child: Stack(
            children: [
              // Grille de jeu
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Coups: $moveCount',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        int value = grid[index ~/ 4][index % 4];
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: value == 0 ? Colors.grey[300] : _getTileColor(value),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            value > 0 ? '$value' : '',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Grille aléatoire'),
                    value: isRandomGrid,
                    onChanged: _onCheckBoxChanged,
                  ),
                  DropdownButton<int>(
                    value: targetValue,
                    onChanged: _onDifficultyChange,
                    items: const [
                      DropdownMenuItem(value: 32, child: Text('32')),
                      DropdownMenuItem(value: 64, child: Text('64')),
                      DropdownMenuItem(value: 128, child: Text('128')),
                      DropdownMenuItem(value: 256, child: Text('256')),
                      DropdownMenuItem(value: 512, child: Text('512')),
                      DropdownMenuItem(value: 1024, child: Text('1024')),
                      DropdownMenuItem(value: 2048, child: Text('2048')),
                    ],
                  ),
                ],
              ),
              // Affichage des pétales par-dessus la grille
              ...petalWidgets,  // Ajoute les pétales à l'écran
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewGame,
        child: const Icon(Icons.refresh),
        tooltip: 'Nouvelle Partie',
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('À propos'),
          content: const Text('Ceci est une implémentation Flutter du jeu 2048.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Règles'),
          content: const Text(
            'Faites glisser les tuiles pour les fusionner. '
                'Atteignez la valeur cible pour gagner !',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );


  }
}
