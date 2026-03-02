// services/sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SyncService {
  static const String serverUrl = 'https://your-go-server.com/api'; // Замените на реальный URL
  
  final DatabaseService _dbService = DatabaseService();

  Future<void> syncWithServer() async {
    print('🔄 Попытка синхронизации с сервером...');
    
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Данные получены с сервера');
        
        // Проверяем структуру данных
        if (data.containsKey('products') && 
            data.containsKey('questions') && 
            data.containsKey('answers') && 
            data.containsKey('conditions')) {
          
          await _dbService.importData(
            List<Map<String, dynamic>>.from(data['products']),
            List<Map<String, dynamic>>.from(data['questions']),
            List<Map<String, dynamic>>.from(data['answers']),
            List<Map<String, dynamic>>.from(data['conditions']),
          );
          
          print('✅ Синхронизация успешно завершена');
        } else {
          print('⚠️ Неверный формат данных от сервера');
        }
      } else {
        print('⚠️ Сервер вернул ошибку: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Сервер недоступен, использую локальные данные: $e');
    }
  }

  Future<bool> checkServerAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/health'),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}