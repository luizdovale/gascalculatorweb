import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_helper.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  // Logic Variables
  String _output =
      "0"; // Represents the logical numerical string (e.g. 1234.56)
  double _num1 = 0;
  double _num2 = 0;
  String _operand = "";
  bool _shouldClearInput = false;
  final List<String> _calcHistory = [];

  // Colors
  final Color _colorDarkGray = const Color(0xFF333333);
  final Color _colorLightGray = const Color(0xFFA5A5A5);
  final Color _colorOrange = const Color(0xFFFF9F0A);
  final Color _colorBlack = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryHelper.getCommonCalcHistory();
    setState(() {
      _calcHistory.clear();
      _calcHistory.addAll(history);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBlack,
      appBar: AppBar(
        backgroundColor: _colorBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Spacer to push buttons down
                const Spacer(),

                // Display Area
                Container(
                  alignment: Alignment.bottomRight,
                  height: 120, // Altura fixa para evitar pulos no layout
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatDisplay(_output),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),

                // Buttons Grid
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildButtonRow("AC", "X", "%", "÷"),
                      const SizedBox(height: 12),
                      _buildButtonRow("7", "8", "9", "×"),
                      const SizedBox(height: 12),
                      _buildButtonRow("4", "5", "6", "-"),
                      const SizedBox(height: 12),
                      _buildButtonRow("1", "2", "3", "+"),
                      const SizedBox(height: 12),
                      _buildLastRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(String b1, String b2, String b3, String b4) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(b1),
        _buildButton(b2),
        _buildButton(b3),
        _buildButton(b4, isOperator: true),
      ],
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton("√"),
        _buildButton("0"),
        _buildButton("."),
        _buildButton("=", isOperator: true),
      ],
    );
  }

  Widget _buildButton(String text, {bool isOperator = false}) {
    Color bgColor;
    Color textColor;

    // Standard styling logic
    if (["AC", "X", "%", "+/-", "√"].contains(text)) {
      bgColor = _colorLightGray;
      textColor = Colors.black;
    } else if (isOperator) {
      bgColor = _colorOrange;
      textColor = Colors.white;
    } else {
      bgColor = _colorDarkGray;
      textColor = Colors.white;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double effectiveWidth = screenWidth > 500 ? 500 : screenWidth;

    double screenHeight = MediaQuery.of(context).size.height;
    double maxButtonHeight = (screenHeight - 300) / 5;

    double size = (effectiveWidth - 100) / 4;
    if (size > maxButtonHeight && maxButtonHeight > 0) {
      size = maxButtonHeight;
    }

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () => _onPressed(text),
        child: text == "X"
            ? Icon(Icons.backspace_outlined, color: textColor, size: 28)
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  void _onPressed(String btnText) {
    Vibration.hasVibrator().then((has) {
      if (has == true) {
        Vibration.vibrate(duration: 10);
      }
    });

    setState(() {
      if (btnText == "AC") {
        _output = "0";
        _num1 = 0;
        _num2 = 0;
        _operand = "";
        _shouldClearInput = false;
      } else if (btnText == "X") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (btnText == "√") {
        double val = double.tryParse(_output) ?? 0;
        if (val < 0) {
          _output = "Erro";
          _shouldClearInput = true;
        } else {
          _output = sqrt(val).toString();
          if (_output.endsWith(".0")) {
            _output = _output.substring(0, _output.length - 2);
          }
          _shouldClearInput = true;
        }
      } else if (btnText == "%") {
        double val = double.tryParse(_output) ?? 0;
        // Don't format here, keep logic string pure
        _output = (val / 100).toString();
        // Remove trailing .0 if integer
        if (_output.endsWith(".0")) {
          _output = _output.substring(0, _output.length - 2);
        }
      } else if (["+", "-", "×", "÷"].contains(btnText)) {
        _num1 = double.tryParse(_output) ?? 0;
        _operand = btnText;
        _shouldClearInput = true;
      } else if (btnText == "=") {
        if (_operand.isNotEmpty) {
          _num2 = double.tryParse(_output) ?? 0;
          if (_shouldClearInput) {
            _num2 = _num1;
          }

          double result = 0;
          if (_operand == "+") result = _num1 + _num2;
          if (_operand == "-") result = _num1 - _num2;
          if (_operand == "×") result = _num1 * _num2;
          if (_operand == "÷") {
            if (_num2 != 0) {
              result = _num1 / _num2;
            } else {
              _output = "Erro";
              _operand = ""; // Reset
              _shouldClearInput = true;
              return;
            }
          }

          // Logic string should be standard float format (dot separator)
          String resultStr = result.toString();
          // Remove trailing .0 if integer
          if (resultStr.endsWith(".0")) {
            resultStr = resultStr.substring(0, resultStr.length - 2);
          }

          // Save to history before updating output
          String op =
              "${_formatDisplay(_num1.toString())} $_operand ${_formatDisplay(_num2.toString())} = ${_formatDisplay(resultStr)}";

          setState(() {
            _calcHistory.insert(0, op);
            if (_calcHistory.length > 20) {
              _calcHistory.removeLast();
            }
          });

          // Persist to disk
          HistoryHelper.addToCommonCalcHistory(op);

          _output = resultStr;
          _shouldClearInput = true;
          _operand = "";
        }
      } else {
        // Numbers or Decimal
        if (_shouldClearInput) {
          _output = "0";
          _shouldClearInput = false;
        }

        if (btnText == ".") {
          if (!_output.contains(".")) {
            _output = "$_output.";
          }
        } else {
          // Numbers
          if (_output == "0") {
            _output = btnText;
          } else {
            _output = _output + btnText;
          }
        }
      }
    });
  }

  // Returns the formatted display string (pt-BR)
  // Input: "1234.56" -> Output: "1.234,56"
  String _formatDisplay(String logicString) {
    if (logicString == "Erro") return "Erro";

    // Split integer and decimal parts
    List<String> parts = logicString.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Format integer part with thousand separators (dot)
    // We can use NumberFormat, but we must handle partial inputs carefully.
    // If logicString is just numbers, formatting is easy.
    // Negative sign handling
    bool isNegative = integerPart.startsWith('-');
    if (isNegative) integerPart = integerPart.substring(1);

    final formatter = NumberFormat("#,###", "pt_BR");
    // Ensure we parse correctly (formatter expects standard format input logic? No, it expects numbers)
    // Actually NumberFormat pt_BR uses dot for thousands and comma for decimal.
    // We just want to format the integer part first.

    String formattedInteger;
    if (integerPart.isEmpty) {
      formattedInteger = "0";
    } else {
      try {
        // Parse generic doesn't work well with partials, so let's format raw number logic
        double val = double.parse(integerPart);
        formattedInteger = formatter.format(val); // This gives 1.234
      } catch (e) {
        formattedInteger = integerPart;
      }
    }

    if (isNegative) formattedInteger = "-$formattedInteger";

    if (decimalPart != null) {
      return "$formattedInteger,$decimalPart";
    } else if (logicString.endsWith(".")) {
      // User just typed decimal point
      return "$formattedInteger,";
    }

    return formattedInteger;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Últimas Operações",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_calcHistory.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          await HistoryHelper.clearCommonCalcHistory();
                          setState(() {
                            _calcHistory.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white54, size: 18),
                        label: Text(
                          "Limpar",
                          style: GoogleFonts.outfit(
                              color: Colors.white54, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              if (_calcHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "Nenhuma operação recente",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _calcHistory.length,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          _calcHistory[index],
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
