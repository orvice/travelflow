import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/travel_plan.dart';

class HistoryService {
  static const String _fileName = 'travel_history.json';
  static HistoryService? _instance;

  factory HistoryService() {
    _instance ??= HistoryService._internal();
    return _instance!;
  }

  HistoryService._internal();

  Future<File> _getHistoryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<TravelPlan>> getHistory() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => TravelPlan.fromJson(json)).toList();
    } catch (e) {
      print('Error loading history: $e');
      return [];
    }
  }

  Future<void> saveHistory(List<TravelPlan> history) async {
    try {
      final file = await _getHistoryFile();
      final jsonList = history.map((plan) => plan.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  Future<void> addTravelPlan(TravelPlan plan) async {
    try {
      final history = await getHistory();

      // 检查是否已存在相同ID的记录
      final existingIndex = history.indexWhere((p) => p.id == plan.id);
      if (existingIndex != -1) {
        history[existingIndex] = plan;
      } else {
        history.insert(0, plan);
      }

      // 限制历史记录数量，最多保留50条
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      await saveHistory(history);
    } catch (e) {
      print('Error adding travel plan: $e');
    }
  }

  Future<void> removeTravelPlan(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((plan) => plan.id == id);
      await saveHistory(history);
    } catch (e) {
      print('Error removing travel plan: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  Future<TravelPlan?> getTravelPlanById(String id) async {
    try {
      final history = await getHistory();
      return history.firstWhere((plan) => plan.id == id);
    } catch (e) {
      print('Error getting travel plan by id: $e');
      return null;
    }
  }
}
