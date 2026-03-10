import 'dart:ui';
import 'package:flutter/material.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fundo Base Off-white
        Container(
          color: const Color(0xFFF8FAFC), // Slate 50
        ),

        // Blob de luz Azul Claro (Topo Esquerdo)
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0F2FE).withOpacity(0.4), // Blue 50
            ),
          ),
        ),

        // Blob de luz Amarelo Sutil (Baixo Direita)
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFEF9C3).withOpacity(0.3), // Yellow 50
            ),
          ),
        ),

        // Blob de luz Slate Sutil (Centro Direita)
        Positioned(
          top: 200,
          right: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9).withOpacity(0.5), // Slate 100
            ),
          ),
        ),

        // Filtro de Blur para misturar os blobs (Mesh Effect)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
          child: Container(
            color: Colors.transparent,
          ),
        ),

        // Conteúdo do App
        child,
      ],
    );
  }
}
