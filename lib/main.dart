import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calculator.dart';
import 'calculopeso.dart';
import 'constants.dart';
import 'widgets/custom_button.dart';
import 'history_helper.dart';
import 'history_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'splash_screen.dart';
import 'widgets/mesh_background.dart';

void main() {
  runApp(GasCalculatorApp());
}

class GasCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData.light().copyWith(
          primaryColor: AppConstants.primaryColor,
          scaffoldBackgroundColor: AppConstants.scaffoldBackgroundColor,
          // Removed unnecessary theme customizations for clarity
        ),
        themeMode: ThemeMode.light,
        home: SplashScreen(),
      ),
    );
  }
}

class GasCalculator extends StatefulWidget {
  @override
  _GasCalculatorState createState() => _GasCalculatorState();
}

class _GasCalculatorState extends State<GasCalculator> {
  String _version = "";
  String _buildNumber = "";

  final TextEditingController fatorController = TextEditingController();
  final TextEditingController nivelInicialController = TextEditingController();
  final TextEditingController nivelFinalController = TextEditingController();
  final TextEditingController polegadasController = TextEditingController();
  final TextEditingController pesoLiquidoController = TextEditingController();
  final TextEditingController m3Controller = TextEditingController();

  final FocusNode nivelInicialFocusNode = FocusNode();
  final FocusNode nivelFinalFocusNode = FocusNode();
  final FocusNode fatorFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    fatorController.addListener(() => handleInput(fatorController));
    nivelInicialController
        .addListener(() => handleInput(nivelInicialController));
    nivelFinalController.addListener(() => handleInput(nivelFinalController));
    nivelFinalController.addListener(_calculatePolegadas);
  }

  @override
  void dispose() {
    fatorController.dispose();
    nivelInicialController.dispose();
    nivelFinalController.dispose();
    pesoLiquidoController.dispose();
    m3Controller.dispose();
    nivelInicialFocusNode.dispose();
    nivelFinalFocusNode.dispose();
    fatorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  void handleInput(TextEditingController controller) {
    String currentText = controller.text;
    if (currentText.contains(',')) {
      currentText = currentText.replaceAll(',', '.');
      controller.value = TextEditingValue(
        text: currentText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: currentText.length),
        ),
      );
    }
  }

  void _calculatePolegadas() {
    double nivelInicial = double.tryParse(nivelInicialController.text) ?? 0.0;
    double nivelFinal = double.tryParse(nivelFinalController.text) ?? 0.0;
    double polegadas = nivelFinal - nivelInicial;
    setState(() {
      polegadasController.text = polegadas.toStringAsFixed(2);
    });
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    return formatter.format(number);
  }

  void calculateGas(double factor, String gasName) {
    double fatorTanque = double.tryParse(fatorController.text) ?? 0.0;
    double polegadas = double.tryParse(polegadasController.text) ?? 0.0;

    if (fatorTanque == 0.0 || polegadas == 0.0) {
      _showAlert(AppConstants.alertMessageInvalidInput);
      return;
    }

    // A lógica original dividia pelo fator específico.
    // Nitrogênio: (fator * polegadas) / 0.862
    // Oxigênio: (fator * polegadas) / 0.754
    // Argônio: (fator * polegadas) / 0.604
    double pesoLiquido = (fatorTanque * polegadas) / factor;
    pesoLiquido = pesoLiquido.roundToDouble();
    double m3 = pesoLiquido * factor;

    String pesoFormatted = _formatNumber(pesoLiquido);
    String m3Formatted = _formatNumber(m3);

    setState(() {
      pesoLiquidoController.text = pesoFormatted;
      m3Controller.text = m3Formatted;
    });

    // Salvar no histórico
    HistoryHelper.addToHistory(HistoryItem(
      date: DateTime.now(),
      gasName: gasName,
      weight: "$pesoFormatted kg",
      volume: "$m3Formatted m³",
    ));
  }

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
          actions: [
            TextButton(
              child: Text(
                AppConstants.okButtonLabel,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void limpar() {
    setState(() {
      fatorController.text = '';
      nivelInicialController.text = '';
      nivelFinalController.text = '';
      polegadasController.text = '';
      pesoLiquidoController.text = '';
      m3Controller.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppConstants.appTitle,
          style: GoogleFonts.outfit(
            // Switching to Outfit or keeping Quicksand but cleaner
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: IconThemeData(color: Colors.white),
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
      drawer: _buildDrawer(context),
      body: MeshBackground(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildInputRow(isSmallScreen),
                        SizedBox(height: 10),
                        _buildFactorRow(isSmallScreen),
                        SizedBox(height: 15),
                        _buildActionButtons(isSmallScreen),
                        SizedBox(height: 15),
                        _buildResultButtons(isSmallScreen),
                        SizedBox(height: 15),
                        _buildFooterButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fire_truck, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Menu Principal',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildDrawerItem(
                    icon: Icons.calculate,
                    label: 'Calculadora Comum',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Calculator()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.balance,
                    label: 'Cálculo Balança',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CalculoBalancaScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.history,
                    label: 'Histórico',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'versão $_version+$_buildNumber',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppConstants.primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'luizdovaletech',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppConstants.primaryColor.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.accentColor),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: AppConstants.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInputRow(bool isSmallScreen) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildTextFieldContainer(
            controller: nivelInicialController,
            focusNode: nivelInicialFocusNode,
            label: 'Nível Inicial',
            icon: Icons.leaderboard_outlined,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(nivelFinalFocusNode),
            textInputType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(width: isSmallScreen ? 5 : 15),
        Expanded(
          child: _buildTextFieldContainer(
            controller: nivelFinalController,
            focusNode: nivelFinalFocusNode,
            label: 'Nível Final',
            icon: Icons.leaderboard,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(fatorFocusNode),
            textInputType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildFactorRow(bool isSmallScreen) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildTextFieldContainer(
            controller: fatorController,
            focusNode: fatorFocusNode,
            label: 'Fator',
            icon: Icons.propane_tank,
            // Changed validation to allow numbers, but kept flexible if needed.
            // Using logic from original but cleaner.
            textInputType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(width: isSmallScreen ? 5 : 10),
        Expanded(
          child: _buildTextFieldContainer(
            controller: polegadasController,
            label: 'Polegadas',
            icon: Icons.format_quote,
            readOnly: true,
            textInputType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldContainer({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool readOnly = false,
    required TextInputType textInputType,
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
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: AppConstants.primaryColor.withOpacity(0.6),
              fontWeight: FontWeight.w500),
          hintText: readOnly ? 'Calculado' : 'Digite o $label'.toLowerCase(),
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
        inputFormatters:
            textInputType == TextInputType.numberWithOptions(decimal: true)
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                : null,
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CustomGasButton(
                  label: AppConstants.nitrogenLabel,
                  onPressed: () => calculateGas(
                      AppConstants.nitrogenFactor, AppConstants.nitrogenLabel),
                  color: AppConstants.nitrogenColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CustomGasButton(
                  label: AppConstants.oxygenLabel,
                  onPressed: () => calculateGas(
                      AppConstants.oxygenFactor, AppConstants.oxygenLabel),
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
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CustomGasButton(
                  label: AppConstants.argonLabel,
                  onPressed: () => calculateGas(
                      AppConstants.argonFactor, AppConstants.argonLabel),
                  color: AppConstants.argonColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
    );
  }

  Widget _buildResultButtons(bool isSmallScreen) {
    // Reusing the style from original but could also be a READ-ONLY CustomButton if desired.
    // Keeping similar visual to original but cleaner code.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildResultButton(
          pesoLiquidoController.text.isEmpty
              ? 'Peso Líquido'
              : '${pesoLiquidoController.text} kg',
          isSmallScreen,
          opacity: 1.0,
        ),
        _buildResultButton(
          m3Controller.text.isEmpty ? 'm³' : '${m3Controller.text} m³',
          isSmallScreen,
          opacity: 1.0, // Original had opacity difference?
          // Original: _resultButtonColor (White)
        ),
      ],
    );
  }

  Widget _buildResultButton(String text, bool isSmallScreen,
      {double opacity = 1.0}) {
    // Making result buttons look like Cards instead of just buttons
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border:
                Border.all(color: AppConstants.primaryColor.withOpacity(0.1)),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.resultTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalculoBalancaScreen()),
          );
        },
        icon: Icon(Icons.scale, color: Colors.white), // Use modern icon
        label: Text(
          'Ir para Cálculo por Balança',
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
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
