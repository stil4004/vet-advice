import 'package:flutter/material.dart';
import 'package:vet_advice_app/models/answer.dart';
import '../models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswerId;
  final Function(int answerId) onAnswerSelected;

  const QuestionCard({
    Key? key,
    required this.question,
    this.selectedAnswerId,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...question.answers.map((answer) => _buildAnswerButton(answer)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(Answer answer) {
    final isSelected = selectedAnswerId == answer.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onAnswerSelected(answer.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Text(
            answer.text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}