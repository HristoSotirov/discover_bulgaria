import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/landmark_model.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import '../services/visited_landmark_service.dart';
import '../config/preferences_manager.dart';
import '../models/visited_landmark_model.dart';
import '../services/user_service.dart'; // добавен импорт за UserService

class LandmarkQuizScreen extends StatefulWidget {
  final LandmarkModel landmark;
  final String userId;

  const LandmarkQuizScreen({
    super.key,
    required this.landmark,
    required this.userId,
  });

  @override
  _LandmarkQuizScreenState createState() => _LandmarkQuizScreenState();
}

class _LandmarkQuizScreenState extends State<LandmarkQuizScreen> {
  late final QuestionService _questionService;
  late final VisitedLandmarkService _visitedLandmarkService;
  late final PreferencesManager _prefsManager;
  List<QuestionModel> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  bool _isQuizCompleted = false;
  List<String> _currentShuffledAnswers = [];

  @override
  void initState() {
    super.initState();
    _questionService = QuestionService();
    _visitedLandmarkService = VisitedLandmarkService();
    _prefsManager = PreferencesManager();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final allQuestions = await _questionService.getAllQuestions();
      final questions = allQuestions.where((q) => widget.landmark.questions.contains(q.id)).toList();

      setState(() {
        _quizQuestions = questions;
        if (questions.isNotEmpty) {
          _currentShuffledAnswers = List.from(questions[0].allAnswers)..shuffle();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  void _submitAnswer(String answer) {
    if (_isAnswerSubmitted) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswerSubmitted = true;

      if (answer == _quizQuestions[_currentQuestionIndex].correctAnswer) {
        _score += 3; // Each correct answer is worth 3 points
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentShuffledAnswers = List.from(_quizQuestions[_currentQuestionIndex].allAnswers)..shuffle();
        _selectedAnswer = null;
        _isAnswerSubmitted = false;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    try {
      // Актуализираме точките на потребителя
      final currentUser = await UserService().getUserById(widget.userId);
      if (currentUser != null) {
        final newScore = currentUser.points + _score;  // Добавяме новия резултат към стария
        await UserService().updateUserPoints(widget.userId, newScore);  // Обновяваме точките в базата

        // Маркираме забележителността като посетена
        await _visitedLandmarkService.createVisitedLandmark(
          VisitedLandmarkModel(
            userId: widget.userId,
            landmarkId: widget.landmark.id!,
            date: DateTime.now(),
          ),
        );

        setState(() {
          _isQuizCompleted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking landmark visited or updating points: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    if (_quizQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: colors['background'],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isQuizCompleted) {
      return _buildQuizCompletionScreen(colors, textStyles);
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final allAnswers = _currentShuffledAnswers;

    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<String>(
                    future: _prefsManager.translate("Въпрос ${_currentQuestionIndex + 1}/${_quizQuestions.length}"),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Въпрос ${_currentQuestionIndex + 1}/${_quizQuestions.length}",
                        style: textStyles['headingLarge'],
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<String>(
                    future: _prefsManager.translate(currentQuestion.question),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? currentQuestion.question,
                        style: textStyles['headingLarge'],
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ...allAnswers.map((answer) => _buildAnswerOption(
                    answer,
                    colors,
                    textStyles,
                    isCorrect: answer == currentQuestion.correctAnswer,
                  )),
                  const SizedBox(height: 24),
                  if (_isAnswerSubmitted)
                    FutureBuilder<String>(
                      future: _prefsManager.translate(
                        _selectedAnswer == currentQuestion.correctAnswer
                            ? 'Правилно!'
                            : 'Грешка! Правилният отговор е ${currentQuestion.correctAnswer}',
                      ),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? '',
                          style: TextStyle(
                            color: _selectedAnswer == currentQuestion.correctAnswer
                                ? Colors.green
                                : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _prefsManager.translate(
                      _currentQuestionIndex < _quizQuestions.length - 1 ? "Следващ" : "Приключи",
                    ),
                    builder: (context, snapshot) {
                      return ElevatedButton(
                        onPressed: _isAnswerSubmitted ? _nextQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['button'],
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          snapshot.data ?? (_currentQuestionIndex < _quizQuestions.length - 1 ? "Next" : "Finish"),
                          style: textStyles['buttonText'],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
      String text,
      Map<String, Color> colors,
      Map<String, TextStyle> textStyles, {
        required bool isCorrect,
      }) {
    final bool isSelected = _selectedAnswer == text;
    Color borderColor = colors['answerOptionBorder'] ?? Colors.grey;
    Color backgroundColor = colors['answerOptionBackground'] ?? Colors.white;

    if (_isAnswerSubmitted) {
      if (isSelected) {
        backgroundColor = isCorrect ? Colors.green[100]! : Colors.red[100]!;
        borderColor = isCorrect ? Colors.green : Colors.red;
      } else if (isCorrect) {
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green;
      }
    }

    return FutureBuilder<String>(
      future: _prefsManager.translate(text),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () => _submitAnswer(text),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              snapshot.data ?? text,
              style: textStyles['answerOptionText'],
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizCompletionScreen(
      Map<String, Color> colors,
      Map<String, TextStyle> textStyles,
      ) {
    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String>(
                  future: _prefsManager.translate('Куизът завърши!'),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Куизът завърши!',
                      style: textStyles['headingLarge'],
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<String>(
                  future: _prefsManager.translate('Твоят резултат е:'),
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data ?? "Твоят резултат е:"} $_score',
                      style: textStyles['headingLarge'],
                    );
                  },
                ),
                const SizedBox(height: 32),
                FutureBuilder<String>(
                  future: _prefsManager.translate('Към начален екран'),
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors['button'],
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        snapshot.data ?? 'Към начален екран',
                        style: textStyles['buttonText'],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
