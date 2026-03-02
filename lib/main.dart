import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:vet_advice_app/screens/test_screen.dart';
import 'screens/questionnaire_screen.dart';
import 'services/database_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Приложение запускается...');
  print('Платформа: ${kIsWeb ? "Web" : "Native"}');
  
  try {
    // Инициализация SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    print('✅ SharedPreferences инициализированы');
    
    // Инициализация SQLite для соответствующей платформы
    if (kIsWeb) {
      print('📦 Инициализация SQLite для Web...');
      databaseFactory = databaseFactoryFfiWeb;
      print('✅ SQLite для Web инициализирован');
    } else {
      print('📦 Инициализация SQLite для Native...');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print('✅ SQLite для Native инициализирован');
    }
    
    // Инициализируем сервис базы данных
    print('📂 Инициализация DatabaseService...');
    final databaseService = DatabaseService();
    await databaseService.init();
    print('✅ DatabaseService инициализирован');
    
    // Проверяем, есть ли данные
    final questions = await databaseService.getQuestionsWithAnswers();
    print('📊 Загружено вопросов: ${questions.length}');
    
    runApp(const VetAdviceApp());
    print('🎯 Приложение запущено');
  } catch (e, stackTrace) {
    print('❌ ОШИБКА: $e');
    print('📚 StackTrace: $stackTrace');
    
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Ошибка инициализации',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    print('🔄 Перезагрузка...');
                    // Просто перезапускаем приложение
                    main();
                  },
                  child: Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class VetAdviceApp extends StatelessWidget {
  const VetAdviceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ветеринарный помощник',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const QuestionnaireScreen(),
      // home: const QuestionnaireScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}