import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'welcom/choose_user_type_screen.dart';
import 'welcom/login_screen.dart';
import 'welcom/register_screen.dart';
import 'home/chat_screen.dart';
import 'home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // تعريف الألوان كثوابت لتسهيل استخدامها في أي مكان
  static const Color kColorBackground = Color(0xFFFFF2F2); // خلفية عامة
  static const Color kColorPrimary = Color(0xFF2D336B); // اللون الأساسي
  static const Color kColorSecondary = Color(0xFFA9B5DF); // اللون الثانوي
  static const Color kColorAccent = Color(0xFF7886C7); // لون مساعد (اختياري)

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'University App',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          // خلفية التطبيق
          scaffoldBackgroundColor: kColorBackground,

          // اللون الأساسي
          primaryColor: kColorPrimary,

          // تدرج ألوان التطبيق (يؤثر على كثير من العناصر كالـ Buttons وغيرها)
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: kColorPrimary,
            secondary: kColorSecondary,
          ),

          // مثال لتعريف الخطوط العريضة لاختيارات النص
          fontFamily: 'Amiri',
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14),
          ),

          // تنسيق الحقول
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.grey),
          ),

          // تنسيق الأزرار
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: kColorPrimary,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: kColorPrimary,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // صفحة البداية
        home: const AppWrapper(),

        // مسارات التنقل في التطبيق
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          OneSidedChatScreen.routeName: (context) => OneSidedChatScreen(userType: 'doctor'),
          ChooseRoleScreen.routeName: (context) => const ChooseRoleScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          CreateAccountScreen.routeName: (context) => const CreateAccountScreen(),
        },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          return HomeScreen();
        }

        return const ChooseRoleScreen();
      },
    );
  }
}