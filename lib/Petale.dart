import 'package:flutter/material.dart';
import 'dart:math';  // Nécessaire pour générer des valeurs aléatoires

class Petal extends StatefulWidget {
  final double size;
  final double leftPosition;
  final double topPosition;

  Petal({
    required this.size,
    required this.leftPosition,
    required this.topPosition,
  });

  @override
  _PetalState createState() => _PetalState();
}

class _PetalState extends State<Petal> with SingleTickerProviderStateMixin {
  late double _topPosition;
  late double _leftPosition;
  late double _size;

  late AnimationController _animationController;
  late Animation<double> _topAnimation;

  @override
  void initState() {
    super.initState();

    _topPosition = widget.topPosition;
    _leftPosition = widget.leftPosition;
    _size = widget.size;

    // Initialiser le contrôleur d'animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Durée de l'animation
    );

    // Créer une animation qui déplace le pétale de haut en bas
    _topAnimation = Tween<double>( // L'animation est verticale
      begin: _topPosition,
      end: _topPosition + 600.0, // Position finale (plus bas)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Courbe d'animation pour un mouvement fluide
      ),
    );

    // Lancer l'animation dès que l'animationController est prêt
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Nettoyer le contrôleur
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _topAnimation,
      builder: (context, child) {
        return Positioned(
          left: _leftPosition,  // Position horizontale aléatoire
          top: _topAnimation.value, // Position verticale animée
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class PetalAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final random = Random();  // Utilisation de Random pour générer des positions aléatoires
    final petalWidgets = List.generate(200, (index) {
      double size = 5.0 + random.nextInt(5) * 5.0; // Taille aléatoire entre 5 et 25
      double leftPosition = random.nextDouble() * MediaQuery.of(context).size.width; // Position horizontale aléatoire
      double topPosition = -size - random.nextDouble() * 100.0; // Position verticale au-dessus de l'écran

      return Petal(
        size: size,
        leftPosition: leftPosition,
        topPosition: topPosition,
      );
    });

    return Scaffold(
      body: Stack(
        children: petalWidgets,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: PetalAnimation()));
}
