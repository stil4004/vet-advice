import 'package:flutter/material.dart';

class AppConstants {
  // Настройки приложения
  static const String appName = 'Ветеринарный помощник';
  static const String appVersion = '1.0.0';
  
  // Цвета
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.green;
  static const Color accentColor = Colors.orange;
  static const Color errorColor = Colors.red;
  
  // Тексты
  static const String loadingText = 'Загрузка...';
  static const String errorText = 'Произошла ошибка';
  static const String noProductFound = 'Не найдено подходящего продукта';
  static const String answerAllQuestions = 'Пожалуйста, ответьте на все вопросы';
  
  // Настройки синхронизации
  static const int syncTimeoutSeconds = 5;
  static const String syncEndpoint = '/api/products';
  static const String healthEndpoint = '/api/health';
  
  // Типы животных
  static const String animalTypeCat = 'cat';
  static const String animalTypeDog = 'dog';
  static const String animalTypeBoth = 'both';
  
  // Пути к изображениям
  static const String defaultImagePath = 'assets/images/default.png';
  static const String productsImagePath = 'assets/images/products/';
  
  // Возрастные категории
  static const int puppyKittenAge = 1;
  static const int adultAge = 7;
  
  // Размеры
  static const double buttonHeight = 50;
  static const double cardBorderRadius = 12;
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
}

class ApiEndpoints {
  static String getProducts(String baseUrl) => '$baseUrl/products';
  static String getHealth(String baseUrl) => '$baseUrl/health';
  static String syncData(String baseUrl) => '$baseUrl/sync';
}

class StorageKeys {
  static const String lastSyncTime = 'last_sync_time';
  static const String databaseVersion = 'database_version';
  static const String userPreferences = 'user_preferences';
}

class ErrorMessages {
  static const String networkError = 'Ошибка сети. Проверьте подключение.';
  static const String serverError = 'Ошибка сервера. Попробуйте позже.';
  static const String databaseError = 'Ошибка базы данных.';
  static const String unknownError = 'Неизвестная ошибка.';
}