import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import '../services/question_service.dart';
import '../services/user_service.dart';
import '../config/preferences_manager.dart';

class DailyQuizScreen extends StatefulWidget {
  final UserModel currentUser;

  const DailyQuizScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _DailyQuizScreenState createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  late final QuestionService _questionService;
  late final UserService _userService;
  late final PreferencesManager _prefsManager;
  late List<QuestionModel> _questions = [];
  late List<QuestionModel> _quizQuestions = [];
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
    _userService = UserService();
    _prefsManager = PreferencesManager();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    try {
      // Fetch all questions from database
      _questions = await _questionService.getAllQuestions();

      // Shuffle and take first 5 questions
      _questions.shuffle();
      _quizQuestions = _questions.take(5).toList();
      
      // Initialize answers for first question
      if (_quizQuestions.isNotEmpty) {
        _currentShuffledAnswers = List.from(_quizQuestions[0].allAnswers)..shuffle();
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _submitAnswer(String answer) {
    if (_isAnswerSubmitted) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswerSubmitted = true;

      // Check if answer is correct
      if (answer == _quizQuestions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        // Shuffle answers for the new question
        _currentShuffledAnswers = List.from(_quizQuestions[_currentQuestionIndex].allAnswers)..shuffle();
        _selectedAnswer = null;
        _isAnswerSubmitted = false;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    setState(() {
      _isQuizCompleted = true;
    });

    // Update user points
    final updatedUser = widget.currentUser.copyWith(
      points: widget.currentUser.points + _score,
      isDailyQuizDone: true,
    );

    try {
      await _userService.updateUser(updatedUser);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user points: $e')),
        );
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      _quizQuestions.shuffle();
      _currentQuestionIndex = 0;
      // Reset shuffled answers for the first question
      _currentShuffledAnswers = List.from(_quizQuestions[0].allAnswers)..shuffle();
      _score = 0;
      _selectedAnswer = null;
      _isAnswerSubmitted = false;
      _isQuizCompleted = false;
    });
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
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
    Map<String, TextStyle> textStyles,
    {required bool isCorrect}
  ) {
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
                  future: _prefsManager.translate('Твоят резултат е'),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Твоят резултат е',
                      style: textStyles['headingLarge'],
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  '$_score/${_quizQuestions.length}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colors['button'],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FutureBuilder<String>(
                  future: _prefsManager.translate('Ти спечели $_score точки!'),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Ти спечели $_score точки!',
                      style: textStyles['bodyMedium'],
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 32),
                FutureBuilder<String>(
                  future: _prefsManager.translate('Върни се в началото'),
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors['button'],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        snapshot.data ?? 'Върни се в началото',
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

