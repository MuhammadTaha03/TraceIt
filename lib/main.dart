import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // 1. Must be called before any async operations in main()
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase safely
  await Supabase.initialize(
    url: 'https://lkleqhrwngbwlljpfisk.supabase.co/rest/v1/', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrbGVxaHJ3bmdid2xsanBmaXNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0OTE1NDYsImV4cCI6MjA5NTA2NzU0Nn0.4kwKhCwZDn6TE1b01v1zuslSjbwrLtuVcf44E_28ooU', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Supabase initialized without errors!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}