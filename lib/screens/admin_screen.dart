import 'package:discover_bulgaria/models/landmark_model.dart';
import 'package:discover_bulgaria/models/question_model.dart';
import 'package:discover_bulgaria/services/landmark_service.dart';
import 'package:discover_bulgaria/services/question_service.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/preferences_manager.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  final String userId;
  final UserModel initialUserData;

  const AdminScreen({
    super.key,
    required this.userId,
    required this.initialUserData,
  });

  @override
  State<AdminScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminScreen> {
  final _prefsManager = PreferencesManager();
  final _userService = UserService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Грешка при зареждане: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Административен панел'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _prefsManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _prefsManager.currentColors['text'],
            ),
            onPressed: () {
              setState(() {
                _prefsManager.setDarkMode(!_prefsManager.isDarkMode);
              });
            },
          ),
          TextButton(
            child: Text(
              _prefsManager.languages[_prefsManager.selectedLanguage]?['symbol'] ?? 'БГ',
              style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                fontWeight: FontWeight.bold
              ),
            ),
            onPressed: () {
              setState(() {
                final newLang = _prefsManager.selectedLanguage == 'bg' ? 'en' : 'bg';
                _prefsManager.setLanguage(newLang);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: _prefsManager.currentColors['text']),
            onPressed: () async {
              await _prefsManager.clearUserSession();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialUserData.name,
                  style: _prefsManager.currentStyles['headingLarge'],
                ),
                FutureBuilder<String>(
                  future: _prefsManager.translate('АДМИНИСТРАТОР'),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? '',
                    style: _prefsManager.currentStyles['bodyRegular'],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(
                    color: _prefsManager.currentColors['button']
                  ))
                : FutureBuilder<List<String>>(
                    future: Future.wait([
                      _prefsManager.translate('Добави забележителност'),
                      _prefsManager.translate('Добави въпрос'),
                      _prefsManager.translate('Изтрий забележителност'),
                      _prefsManager.translate('Изтрий въпрос'),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(
                          color: _prefsManager.currentColors['button']
                        ));
                      }

                      final texts = snapshot.data!;
                      return GridView.count(
                        padding: const EdgeInsets.all(16),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          _buildActionCard(
                            icon: Icons.add_photo_alternate,
                            title: texts[0],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddLandscapeScreen())
                            ),
                          ),
                          _buildActionCard(
                            icon: Icons.question_answer,
                            title: texts[1],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddQuestionScreen())
                            ),
                          ),
                          _buildActionCard(
                            icon: Icons.delete,
                            title: texts[2],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DeleteLandscapeScreen())
                            ),
                          ),
                          _buildActionCard(
                            icon: Icons.delete_forever,
                            title: texts[3],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DeleteQuestionScreen())
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: _prefsManager.currentColors['box'],
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: _prefsManager.currentColors['accent']),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: _prefsManager.currentStyles['bodyRegular'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Екран за добавяне на пейзаж
class AddLandscapeScreen extends StatefulWidget {
  const AddLandscapeScreen({super.key});

  @override
  State<AddLandscapeScreen> createState() => _AddLandscapeScreenState();
}

class _AddLandscapeScreenState extends State<AddLandscapeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _landmarkService = LandmarkService();
  final _prefsManager = PreferencesManager();
  String? _imageUrl;
  bool _isLoading = false;

  Future<void> _uploadImage() async {
    setState(() {
      _imageUrl = 'https://placeholder.com/image.jpg';
    });
  }

  Future<void> _saveLandmark() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final landmark = LandmarkModel(
        imageUrl: _imageUrl ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        questions: [],
      );

      await _landmarkService.createLandmark(landmark);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(await _prefsManager.translate('Забележителността е добавена успешно'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Добавяне на забележителност'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Име на забележителността',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Моля въведете име' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty == true ? 'Моля въведете описание' : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.upload),
                    label: Text('Качи снимка'),
                    onPressed: _uploadImage,
                  ),
                  if (_imageUrl != null) ...[
                    SizedBox(height: 16),
                    Image.network(_imageUrl!, height: 200),
                  ],
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveLandmark,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _prefsManager.currentColors['button'],
                      foregroundColor: _prefsManager.currentColors['background'],
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: _prefsManager.currentColors['background'])
                        : Text('Запази'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Екран за изтриване на пейзаж
class DeleteLandscapeScreen extends StatefulWidget {
  const DeleteLandscapeScreen({super.key});

  @override
  State<DeleteLandscapeScreen> createState() => _DeleteLandscapeScreenState();
}

class _DeleteLandscapeScreenState extends State<DeleteLandscapeScreen> {
  final _landscapeService = LandmarkService();
  final _prefsManager = PreferencesManager();
  List<LandmarkModel> _landscapes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLandscapes();
  }

  Future<void> _loadLandscapes() async {
    try {
      final landscapes = await _landscapeService.getAllLandmarks();
      setState(() {
        _landscapes = landscapes;
        _isLoading = false;
      });
    } catch (e) {
      // Грешка
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Изтриване на пейзаж'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _landscapes.length,
        itemBuilder: (context, index) => ListTile(
          leading: Image.network(_landscapes[index].imageUrl, width: 50),
          title: Text(_landscapes[index].name),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              if (_landscapes[index].id != null) {
                await _landscapeService.deleteLandmark(_landscapes[index].id!);
                _loadLandscapes();
              }
            },
          ),
        ),
      ),
    );
  }
}

// Екран за изтриване на въпрос
class DeleteQuestionScreen extends StatefulWidget {
  const DeleteQuestionScreen({super.key});

  @override
  State<DeleteQuestionScreen> createState() => _DeleteQuestionScreenState();
}

class _DeleteQuestionScreenState extends State<DeleteQuestionScreen> {
  final _questionService = QuestionService();
  final _prefsManager = PreferencesManager();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _questionService.getAllQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Изтриване на въпрос'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_questions[index].question),
          subtitle: Text(_questions[index].correctAnswer),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              if (_questions[index].id != null) {
                await _questionService.deleteQuestion(_questions[index].id!);
                _loadQuestions();
              }
            },
          ),
        ),
      ),
    );
  }
}

// Екран за добавяне на въпрос
class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _wrongAnswer1Controller = TextEditingController();
  final _wrongAnswer2Controller = TextEditingController();
  final _wrongAnswer3Controller = TextEditingController();
  final _questionService = QuestionService();
  final _prefsManager = PreferencesManager();
  bool _isLoading = false;

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final question = QuestionModel(
        question: _questionController.text,
        correctAnswer: _correctAnswerController.text,
        incorrectAnswers: [  // Changed from wrongAnswers to incorrectAnswers
          _wrongAnswer1Controller.text,
          _wrongAnswer2Controller.text,
          _wrongAnswer3Controller.text,
        ],
      );

      await _questionService.createQuestion(question);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(await _prefsManager.translate('Въпросът е добавен успешно'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Добавяне на въпрос'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Въпрос',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Моля въведете въпрос' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _correctAnswerController,
                decoration: InputDecoration(
                  labelText: 'Правилен отговор',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Моля въведете правилен отговор' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _wrongAnswer1Controller,
                decoration: InputDecoration(
                  labelText: 'Грешен отговор 1',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Моля въведете грешен отговор' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _wrongAnswer2Controller,
                decoration: InputDecoration(
                  labelText: 'Грешен отговор 2',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Моля въведете грешен отговор' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _wrongAnswer3Controller,
                decoration: InputDecoration(
                  labelText: 'Грешен отговор 3',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Моля въведете грешен отговор' : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _prefsManager.currentColors['button'],
                  foregroundColor: _prefsManager.currentColors['background'],
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: _prefsManager.currentColors['background'])
                    : Text('Запази'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

