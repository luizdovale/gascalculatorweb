import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final DateTime date;
  final String gasName;
  final String weight;
  final String volume;

  HistoryItem({
    required this.date,
    required this.gasName,
    required this.weight,
    required this.volume,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'gasName': gasName,
        'weight': weight,
        'volume': volume,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        date: DateTime.parse(json['date']),
        gasName: json['gasName'],
        weight: json['weight'],
        volume: json['volume'],
      );
}

class HistoryHelper {
  static const String _key = 'calc_history';
  static const String _calcHistoryKey = 'common_calc_history';

  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => HistoryItem.fromJson(e)).toList();
  }

  static Future<void> addToHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> currentList = await getHistory();

    // Add to beginning (newest first)
    currentList.insert(0, item);

    // Keep only last 15
    if (currentList.length > 15) {
      currentList = currentList.sublist(0, 15);
    }

    final String jsonString =
        jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // --- Common Calculator History Methods ---

  static Future<List<String>> getCommonCalcHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_calcHistoryKey) ?? [];
  }

  static Future<void> addToCommonCalcHistory(String operation) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getCommonCalcHistory();

    history.insert(0, operation);
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }

    await prefs.setStringList(_calcHistoryKey, history);
  }

  static Future<void> clearCommonCalcHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_calcHistoryKey);
  }
}
