import 'package:vet_advice_app/models/answer.dart';

class Question {
  final int id;
  final String text;
  final int orderNum;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.orderNum,
    this.answers = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      text: json['question_text'] as String,
      orderNum: json['order_num'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_text': text,
    'order_num': orderNum,
  };

  @override
  String toString() => 'Question(id: $id, text: $text)';
}