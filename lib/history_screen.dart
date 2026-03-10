import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'history_helper.dart';
import 'widgets/mesh_background.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryHelper.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar Histórico'),
        content: Text('Tem certeza que deseja apagar todo o histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await HistoryHelper.clearHistory();
              Navigator.pop(context);
              _loadHistory();
            },
            child: Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Histórico',
          style: GoogleFonts.outfit(
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
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: _clearHistory,
              tooltip: 'Limpar Histórico',
            ),
        ],
      ),
      body: MeshBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 64, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Histórico vazio',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppConstants.primaryColor
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          Color itemColor = AppConstants.accentColor;
                          if (item.gasName == AppConstants.nitrogenLabel) {
                            itemColor = AppConstants.nitrogenColor;
                          } else if (item.gasName == AppConstants.oxygenLabel) {
                            itemColor = AppConstants.oxygenColor;
                          } else if (item.gasName == AppConstants.argonLabel) {
                            itemColor = AppConstants.argonColor;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultBorderRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: itemColor.withOpacity(0.1),
                                child: Icon(Icons.science, color: itemColor),
                              ),
                              title: Text(
                                item.gasName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColorDark),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text('Peso: ${item.weight}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Text('Volume: ${item.volume}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(item.date),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
