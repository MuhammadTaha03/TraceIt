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
    const primaryColor = Color(0xFF1A73E8);
    const outlineColor = Color(0xFF727785);
    const outlineVariant = Color(0xFFC1C6D6);
    const backgroundColor = Color(0xFFF8F9FA);
    const onSurface = Color(0xFF191C1D);
    const errorColor = Color(0xFFBA1A1A);

    return MaterialApp(
      title: 'TraceIt',
      debugShowCheckedModeBanner: false,
      
      // Beautiful premium M3 theme
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: const Color(0xFF005AC1),
          error: errorColor,
          surface: backgroundColor,
          onSurface: onSurface,
        ),
        
        // Form field formatting matching M3 rounded design
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: outlineVariant, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: errorColor, width: 2),
          ),
          hintStyle: TextStyle(
            color: outlineColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: outlineColor,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Text typography defaults (Inter per DESIGN.md)
        fontFamily: 'Inter', 
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.02),
          headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: onSurface),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: onSurface),
          titleMedium: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: onSurface),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: onSurface),
          labelLarge: TextStyle(fontWeight: FontWeight.w600, color: onSurface),
        ),

        // Custom AppBar M3 default styling
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: onSurface),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            color: onSurface,
            fontWeight: FontWeight.w600,
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
            color: Color(0xFF1A73E8),
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
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBA1A1A)),
            ),
          ),
        ),
      ),
    );
  }
}