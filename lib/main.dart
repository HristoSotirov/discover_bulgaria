import 'package:flutter/material.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('Supabase Demo')),
        body: Center(child: Text('Hello, Supabase!')),
      ),
    );
  }
}
