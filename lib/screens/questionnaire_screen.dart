import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/recommendation_service.dart';
import '../models/question.dart';
import '../models/product.dart';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final DatabaseService _dbService = DatabaseService();
  final RecommendationService _recommendationService = RecommendationService();
  
  List<Question> _questions = [];
  Map<int, int> _selectedAnswers = {}; // questionId -> answerId
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await _dbService.getQuestionsWithAnswers();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки вопросов: $e';
      });
    }
  }

  void _selectAnswer(int questionId, int answerId) {
    setState(() {
      _selectedAnswers[questionId] = answerId;
    });

    // Автоматически переходим к следующему вопросу
    if (_currentQuestionIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _currentQuestionIndex++;
        });
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _getRecommendation() async {
    // Проверяем, все ли вопросы отвечены
    if (_selectedAnswers.length < _questions.length) {
      _showDialog(
        'Внимание',
        'Пожалуйста, ответьте на все вопросы',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = await _recommendationService.findProduct(_selectedAnswers);
      
      setState(() {
        _isLoading = false;
      });

      if (product != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(product: product),
          ),
        );
      } else {
        _showDialog(
          'Не найдено',
          'Не найдено подходящего продукта для указанных параметров',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Ошибка', 'Произошла ошибка при поиске: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetQuestionnaire() {
    setState(() {
      _selectedAnswers = {};
      _currentQuestionIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Загрузка...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Нет доступных вопросов'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подбор лекарства'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetQuestionnaire,
            tooltip: 'Начать заново',
          ),
        ],
      ),
      body: Column(
        children: [
          // Прогресс бар
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          
          // Индикатор вопроса
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Вопрос ${_currentQuestionIndex + 1} из ${_questions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Текущий вопрос
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Варианты ответов
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion.answers.length,
                      itemBuilder: (ctx, index) {
                        final answer = currentQuestion.answers[index];
                        final isSelected = _selectedAnswers[currentQuestion.id] == answer.id;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ElevatedButton(
                            onPressed: () => _selectAnswer(
                              currentQuestion.id,
                              answer.id,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isSelected ? Colors.blue : Colors.white,
                              foregroundColor: isSelected ? Colors.white : Colors.black,
                              side: BorderSide(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: isSelected ? 4 : 1,
                            ),
                            child: Text(
                              answer.text,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Навигационные кнопки
                  Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goToPreviousQuestion,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('НАЗАД'),
                          ),
                        ),
                      if (_currentQuestionIndex > 0)
                        const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentQuestionIndex == _questions.length - 1
                              ? _getRecommendation
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'ПОДОБРАТЬ'
                                : 'ДАЛЕЕ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}