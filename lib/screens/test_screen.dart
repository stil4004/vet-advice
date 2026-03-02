import 'package:flutter/material.dart';
import 'package:vet_advice_app/services/database_service.dart';

class TestDbScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Тест БД')),
      body: FutureBuilder(
        future: _dbService.getQuestionsWithAnswers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (ctx, i) {
              final q = questions[i];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${q.id}. ${q.text}', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      ...q.answers.map((a) => Text('  - ${a.text}')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}