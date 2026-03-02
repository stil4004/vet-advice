// services/database_service.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:developer' as developer;
import '../models/question.dart';
import '../models/answer.dart';
import '../models/product.dart';
import '../models/database_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await init();
    return _database!;
  }

  Future<void> init() async {
    if (_database != null) return;
    
    developer.log('📂 DatabaseService.init() начат');
    
    try {
      String path;
      
      if (kIsWeb) {
        path = DatabaseModel.name;
        developer.log('🌐 Веб режим, путь: $path');
      } else {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, DatabaseModel.name);
        developer.log('📁 Нативный режим, путь: $path');
      }
      
      _database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: DatabaseModel.version,
          onCreate: _onCreate,
          onOpen: (db) {
            developer.log('✅ База данных открыта');
            _ensureDataExists(db);
          },
        ),
      );
      
    } catch (e, stackTrace) {
      developer.log('❌ Ошибка в DatabaseService.init()', 
        error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _ensureDataExists(Database db) async {
    try {
      final count = await _getQuestionsCount(db);
      developer.log('📊 Текущее количество вопросов: $count');
      
      if (count == 0) {
        developer.log('🌱 База данных пуста, заполняем тестовыми данными...');
        await _seedInitialData(db);
        developer.log('✅ Тестовые данные загружены');
      }
    } catch (e) {
      developer.log('⚠️ Ошибка при проверке данных: $e');
    }
  }

  Future<int> _getQuestionsCount(Database db) async {
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseModel.tableQuestions}');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    developer.log('🔨 Создание таблиц, версия: $version');
    
    try {
      await db.execute(DatabaseModel.createQuestionsTable);
      await db.execute(DatabaseModel.createAnswersTable);
      await db.execute(DatabaseModel.createProductsTable);
      await db.execute(DatabaseModel.createProductConditionsTable);
      
      await db.execute(DatabaseModel.createAnswersIndex);
      await db.execute(DatabaseModel.createConditionsProductIndex);
      await db.execute(DatabaseModel.createConditionsQuestionIndex);
      
      developer.log('✅ Таблицы созданы');
    } catch (e) {
      developer.log('❌ Ошибка создания таблиц: $e');
      rethrow;
    }
  }

  // Метод для импорта данных с сервера
  Future<void> importData(
    List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> questions,
    List<Map<String, dynamic>> answers,
    List<Map<String, dynamic>> conditions,
  ) async {
    developer.log('📥 Импорт данных с сервера...');
    developer.log('📊 Продуктов: ${products.length}, Вопросов: ${questions.length}, Ответов: ${answers.length}, Условий: ${conditions.length}');
    
    try {
      final db = await database;
      
      await db.transaction((txn) async {
        // Очищаем существующие данные
        developer.log('🧹 Очистка старых данных...');
        await txn.delete(DatabaseModel.tableProductConditions);
        await txn.delete(DatabaseModel.tableProducts);
        await txn.delete(DatabaseModel.tableAnswers);
        await txn.delete(DatabaseModel.tableQuestions);
        
        // Импортируем вопросы
        developer.log('📝 Импорт вопросов...');
        for (var q in questions) {
          await txn.insert(DatabaseModel.tableQuestions, {
            'id': q['id'],
            'question_text': q['question_text'],
            'order_num': q['order_num'],
          });
        }
        
        // Импортируем ответы
        developer.log('📝 Импорт ответов...');
        for (var a in answers) {
          await txn.insert(DatabaseModel.tableAnswers, {
            'id': a['id'],
            'question_id': a['question_id'],
            'answer_text': a['answer_text'],
          });
        }
        
        // Импортируем продукты
        developer.log('📝 Импорт продуктов...');
        for (var p in products) {
          await txn.insert(DatabaseModel.tableProducts, {
            'id': p['id'],
            'name': p['name'],
            'description': p['description'],
            'image_path': p['image_path'] ?? '',
            'animal_type': p['animal_type'],
            'min_age': p['min_age'],
            'max_age': p['max_age'],
          });
        }
        
        // Импортируем условия
        developer.log('📝 Импорт условий...');
        for (var c in conditions) {
          await txn.insert(DatabaseModel.tableProductConditions, {
            'id': c['id'],
            'product_id': c['product_id'],
            'question_id': c['question_id'],
            'answer_id': c['answer_id'],
          });
        }
      });
      
      developer.log('✅ Импорт данных успешно завершен');
      
      // Проверяем результат
      final questionsCount = await _getQuestionsCount(db);
      developer.log('📊 После импорта: $questionsCount вопросов в БД');
      
    } catch (e) {
      developer.log('❌ Ошибка при импорте данных: $e');
      rethrow;
    }
  }

  // Метод для экспорта данных (опционально)
  Future<Map<String, dynamic>> exportData() async {
    developer.log('📤 Экспорт данных...');
    
    try {
      final db = await database;
      
      final questions = await db.query(DatabaseModel.tableQuestions);
      final answers = await db.query(DatabaseModel.tableAnswers);
      final products = await db.query(DatabaseModel.tableProducts);
      final conditions = await db.query(DatabaseModel.tableProductConditions);
      
      developer.log('✅ Экспорт завершен');
      
      return {
        'questions': questions,
        'answers': answers,
        'products': products,
        'conditions': conditions,
      };
    } catch (e) {
      developer.log('❌ Ошибка при экспорте данных: $e');
      rethrow;
    }
  }

  Future<void> _seedInitialData(Database db) async {
    developer.log('🌱 Начало заполнения тестовыми данными...');
    
    try {
      await db.transaction((txn) async {
        // Вопрос 1: Тип животного
        final q1Id = await txn.insert(DatabaseModel.tableQuestions, {
          'question_text': 'Какое у вас животное?',
          'order_num': 1,
        });

        final a1Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q1Id,
          'answer_text': 'Кошка',
        });
        
        final a2Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q1Id,
          'answer_text': 'Собака',
        });

        // Вопрос 2: Возраст
        final q2Id = await txn.insert(DatabaseModel.tableQuestions, {
          'question_text': 'Какой возраст питомца?',
          'order_num': 2,
        });

        final a3Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q2Id,
          'answer_text': 'До 1 года (щенок/котенок)',
        });
        
        final a4Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q2Id,
          'answer_text': '1-7 лет (взрослый)',
        });
        
        final a5Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q2Id,
          'answer_text': 'Старше 7 лет (пожилой)',
        });

        // Вопрос 3: Симптомы
        final q3Id = await txn.insert(DatabaseModel.tableQuestions, {
          'question_text': 'Какие симптомы?',
          'order_num': 3,
        });

        final a6Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q3Id,
          'answer_text': 'Проблемы с суставами',
        });
        
        final a7Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q3Id,
          'answer_text': 'Паразиты (блохи/клещи)',
        });
        
        final a8Id = await txn.insert(DatabaseModel.tableAnswers, {
          'question_id': q3Id,
          'answer_text': 'Проблемы с пищеварением',
        });

        // Продукт 1: Для суставов (пожилые собаки)
        final p1Id = await txn.insert(DatabaseModel.tableProducts, {
          'name': 'АртроБарс',
          'description': 'Хондропротектор для поддержки суставов пожилых собак. Содержит глюкозамин и хондроитин.',
          'image_path': '',
          'animal_type': 'dog',
          'min_age': 7,
          'max_age': null,
        });

        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p1Id,
          'question_id': q1Id,
          'answer_id': a2Id, // Собака
        });
        
        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p1Id,
          'question_id': q2Id,
          'answer_id': a5Id, // Старше 7 лет
        });
        
        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p1Id,
          'question_id': q3Id,
          'answer_id': a6Id, // Проблемы с суставами
        });

        // Продукт 2: От паразитов (для всех)
        final p2Id = await txn.insert(DatabaseModel.tableProducts, {
          'name': 'Барс капли',
          'description': 'Универсальные капли от блох и клещей для кошек и собак. Защита до 4 недель.',
          'image_path': '',
          'animal_type': 'both',
          'min_age': 2,
          'max_age': null,
        });

        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p2Id,
          'question_id': q3Id,
          'answer_id': a7Id, // Паразиты
        });

        // Продукт 3: Для пищеварения (котята)
        final p3Id = await txn.insert(DatabaseModel.tableProducts, {
          'name': 'ПробиоКот',
          'description': 'Пробиотик для котят при проблемах с пищеварением. Нормализует микрофлору кишечника.',
          'image_path': '',
          'animal_type': 'cat',
          'min_age': 0,
          'max_age': 1,
        });

        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p3Id,
          'question_id': q1Id,
          'answer_id': a1Id, // Кошка
        });
        
        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p3Id,
          'question_id': q2Id,
          'answer_id': a3Id, // До 1 года
        });
        
        await txn.insert(DatabaseModel.tableProductConditions, {
          'product_id': p3Id,
          'question_id': q3Id,
          'answer_id': a8Id, // Проблемы с пищеварением
        });
      });
      
      developer.log('✅ Тестовые данные успешно загружены!');
      
    } catch (e) {
      developer.log('❌ Ошибка заполнения тестовыми данными: $e');
      rethrow;
    }
  }

  Future<List<Question>> getQuestionsWithAnswers() async {
    developer.log('📖 Запрос вопросов с ответами');
    
    try {
      final db = await database;
      
      final questions = await db.query(
        DatabaseModel.tableQuestions,
        orderBy: 'order_num',
      );
      
      developer.log('📊 Получено вопросов: ${questions.length}');
      
      List<Question> result = [];
      
      for (var q in questions) {
        final answers = await db.query(
          DatabaseModel.tableAnswers,
          where: 'question_id = ?',
          whereArgs: [q['id']],
        );
        
        result.add(Question(
          id: q['id'] as int,
          text: q['question_text'] as String,
          orderNum: q['order_num'] as int,
          answers: answers.map((a) => Answer(
            id: a['id'] as int,
            questionId: a['question_id'] as int,
            text: a['answer_text'] as String,
          )).toList(),
        ));
      }
      
      return result;
    } catch (e) {
      developer.log('❌ Ошибка получения вопросов: $e');
      return [];
    }
  }

  Future<Product?> findProductByAnswers(Map<int, int> selectedAnswers) async {
    developer.log('🔍 Поиск продукта по ответам: $selectedAnswers');
    
    try {
      final db = await database;
      
      final products = await db.query(DatabaseModel.tableProducts);
      
      for (var p in products) {
        final conditions = await db.query(
          DatabaseModel.tableProductConditions,
          where: 'product_id = ?',
          whereArgs: [p['id']],
        );
        
        if (conditions.isEmpty) continue;
        
        bool matches = true;
        for (var condition in conditions) {
          final questionId = condition['question_id'] as int;
          final requiredAnswerId = condition['answer_id'] as int;
          
          if (!selectedAnswers.containsKey(questionId) || 
              selectedAnswers[questionId] != requiredAnswerId) {
            matches = false;
            break;
          }
        }
        
        if (matches) {
          developer.log('✅ Найден продукт: ${p['name']}');
          return Product(
            id: p['id'] as int,
            name: p['name'] as String,
            description: p['description'] as String,
            imagePath: p['image_path'] as String? ?? '',
            animalType: p['animal_type'] as String,
            minAge: p['min_age'] as int?,
            maxAge: p['max_age'] as int?,
          );
        }
      }
      
      developer.log('❌ Продукт не найден');
      return null;
    } catch (e) {
      developer.log('❌ Ошибка поиска продукта: $e');
      return null;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}