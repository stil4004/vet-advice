class DatabaseModel {
  // Версия базы данных
  static const int version = 1;
  
  // Имя базы данных
  static const String name = 'vet_advice.db';

  // Имена таблиц
  static const String tableQuestions = 'questions';
  static const String tableAnswers = 'answers';
  static const String tableProducts = 'products';
  static const String tableProductConditions = 'product_conditions';

  // SQL для создания таблиц
  static String get createQuestionsTable => '''
    CREATE TABLE IF NOT EXISTS $tableQuestions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question_text TEXT NOT NULL,
      order_num INTEGER NOT NULL
    )
  ''';

  static String get createAnswersTable => '''
    CREATE TABLE IF NOT EXISTS $tableAnswers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question_id INTEGER NOT NULL,
      answer_text TEXT NOT NULL,
      FOREIGN KEY (question_id) REFERENCES $tableQuestions(id) ON DELETE CASCADE
    )
  ''';

  static String get createProductsTable => '''
    CREATE TABLE IF NOT EXISTS $tableProducts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      image_path TEXT,
      animal_type TEXT CHECK(animal_type IN ('cat', 'dog', 'both')),
      min_age INTEGER,
      max_age INTEGER
    )
  ''';

  static String get createProductConditionsTable => '''
    CREATE TABLE IF NOT EXISTS $tableProductConditions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      question_id INTEGER NOT NULL,
      answer_id INTEGER NOT NULL,
      FOREIGN KEY (product_id) REFERENCES $tableProducts(id) ON DELETE CASCADE,
      FOREIGN KEY (question_id) REFERENCES $tableQuestions(id) ON DELETE CASCADE,
      FOREIGN KEY (answer_id) REFERENCES $tableAnswers(id) ON DELETE CASCADE,
      UNIQUE(product_id, question_id, answer_id)
    )
  ''';

  // Индексы
  static String get createAnswersIndex => '''
    CREATE INDEX IF NOT EXISTS idx_answers_question_id ON $tableAnswers(question_id)
  ''';

  static String get createConditionsProductIndex => '''
    CREATE INDEX IF NOT EXISTS idx_conditions_product_id ON $tableProductConditions(product_id)
  ''';

  static String get createConditionsQuestionIndex => '''
    CREATE INDEX IF NOT EXISTS idx_conditions_question_id ON $tableProductConditions(question_id)
  ''';
}