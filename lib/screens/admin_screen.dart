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
  final _imageUrlController = TextEditingController();
  final _landmarkService = LandmarkService();
  final _questionService = QuestionService();
  final _prefsManager = PreferencesManager();
  bool _isLoading = false;
  List<QuestionModel> _allQuestions = [];
  List<String> _selectedQuestionIds = [];
  final _questionSearchController = TextEditingController();
  List<QuestionModel> _filteredQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _questionSearchController.addListener(_filterQuestions);
  }

  @override
  void dispose() {
    _questionSearchController.dispose();
    super.dispose();
  }

  void _filterQuestions() {
    final query = _questionSearchController.text.toLowerCase();
    setState(() {
      _filteredQuestions = _allQuestions.where((question) =>
        question.question.toLowerCase().contains(query) ||
        question.correctAnswer.toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _questionService.getAllQuestions();
      setState(() {
        _allQuestions = questions;
        _filteredQuestions = questions;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveLandmark() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final landmark = LandmarkModel(
        imageUrl: _imageUrlController.text,
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        questions: _selectedQuestionIds, // Use selected question IDs
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
                  FutureBuilder<String>(
                    future: _prefsManager.translate('Име на забележителността'),
                    builder: (context, snapshot) => TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: snapshot.data ?? '',
                        border: OutlineInputBorder(),
                        labelStyle: _prefsManager.currentStyles['bodyRegular'],
                      ),
                      style: _prefsManager.currentStyles['bodyRegular'],
                      validator: (value) => value?.isEmpty == true ? 
                        'Моля въведете име' : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _prefsManager.translate('Описание'),
                    builder: (context, snapshot) => TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: snapshot.data ?? '',
                        border: OutlineInputBorder(),
                        labelStyle: _prefsManager.currentStyles['bodyRegular'],
                      ),
                      style: _prefsManager.currentStyles['bodyRegular'],
                      maxLines: 3,
                      validator: (value) => value?.isEmpty == true ? 
                        'Моля въведете описание' : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _prefsManager.translate('Географска ширина'),
                          builder: (context, snapshot) => TextFormField(
                            controller: _latitudeController,
                            decoration: InputDecoration(
                              labelText: snapshot.data ?? '',
                              border: OutlineInputBorder(),
                              labelStyle: _prefsManager.currentStyles['bodyRegular'],
                            ),
                            style: _prefsManager.currentStyles['bodyRegular'],
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _prefsManager.translate('Географска дължина'),
                          builder: (context, snapshot) => TextFormField(
                            controller: _longitudeController,
                            decoration: InputDecoration(
                              labelText: snapshot.data ?? '',
                              border: OutlineInputBorder(),
                              labelStyle: _prefsManager.currentStyles['bodyRegular'],
                            ),
                            style: _prefsManager.currentStyles['bodyRegular'],
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _prefsManager.translate('URL на снимката'),
                    builder: (context, snapshot) => TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: snapshot.data ?? '',
                        border: OutlineInputBorder(),
                        labelStyle: _prefsManager.currentStyles['bodyRegular'],
                      ),
                      style: _prefsManager.currentStyles['bodyRegular'],
                      validator: (value) => value?.isEmpty == true ? 
                        'Please enter image URL' : null,
                    ),
                  ),
                  if (_imageUrlController.text.isNotEmpty) ...[
                    Image.network(
                      _imageUrlController.text,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) =>
                          Text('Invalid image URL'),
                    ),
                    SizedBox(height: 16),
                  ],
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _prefsManager.translate('Търсене на въпроси'),
                    builder: (context, snapshot) => TextField(
                      controller: _questionSearchController,
                      decoration: InputDecoration(
                        labelText: snapshot.data ?? '',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        labelStyle: _prefsManager.currentStyles['bodyRegular'],
                      ),
                      style: _prefsManager.currentStyles['bodyRegular'],
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    color: _prefsManager.currentColors['box'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder<String>(
                            future: _prefsManager.translate('Изберете въпроси за тази забележителност'),
                            builder: (context, snapshot) => Text(
                              snapshot.data ?? '',
                              style: _prefsManager.currentStyles['bodyRegular'],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final question = _filteredQuestions[index];
                            final isSelected = _selectedQuestionIds.contains(question.id);
                            
                            return CheckboxListTile(
                              title: Text(question.question),
                              subtitle: Text(question.correctAnswer),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedQuestionIds.add(question.id!);
                                  } else {
                                    _selectedQuestionIds.remove(question.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _prefsManager.translate('Запази'),
                    builder: (context, snapshot) => ElevatedButton(
                      onPressed: _isLoading ? null : _saveLandmark,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _prefsManager.currentColors['button'],
                        foregroundColor: _prefsManager.currentColors['background'],
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: _prefsManager.currentColors['background']
                            )
                          : Text(
                              snapshot.data ?? '',
                              style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                                color: _prefsManager.currentColors['background']
                              ),
                            ),
                    ),
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

class DeleteLandscapeScreen extends StatefulWidget {
  const DeleteLandscapeScreen({super.key});

  @override
  State<DeleteLandscapeScreen> createState() => _DeleteLandscapeScreenState();
}

class _DeleteLandscapeScreenState extends State<DeleteLandscapeScreen> {
  final _landscapeService = LandmarkService();
  final _prefsManager = PreferencesManager();
  List<LandmarkModel> _landscapes = [];
  List<LandmarkModel> _filteredLandscapes = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLandscapes();
    _searchController.addListener(_filterLandscapes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLandscapes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLandscapes = _landscapes.where((landmark) =>
        landmark.name.toLowerCase().contains(query) ||
        landmark.description.toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _loadLandscapes() async {
    try {
      final landscapes = await _landscapeService.getAllLandmarks();
      setState(() {
        _landscapes = landscapes;
        _filteredLandscapes = landscapes;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Изтриване на забележителност'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<String>(
              future: _prefsManager.translate('Търсене на забележителности'),
              builder: (context, snapshot) => TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: snapshot.data ?? '',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  labelStyle: _prefsManager.currentStyles['bodyRegular'],
                ),
                style: _prefsManager.currentStyles['bodyRegular'],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredLandscapes.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: Image.network(_filteredLandscapes[index].imageUrl, width: 50),
                      title: Text(_filteredLandscapes[index].name),
                      subtitle: Text(_filteredLandscapes[index].description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (_filteredLandscapes[index].id != null) {
                            await _landscapeService.deleteLandmark(_filteredLandscapes[index].id!);
                            _loadLandscapes();
                          }
                        },
                      ),
                    ),
                  ),
          ),
        ],
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
  final _landmarkService = LandmarkService(); 
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  List<QuestionModel> _filteredQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _searchController.addListener(_filterQuestions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterQuestions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredQuestions = _questions.where((question) =>
        question.question.toLowerCase().contains(query) ||
        question.correctAnswer.toLowerCase().contains(query)
      ).toList();
    });
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

  Future<void> _deleteQuestion(QuestionModel question) async {
    if (question.id == null) return;

    try {
      // First, find all landmarks that have this question
      final landmarks = await _landmarkService.getAllLandmarks();
      for (var landmark in landmarks) {
        if (landmark.questions.contains(question.id)) {
          // Remove the question ID from the landmark's questions list
          final updatedLandmark = LandmarkModel(
            id: landmark.id,
            imageUrl: landmark.imageUrl,
            name: landmark.name,
            description: landmark.description,
            latitude: landmark.latitude,
            longitude: landmark.longitude,
            questions: landmark.questions.where((q) => q != question.id).toList(),
          );
          await _landmarkService.updateLandmark(updatedLandmark);
        }
      }

      // Then delete the question
      await _questionService.deleteQuestion(question.id!);
      _loadQuestions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
          future: _prefsManager.translate('Изтриване на въпрос'),
          builder: (context, snapshot) => Text(
            snapshot.data ?? '',
            style: _prefsManager.currentStyles['heading'],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<String>(
              future: _prefsManager.translate('Търсене на въпроси'),
              builder: (context, snapshot) => TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: snapshot.data ?? '',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  labelStyle: _prefsManager.currentStyles['bodyRegular'],
                ),
                style: _prefsManager.currentStyles['bodyRegular'],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredQuestions.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_filteredQuestions[index].question),
                      subtitle: Text(_filteredQuestions[index].correctAnswer),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (_filteredQuestions[index].id != null) {
                            await _deleteQuestion(_filteredQuestions[index]);
                          }
                        },
                      ),
                    ),
                  ),
          ),
        ],
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
        incorrectAnswers: [
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
              FutureBuilder<String>(
                future: _prefsManager.translate('Въпрос'),
                builder: (context, snapshot) => TextFormField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: snapshot.data ?? '',
                    border: OutlineInputBorder(),
                    labelStyle: _prefsManager.currentStyles['bodyRegular'],
                  ),
                  style: _prefsManager.currentStyles['bodyRegular'],
                  validator: (value) => value?.isEmpty == true ? 'Моля въведете въпрос' : null,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<String>(
                future: _prefsManager.translate('Правилен отговор'),
                builder: (context, snapshot) => TextFormField(
                  controller: _correctAnswerController,
                  decoration: InputDecoration(
                    labelText: snapshot.data ?? '',
                    border: OutlineInputBorder(),
                    labelStyle: _prefsManager.currentStyles['bodyRegular'],
                  ),
                  style: _prefsManager.currentStyles['bodyRegular'],
                  validator: (value) => value?.isEmpty == true ? 'Моля въведете правилен отговор' : null,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<String>(
                future: _prefsManager.translate('Грешен отговор 1'),
                builder: (context, snapshot) => TextFormField(
                  controller: _wrongAnswer1Controller,
                  decoration: InputDecoration(
                    labelText: snapshot.data ?? '',
                    border: OutlineInputBorder(),
                    labelStyle: _prefsManager.currentStyles['bodyRegular'],
                  ),
                  style: _prefsManager.currentStyles['bodyRegular'],
                  validator: (value) => value?.isEmpty == true ? 'Моля въведете грешен отговор' : null,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<String>(
                future: _prefsManager.translate('Грешен отговор 2'),
                builder: (context, snapshot) => TextFormField(
                  controller: _wrongAnswer2Controller,
                  decoration: InputDecoration(
                    labelText: snapshot.data ?? '',
                    border: OutlineInputBorder(),
                    labelStyle: _prefsManager.currentStyles['bodyRegular'],
                  ),
                  style: _prefsManager.currentStyles['bodyRegular'],
                  validator: (value) => value?.isEmpty == true ? 'Моля въведете грешен отговор' : null,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<String>(
                future: _prefsManager.translate('Грешен отговор 3'),
                builder: (context, snapshot) => TextFormField(
                  controller: _wrongAnswer3Controller,
                  decoration: InputDecoration(
                    labelText: snapshot.data ?? '',
                    border: OutlineInputBorder(),
                    labelStyle: _prefsManager.currentStyles['bodyRegular'],
                  ),
                  style: _prefsManager.currentStyles['bodyRegular'],
                  validator: (value) => value?.isEmpty == true ? 'Моля въведете грешен отговор' : null,
                ),
              ),
              SizedBox(height: 32),
              FutureBuilder<String>(
                future: _prefsManager.translate('Запази'),
                builder: (context, snapshot) => ElevatedButton(
                  onPressed: _isLoading ? null : _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _prefsManager.currentColors['button'],
                    foregroundColor: _prefsManager.currentColors['background'],
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: _prefsManager.currentColors['background'])
                      : Text(
                          snapshot.data ?? '',
                          style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                            color: _prefsManager.currentColors['background']
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

