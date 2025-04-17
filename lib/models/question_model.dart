class QuestionModel {
  final String? id;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  QuestionModel({
    this.id,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    print('Received JSON: $json');
    return QuestionModel(
      id: json['id']?.toString(),
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers,
    };
  }

  // Helper to get all answers shuffled
  List<String> get allAnswers {
    final answers = List<String>.from(incorrectAnswers);
    answers.add(correctAnswer);
    answers.shuffle();
    return answers;
  }
}
