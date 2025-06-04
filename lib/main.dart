import 'package:flutter/material.dart';
import 'package:admin/auth/LoginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://vthiecdhvedvbokcbpca.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0aGllY2RodmVkdmJva2NicGNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2NjAxODEsImV4cCI6MjA2NDIzNjE4MX0.mKmJI9hHCzCBxEmJyAK4SbkxNXXtPGdoJmRg8pGlybY",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
