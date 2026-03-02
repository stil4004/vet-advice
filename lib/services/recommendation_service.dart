import '../models/product.dart';
import 'database_service.dart';

class RecommendationService {
  final DatabaseService _dbService = DatabaseService();

  Future<Product?> findProduct(Map<int, int> answers) async {
    return await _dbService.findProductByAnswers(answers);
  }

  // Валидация ответов
  bool validateAnswers(Map<int, int> answers, List<int> requiredQuestions) {
    for (var qId in requiredQuestions) {
      if (!answers.containsKey(qId)) {
        return false;
      }
    }
    return true;
  }

  // Получить список вопросов, на которые нужно ответить
  Future<List<int>> getRequiredQuestionIds() async {
    final questions = await _dbService.getQuestionsWithAnswers();
    return questions.map((q) => q.id).toList();
  }
}