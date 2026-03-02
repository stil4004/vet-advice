class Answer {
  final int id;
  final int questionId;
  final String text;

  Answer({
    required this.id,
    required this.questionId,
    required this.text,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      text: json['answer_text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_id': questionId,
    'answer_text': text,
  };

  @override
  String toString() => 'Answer(id: $id, text: $text)';
}