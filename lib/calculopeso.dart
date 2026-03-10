import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';
import 'constants.dart';
import 'widgets/custom_button.dart';
import 'history_helper.dart';
import 'history_screen.dart';
import 'widgets/mesh_background.dart';

class CalculoBalancaScreen extends StatefulWidget {
  @override
  _CalculoBalancaScreenState createState() => _CalculoBalancaScreenState();
}

class _CalculoBalancaScreenState extends State<CalculoBalancaScreen> {
  final TextEditingController pesoLiquidoController = TextEditingController();
  final TextEditingController m3Controller = TextEditingController();

  // Função para calcular o m³ com o fator correspondente
  void calcularM3(double fator, String gasName) {
    double pesoLiquido = double.tryParse(pesoLiquidoController.text) ?? 0.0;

    if (pesoLiquido == 0.0) {
      _showAlert(AppConstants.alertMessageEmptyWeight);
      return;
    }

    double resultadoM3 = pesoLiquido * fator;

    // Formatação do número com ponto nos milhares e vírgula decimal, seguido por "m³"
    String resultadoFormatado =
        "${NumberFormat('#,##0.###', 'pt_BR').format(resultadoM3)} m³";

    m3Controller.text = resultadoFormatado;

    // Salvar no histórico
    HistoryHelper.addToHistory(HistoryItem(
      date: DateTime.now(),
      gasName: gasName,
      weight: "${NumberFormat('#,##0.###', 'pt_BR').format(pesoLiquido)} kg",
      volume: resultadoFormatado,
    ));
  }

  // Função para exibir o alerta
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppConstants.primaryColor,
          title: Text(
            AppConstants.alertTitle,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppConstants.okButtonLabel,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função para limpar todos os campos
  void limpar() {
    pesoLiquidoController.clear();
    m3Controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Cálculo Balança",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: MeshBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 15),
                    _buildInputContainer(
                      controller: pesoLiquidoController,
                      label: 'Peso Líquido',
                      hint: 'Digite o peso líquido',
                      icon: Icons.balance,
                      textInputType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 12),
                    _buildInputContainer(
                      controller: m3Controller,
                      label: 'Quantidade em m³',
                      hint: '',
                      icon: Icons.propane_tank_outlined,
                      textInputType: TextInputType.number,
                      readOnly: true,
                    ),
                    SizedBox(height: 15),
                    // Botões de Nitrogênio, Oxigênio e Argônio
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CustomGasButton(
                                  label: AppConstants.nitrogenLabel,
                                  onPressed: () => calcularM3(
                                      AppConstants.nitrogenFactor,
                                      AppConstants.nitrogenLabel),
                                  color: AppConstants.nitrogenColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CustomGasButton(
                                  label: AppConstants.oxygenLabel,
                                  onPressed: () => calcularM3(
                                      AppConstants.oxygenFactor,
                                      AppConstants.oxygenLabel),
                                  color: AppConstants.oxygenColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CustomGasButton(
                                  label: AppConstants.argonLabel,
                                  onPressed: () => calcularM3(
                                      AppConstants.argonFactor,
                                      AppConstants.argonLabel),
                                  color: AppConstants.argonColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CustomGasButton(
                                  label: AppConstants.clearLabel,
                                  onPressed: limpar,
                                  color: AppConstants.clearButtonColor,
                                  textColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigating back using pop instead of push to avoid restarting the app (which shows splash screen)
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GasCalculator()),
                                  );
                                }
                              },
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              label: Text(
                                'Voltar para Cálculo por Fator',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                elevation: AppConstants.defaultElevation,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultBorderRadius),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType textInputType = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: AppConstants.primaryColor.withOpacity(0.6),
              fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppConstants.accentColor),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: textInputType,
        style: TextStyle(
            fontSize: 16,
            color: AppConstants.primaryColorDark,
            fontWeight: FontWeight.w600),
        readOnly: readOnly,
        inputFormatters: formatters,
      ),
    );
  }
}
