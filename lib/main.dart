import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_providers.dart';
import 'screens/auth_screen.dart';
import 'screens/home_feed_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase cleanly
  await Supabase.initialize(
    url: 'https://lkleqhrwngbwlljpfisk.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrbGVxaHJ3bmdid2xsanBmaXNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0OTE1NDYsImV4cCI6MjA5NTA2NzU0Nn0.4kwKhCwZDn6TE1b01v1zuslSjbwrLtuVcf44E_28ooU', 
  );

  runApp(
    // Wrap entire app in ProviderScope to enable Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1E1E1E);

    return MaterialApp(
      title: 'TraceIt',
      debugShowCheckedModeBanner: false,
      
      // Beautiful modern flat minimalist theme
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD93D),
          primary: const Color(0xFFFFD93D),
          secondary: const Color(0xFF4ECDC4),
          error: const Color(0xFFFF6B6B),
        ),
        
        // Form field formatting
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          hintStyle: TextStyle(
            color: borderColor.withOpacity(0.3),
            fontWeight: FontWeight.bold,
          ),
        ),

        // Text typography defaults (Clean and Bold)
        fontFamily: 'Outfit', // Uses system font or Outfit if bundled
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: borderColor),
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: borderColor),
          titleLarge: TextStyle(fontWeight: FontWeight.w900, color: borderColor),
          titleMedium: TextStyle(fontWeight: FontWeight.bold, color: borderColor),
          bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: borderColor),
          bodyMedium: TextStyle(fontWeight: FontWeight.normal, color: borderColor),
        ),

        // Custom AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: borderColor),
          titleTextStyle: TextStyle(
            color: borderColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),

      // Auth gateway as home page
      home: const AuthGateway(),

      // Standard Named Routes
      routes: {
        '/feed': (context) => const HomeFeedScreen(),
        '/create': (context) => const CreatePostScreen(),
        '/details': (context) => const PostDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

/// Dynamic Authentication Gateway that listens to the user session stream
/// and presents the feed or the auth screen seamlessly.
class AuthGateway extends ConsumerWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) {
          return const HomeFeedScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E1E1E),
            strokeWidth: 3,
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Authentication Error: $err\nPlease check connection or reload.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B)),
            ),
          ),
        ),
      ),
    );
  }
}