import 'package:flutter/material.dart';

class AppConstants {
  // Fatores de conversão
  static const double nitrogenFactor = 0.862;
  static const double oxygenFactor = 0.754;
  static const double argonFactor = 0.604;

  // Cores Principais
  static const Color primaryColor = Color(0xFF1c2946); // Modern Slate/Navy
  static const Color primaryColorDark = Color(0xFF0F172A);
  static const Color accentColor = Color(0xFF7690c0); // Sky Blue
  static const Color scaffoldBackgroundColor = Color(0xFFF1F5F9); // Slate 100
  static const Color cardColor = Colors.white;

  // Cores dos Botões (Produtos)
  static const Color nitrogenColor = Color(0xFF1c2946); // Blue 500
  static const Color oxygenColor = Color(0xFF1c2946); // Emerald 500
  static const Color argonColor = Color(0xFF1c2946); // Violet 500

  // Botões de Ação
  static const Color clearButtonColor =
      Color.fromARGB(255, 118, 144, 192); // Amber 500
  static const Color resultButtonColor = Color(0xFFFFFFFF);
  static const Color resultTextColor = Color(0xFF1E293B);

  // Styles
  static const double defaultBorderRadius = 16.0;
  static const double defaultElevation = 4.0;

  // Textos
  static const String appTitle = 'Calculadora de Gases';
  static const String nitrogenLabel = 'Nitrogênio';
  static const String oxygenLabel = 'Oxigênio';
  static const String argonLabel = 'Argônio';
  static const String clearLabel = 'Limpar';
  static const String alertTitle = 'Atenção';
  static const String alertMessageInvalidInput =
      'Por favor, insira valores válidos para fator e polegadas.';
  static const String alertMessageEmptyWeight =
      'Por favor, insira o peso líquido.';
  static const String okButtonLabel = 'OK';
}
